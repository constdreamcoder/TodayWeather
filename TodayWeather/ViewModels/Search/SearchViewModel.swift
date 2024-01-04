//
//  SearchViewModel.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/30.
//

import Foundation
import NMapsMap
import RxSwift
import RxRelay
import RxDataSources
import RxRealm
import RxCocoa

protocol SearchUserEvent: AnyObject {
    func showTableView(isHidden: Bool)
    func goBackToHome()
    func resignSearchBarFromFirstResponder()
    func showInfoWindowOnMarker(latitude: Double, longitude: Double, address: Address, addressForSearchNextForecast: String)
    func moveToUser()
}

final class SearchViewModel: ViewModelType {
    struct Input {
        let goBackBtnTapped: Driver<Void>
        let searchBarTextInput: Driver<String>
        let textDidBeginEditing: Driver<Void>
        let textDidEndEditing: Driver<Void>
        let searchButtonClicked: Driver<Void>
        let addressSelected: Driver<IndexPath>
        let moveToUserBtnTapped: Driver<Void>
    }
    
    struct Output {
        let goBackToHome: Driver<Void>
        let textDidBeginEditing: Driver<Void>
        let textDidEndEditing: Driver<Void>
        let searchButtonClicked: Driver<Void>
        let userLocation: Driver<ConvertXY.LatXLngY>
        let searchDataSectionList: Driver<[SearchDataSection]>
        let infoWindowContents: Driver<String>
        let addressSelected: Driver<IndexPath>
        let moveToUser: Driver<Void>
        let searchedTextData: BehaviorRelay<String>
    }
    
    func transform(input: Input) -> Output {
        let goBackToHome = input.goBackBtnTapped.do { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.delegate?.goBackToHome()
        }
        
        input.searchBarTextInput.asObservable()
//            .debounce(.milliseconds(300), scheduler: MainScheduler.instance) // 입력이 멈춘 후 0.3초 기다림
//            .distinctUntilChanged() // 이전 값과 같은 값은 무시
            .map { [weak self] searchText -> String in
                guard let weakSelf = self else { return "" }
                if searchText == "" {
                    weakSelf.getRecentlySearchedResultList()
                }
                return searchText
            }
            .bind(to: searchTextRelay)
            .disposed(by: dispostBag)
        
        let searchedTextData = searchTextRelay
        
        let textDidBeginEditing = input.textDidBeginEditing
            .do { [weak self] _ in
                guard let weakSelf = self else { return }
                weakSelf.delegate?.showTableView(isHidden: false)
                if weakSelf.searchTextRelay.value != "" {
                    weakSelf.isSearchMode = true
                    weakSelf.searchAddressList()
                } else if weakSelf.searchTextRelay.value == "" {
                    weakSelf.isSearchMode = false
                    weakSelf.getRecentlySearchedResultList()
                }
            }
        
        let textDidEndEditing = input.textDidEndEditing.do { _ in
            print("끝남")
        }
        
        let searchButtonClicked = input.searchButtonClicked
            .do { [weak self] _ in
                guard let weakSelf = self else { return }
                if weakSelf.searchTextRelay.value != "" {
                    weakSelf.isSearchMode = true
                    weakSelf.searchAddressList()
                    weakSelf.delegate?.resignSearchBarFromFirstResponder()
                }
            }
        
        let addressSelectecd = input.addressSelected
            .do(onNext: { [weak self] indexPath in
                guard let weakSelf = self else { return }
                let addressItems = weakSelf.searchDataSectionListRelay.value[0].items
                
                if addressItems.isEmpty { return }
                
                let selectedItem = addressItems[indexPath.row]
                let addressForSearchNextForecast = selectedItem.addressForSearchNextForecast
                let selectedAddress = selectedItem.address
                
                guard let longitude = Double(selectedAddress.x),
                      let latitude = Double(selectedAddress.y)
                else { return }
                
                weakSelf.getWeatherForecastInfosOfSelectedRegion(latitude: latitude, longitude: longitude)
                
                weakSelf.delegate?.showInfoWindowOnMarker(latitude: latitude, longitude: longitude, address: selectedAddress, addressForSearchNextForecast: addressForSearchNextForecast)
                
                weakSelf.delegate?.showTableView(isHidden: true)
                weakSelf.updateRecentlySearchedAddressList(selectedAddress: selectedAddress, addressForSearchNextForecast: addressForSearchNextForecast)
                weakSelf.delegate?.resignSearchBarFromFirstResponder()
            })
        
        let userLocation = userLocationRelay.asDriver()
        let searchDataSectionList = searchDataSectionListRelay.asDriver()
        let infoWindowContents = infoWindowContentsRelay.asDriver(onErrorJustReturn: "")
        
        let moveToUser = input.moveToUserBtnTapped
            .do { [weak self] _ in
                guard let weakSelf = self else { return }
                weakSelf.delegate?.moveToUser()
            }
        return Output(
            goBackToHome: goBackToHome,
            textDidBeginEditing: textDidBeginEditing,
            textDidEndEditing: textDidEndEditing,
            searchButtonClicked: searchButtonClicked,
            userLocation: userLocation,
            searchDataSectionList: searchDataSectionList,
            infoWindowContents: infoWindowContents,
            addressSelected: addressSelectecd, 
            moveToUser: moveToUser, 
            searchedTextData: searchedTextData
        )
    }
    
