//
//  DetailViewModel.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/28.
//

import Foundation
import RxSwift
import RxRelay
import RxDataSources
import UIKit

struct NextForecastItem {
    var date: Date?
    var temperatureItem: NextForecastTemperatureItem?
    var skyConditionItem: NextForecastSkyConditionItem?
}

final class DetailViewModel {
    static let shared = DetailViewModel()
    
    var todayWeatherForecastListSubject = BehaviorSubject<[TodayWeatherForecasts]>(value: [])
    // CollectionView Section 데이터를 담고 있는 Relay
    var todayWeatherDataSectionListRelay = BehaviorRelay<[TodayWeatherDataSection]>(value: [])
        
    var nextForecastListRelay = BehaviorRelay<[NextForecastItem]>(value: [])
        
    private init() {
        // TODO: - DetailViewController
        setupNextForecastList(regIdForTemp: "11B10101", regIdForSky: "11B00000")
    }
}

// MARK: - 오늘 예보 관련 메소드
extension DetailViewModel {
    func reSetupTodayWeatherForecastList(latitude: Double, longitude: Double) {
        let convertedXY = ConvertXY().convertGRID_GPS(mode: .TO_GRID, lat_X: latitude, lng_Y: longitude)
        HomeViewModel.shared.getWeatherConditionOfCurrentLocationObservable(nx: convertedXY.x, ny: convertedXY.y)
            .take(1)
            .subscribe { [weak self] _ in
                guard let weakSelf = self else { return }
                weakSelf.bindDataToCollectionViewSection()
            }
    }
}

// 다음 예보 관련 메소드
extension DetailViewModel {
    
    func updateNextForecastListWithUserLocation() {
        let searchVM = SearchViewModel.shared
        
        if searchVM.userLocationRelay.value.count == 0 {
            searchVM.userLocationSubject
                .take(1)
                .subscribe { [weak self] userLocation in
                    guard let weakSelf = self else { return }
                    weakSelf.setupNextForecastList(
                        regIdForTemp: "11B10101",
                        regIdForSky: "11B00000",
                        latitude: userLocation[0],
                        longitude: userLocation[1]
                    )
                }
        } else {
            setupNextForecastList(
                regIdForTemp: "11B10101",
                regIdForSky: "11B00000",
                latitude: searchVM.userLocationRelay.value[0],
                longitude: searchVM.userLocationRelay.value[1]
            )
        }
        
    }
    
    // TODO: - 아래 메소드 사용 위치별 latitude, longitude 사용 여부 처리하기
    func setupNextForecastList(regIdForTemp: String, regIdForSky: String, latitude: Double = 0.0, longitude: Double = 0.0) {
        
        guard latitude > 0.0 && longitude > 0.0 else { return }
        let now = Date()

        let convertedXY = ConvertXY().convertGRID_GPS(mode: .TO_GRID, lat_X: latitude, lng_Y: longitude)
                
        Observable.combineLatest(
            DailyWeatherForecastService.shared.fetchDailyWeatherForecastInfosRx(
                nx: convertedXY.x,
                ny: convertedXY.y,
                base_time: now.getDateOfSelectedRegion.getBaseDateAndTimeForDailyWeatherForecast.baseTime
            ), DailyWeatherForecastService.shared.fetchDailyWeatherForecastInfosRx(
                nx: convertedXY.x,
                ny: convertedXY.y,
                base_time: now.convertBaseTime.getBaseDateAndTimeForDailyWeatherForecast.baseTime
            ), TemperatureForecastService.shared.fetchTemperatureForcastsRx(
                regId: regIdForTemp, // TODO: - 예보구역코드 구현하기
                tmFc: now.getTimeForecast
            ), SkyConditionForecastService.shared.fetchSkyConditionForcastsRx(
                regId: regIdForSky, // TODO: - 예보구역코드 구현하기
                tmFc: now.getTimeForecast
            )) { [weak self, now] dwfItems1, dwfItems2, tfItem, scItem -> [NextForecastItem] in
                guard let weakSelf = self else { return [] }
                let temperatureList = tfItem.getNextForecastTemperatureList()
                let skyConditionList = scItem.getNextForecastSkyCondtionList()
                let (nextForecastTemperatureListForThreeDaysFromToday, nextForecastSkyConditionListForThreeDaysFromToday) = weakSelf.getThreeDaysWeatherForcastListFromToday(now: now, dwfItems1: dwfItems1, dwfItems2: dwfItems2)
                
                var nextForecastList: [NextForecastItem] = []
                let count = min(temperatureList.count, skyConditionList.count) + 3
                for index in 0..<count {
                    var nextForecastItem = NextForecastItem()
                    nextForecastItem.date = now.addingTimeInterval(Double(86400 * index))

                    if index < 3 {
                        nextForecastItem.temperatureItem = nextForecastTemperatureListForThreeDaysFromToday[index]
                        nextForecastItem.skyConditionItem = nextForecastSkyConditionListForThreeDaysFromToday[index]
                    } else {
                        nextForecastItem.temperatureItem = temperatureList[index - 3]
                        nextForecastItem.skyConditionItem = skyConditionList[index - 3]
                    }
                    
                    nextForecastList.append(nextForecastItem)
                }
                print("fetch is done")
                return nextForecastList
            }
            .take(1)
            .bind(to: nextForecastListRelay)
    }
    
