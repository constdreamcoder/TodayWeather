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

final class SearchViewModel {
    static let shared = SearchViewModel()
    
    var userLocationSubject = PublishSubject<[CLLocationDegrees]>()
    var userLocationRelay = BehaviorRelay<[CLLocationDegrees]>(value: [])
    
    var searchDataSectionListRelay = BehaviorRelay<[SearchDataSection]>(value: [])
    var searchText: String = ""
    
    var infoWindowContentsRelay = PublishRelay<String>()
    
    private var _isSearchMode: Bool = false
    var isSearchMode: Bool {
        get {
            return _isSearchMode
        }
        set {
            _isSearchMode = newValue
        }
    }
    
    private init() {
        // SearchViewModel과 연결
        userLocationSubject
            .take(1)
            .bind(to: userLocationRelay)
    }
    
    func getRecentlySearchedResultList() {
        let recentlySearchedAddressList = RecentlySearchedAddressService.shared.fetchRecentlySearchedAddressList()
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
            .take(1)
            .subscribe(onNext: { [weak self] searchedRegionList in
                guard let weakSelf = self else { return }
                weakSelf.searchDataSectionListRelay.accept([
                    SearchDataSection(items: searchedRegionList)
                ])
            })
    }
    
    func searchAddressList() {
        GeolocationService.shared.fetchGeolocationRx(query: searchText)
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
            .take(1)
            .subscribe(onNext: { [weak self] searchedRegionList in
                guard let weakSelf = self else { return }
                weakSelf.searchDataSectionListRelay.accept([
                    SearchDataSection(items: searchedRegionList)
                ])
            })
    }
    
    func getWeatherForecastInfosOfSelectedRegion(latitude: Double, longitude: Double) {
        let convertedXY = ConvertXY().convertGRID_GPS(mode: .TO_GRID, lat_X: latitude, lng_Y: longitude)
        print(convertedXY.x, convertedXY.y)
        
        Observable.combineLatest(
            DailyWeatherForecastService.shared.fetchDailyWeatherForecastInfosRx(nx: convertedXY.x, ny: convertedXY.y),
            RealtimeForcastService.shared.fetchRealtimeForecastsRx(nx: convertedXY.x, ny: convertedXY.y)
        ) { dwfItems, items -> InfoWindowContents in
            let lowAndHighTempForToday = dwfItems.getHighAndLowTemperatureForToday(today: Date().getBaseDateAndTimeForDailyWeatherForecast.baseDate)
            let currentWeatherCondition =  items.getCurrentWeatherConditionInfos()
            return InfoWindowContents(
                highestTemperature: lowAndHighTempForToday.highestTemp,
                lowestTemperature: lowAndHighTempForToday.lowestTemp,
                currentWeatherCondition: currentWeatherCondition
            )
        }
        .take(1)
        .subscribe(onNext: { [weak self] infoWindowContents in
            guard let weakSelf = self else { return }
            let contents = "현재: \(infoWindowContents.currentWeatherCondition.temperature)° / 최저(일): \(infoWindowContents.lowestTemperature)° / 최고(일): \(infoWindowContents.highestTemperature)°"
            weakSelf.infoWindowContentsRelay.accept(contents)
        })
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