    private let geolocationService: GeolocationServiceModel
    private let dailyWeatherForecastService: DailyWeatherForecastServiceModel
    private let realtimeForcastService: RealtimeForecastServiceModel
    private let recentlySearchedAddressService: RecentlySearchedAddressServiceModel
    
    private var userLocationRelay = BehaviorRelay<ConvertXY.LatXLngY>(value: ConvertXY.LatXLngY())
    private var searchDataSectionListRelay = BehaviorRelay<[SearchDataSection]>(value: [])
    private var infoWindowContentsRelay = PublishRelay<String>()
    private var searchTextRelay = BehaviorRelay<String>(value: "")
    
    var testRelay = BehaviorRelay<String>(value: "")
    
    private var dispostBag = DisposeBag()
    
    weak var delegate: SearchUserEvent?
        
    private var _isSearchMode: Bool = false
    var isSearchMode: Bool {
        get {
            return _isSearchMode
        }
        set {
            _isSearchMode = newValue
        }
    }
    
    private var userLocation: ConvertXY.LatXLngY?
    
    init(
        geolocationService: GeolocationServiceModel,
        dailyWeatherForecastService: DailyWeatherForecastServiceModel,
        realtimeForcastService: RealtimeForecastServiceModel,
        recentlySearchedAddressService: RecentlySearchedAddressServiceModel,
        userLocation: ConvertXY.LatXLngY
    ) {
        self.geolocationService = geolocationService
        self.dailyWeatherForecastService = dailyWeatherForecastService
        self.realtimeForcastService = realtimeForcastService
        self.recentlySearchedAddressService = recentlySearchedAddressService
        
        self.userLocation = userLocation
        
        // SearchViewModel과 연결
        Observable.just(userLocation)
            .bind(to: userLocationRelay)
            .disposed(by: dispostBag)
    }
    
    func getRecentlySearchedResultList() {
        let recentlySearchedAddressList = recentlySearchedAddressService.fetchRecentlySearchedAddressList()
        
        Observable.changeset(from: recentlySearchedAddressList)
            .take(1)
            .map { [weak self] results, changes -> [SearchedRegion] in
                guard let weakSelf = self else { return [] }
                if let changes = changes {
                    // it's an update
                    print("deleted: \(changes.deleted)")
                    print("inserted: \(changes.inserted)")
                    print("updated: \(changes.updated)")
                    return []
                } else {
                    // it's the initial data
                    let addressList = results.toArray()
                    var searchedRegionList: [SearchedRegion] = []
                    addressList.forEach { recentlySearchedAddressModel in
                        let address = Address(
                            roadAddress: recentlySearchedAddressModel.address,
                            jibunAddress: "",
                            englishAddress: "",
                            addressElements: [],
                            x: recentlySearchedAddressModel.longitude,
                            y: recentlySearchedAddressModel.latitude,
                            distance: 0
                        )
                        let searchedRegion = SearchedRegion(
                            address: address,
                            addressForSearchNextForecast: recentlySearchedAddressModel.addressForSearchNextForecast,
                            lowestTemperatureForToday: 0,
                            highestTemperatureForToday: 0,
                            isSearchMode: weakSelf._isSearchMode
                        )
                        searchedRegionList.append(searchedRegion)
                    }
                    return searchedRegionList
                }
            }
            .map { searchedRegionList -> [SearchDataSection] in
                return [
                    SearchDataSection(items: searchedRegionList)
                ]
            }
            .bind(to: searchDataSectionListRelay)
            .disposed(by: dispostBag)
    }
    