    private func getThreeDaysWeatherForcastListFromToday(now: Date, dwfItems1: DWFItems, dwfItems2: DWFItems) -> (
        nextForecastTemperatureListForThreeDaysFromToday: [NextForecastTemperatureItem],
        nextForecastSkyConditionListForThreeDaysFromToday: [NextForecastSkyConditionItem]
    ) {
        let lowAndHighTempForToday = dwfItems1.getHighAndLowTemperatureForToday(baseDate: now.getBaseDateAndTimeForDailyWeatherForecast.baseDate)
       var (nextForecastTemperatureListForThreeDaysFromToday, nextForecastSkyConditionListForThreeDaysFromToday) = dwfItems2.getTwoDaysWeatherForcastListSinceToday(now: now)
       
       nextForecastTemperatureListForThreeDaysFromToday.insert(
           NextForecastTemperatureItem(
               min: Int(lowAndHighTempForToday.lowestTemp),
               max: Int(Double(lowAndHighTempForToday.highestTemp) ?? 0.0)
           ),
           at: 0
       )
       
       nextForecastSkyConditionListForThreeDaysFromToday.insert(NextForecastSkyConditionItem(
               skyConditionAM: lowAndHighTempForToday.skyConditionAM,
               skyConditionPM: lowAndHighTempForToday.skyConditionPM
           ),
           at: 0
       )
        
        return (nextForecastTemperatureListForThreeDaysFromToday, nextForecastSkyConditionListForThreeDaysFromToday)
    }
}

// MARK: - TodayWeather DataSource 관련 메소드
extension DetailViewModel {
    func configureCollectionViewDataSource() -> RxCollectionViewSectionedReloadDataSource<TodayWeatherDataSection> {
        return RxCollectionViewSectionedReloadDataSource<TodayWeatherDataSection> { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayWeatherDetailCollectionViewCell.identifier, for: indexPath) as? TodayWeatherDetailCollectionViewCell else { return UICollectionViewCell() }
            cell.bind(item: item)
            if indexPath.row == 2 {
                cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
            }
            
            return cell
        } configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TodayWeatherDetailCollectionViewHeaderView.headerIdentifier, for: indexPath) as? TodayWeatherDetailCollectionViewHeaderView else { return UICollectionReusableView() }
            return header
        }
    }
    
    func bindDataToCollectionViewSection() {
        todayWeatherForecastListSubject
            .take(1)
            .bind { [weak self] todayWeatherForecastList in
                guard let weakSelf = self else { return }
                weakSelf.todayWeatherDataSectionListRelay.accept([
                    TodayWeatherDataSection(items: todayWeatherForecastList )
                ])
            }
    }
}
