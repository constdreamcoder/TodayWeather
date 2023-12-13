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

final class SearchViewModel: ViewModelType {
    struct Input {}
    
    struct Output {
        let userLocation: Driver<ConvertXY.LatXLngY>
        let searchDataSectionList: Driver<[SearchDataSection]>
        let infoWindowContents: Driver<String>
        let searchDataSectionListRelay: BehaviorRelay<[SearchDataSection]>
    }
    
    func transform(input: Input) -> Output {
        let userLocation = userLocationRelay.asDriver()
        let searchDataSectionList = searchDataSectionListRelay.asDriver()
        let infoWindowContents = infoWindowContentsRelay.asDriver(onErrorJustReturn: "")
        let searchDataSectionListRelay = searchDataSectionListRelay
        
        return Output(
            userLocation: userLocation,
            searchDataSectionList: searchDataSectionList, 
            infoWindowContents: infoWindowContents,
            searchDataSectionListRelay: searchDataSectionListRelay
        )
    }
    
    private let geolocationService: GeolocationService
    private let dailyWeatherForecastService: DailyWeatherForecastService
    private let realtimeForcastService: RealtimeForcastService
    private let recentlySearchedAddressService: RecentlySearchedAddressService
    
    private var userLocationRelay = BehaviorRelay<ConvertXY.LatXLngY>(value: ConvertXY.LatXLngY())
    private var searchDataSectionListRelay = BehaviorRelay<[SearchDataSection]>(value: [])
    private var infoWindowContentsRelay = PublishRelay<String>()

    private var dispostBag = DisposeBag()

    var searchText: String = ""
    
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
        geolocationService: GeolocationService,
        dailyWeatherForecastService: DailyWeatherForecastService,
        realtimeForcastService: RealtimeForcastService,
        recentlySearchedAddressService: RecentlySearchedAddressService,
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
        Observable.changeset(from:recentlySearchedAddressList)
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
        geolocationService.fetchGeolocationRx(query: searchText)
            .map{ [weak self] addressList -> [SearchedRegion] in
                guard let weakSelf = self else { return [] }
                
                var searchedRegionList: [SearchedRegion] = []
                addressList.forEach { address in
                    let searchedRegion = SearchedRegion(
                        address: address,
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
    func updateRecentlySearchedAddressList(selectedAddress: Address){
        recentlySearchedAddressService.addNewlySearchedAddress(newAddress: selectedAddress)
    }
}