    func searchAddressList() {
        geolocationService.fetchGeolocationRx(query: searchTextRelay.value)
            .observe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
            .map{ [weak self] addressList -> [SearchedRegion] in
                guard let weakSelf = self else { return [] }
                var searchedRegionList: [SearchedRegion] = []
                addressList.forEach { address in
                    let siDo = address.addressElements[0].shortName
                    let siGuGun = address.addressElements[1].shortName
                    let searchedRegion = SearchedRegion(
                        address: address,
                        addressForSearchNextForecast: siDo + " " + siGuGun,
                        lowestTemperatureForToday: 0,
                        highestTemperatureForToday: 0,
                        isSearchMode: weakSelf._isSearchMode
                    )
                    searchedRegionList.append(searchedRegion)
                }
                return searchedRegionList
            }
            .map { searchedRegionList -> [SearchDataSection] in
                return [
                    SearchDataSection(items: searchedRegionList)
                ]
            }
            .bind(to: searchDataSectionListRelay)
            .disposed(by: dispostBag)
    }
    
    func getWeatherForecastInfosOfSelectedRegion(latitude: Double, longitude: Double) {
        let convertedXY = ConvertXY().convertGRID_GPS(mode: .TO_GRID, lat_X: latitude, lng_Y: longitude)
        
        Observable.combineLatest(
            dailyWeatherForecastService.fetchDailyWeatherForecastInfosRx(
                nx: convertedXY.x,
                ny: convertedXY.y,
                base_time: Date().getDateOfSelectedRegion.getBaseDateAndTimeForDailyWeatherForecast.baseTime
            ), realtimeForcastService.fetchRealtimeForecastsRx(
                nx: convertedXY.x,
                ny: convertedXY.y
            )
        ) { dwfItems, items -> String in
            let lowAndHighTempForToday = dwfItems.getHighAndLowTemperatureForToday(baseDate: Date().getBaseDateAndTimeForDailyWeatherForecast.baseDate)
            let currentWeatherCondition = items.getCurrentWeatherConditionInfos()
            
            let infoWindowContents = InfoWindowContents(
                highestTemperature: lowAndHighTempForToday.highestTemp,
                lowestTemperature: lowAndHighTempForToday.lowestTemp,
                currentWeatherCondition: currentWeatherCondition
            )
            
            let contents = "현재: \(infoWindowContents.currentWeatherCondition.temperature)° / 최저(일): \(infoWindowContents.lowestTemperature)° / 최고(일): \(infoWindowContents.highestTemperature)°"
            return contents
        }
        .bind(to: infoWindowContentsRelay)
        .disposed(by: dispostBag)
    }
}

// MARK: - SearchTableView DataSource 관련 메소드
extension SearchViewModel {
    func configureTableViewDataSource() -> RxTableViewSectionedReloadDataSource<SearchDataSection> {
        return RxTableViewSectionedReloadDataSource<SearchDataSection> { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as? SearchTableViewCell else { return UITableViewCell()}
            cell.bind(item: item)
            return cell
        } titleForHeaderInSection: { [weak self] dataSource, index in
            guard let weakSelf = self else { return  "최근 검색" }
            if weakSelf._isSearchMode {
                return ""
            }
            return "최근 검색"
        }
    }
}

// MARK: - Realm 관련 메소드
extension SearchViewModel {
    func updateRecentlySearchedAddressList(selectedAddress: Address, addressForSearchNextForecast: String){
        recentlySearchedAddressService.addNewlySearchedAddress(newAddress: selectedAddress, addressForSearchNextForecast: addressForSearchNextForecast)
    }
}
