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
import RxCocoa
import UIKit

struct NextForecastItem {
    var date: Date?
    var temperatureItem: NextForecastTemperatureItem?
    var skyConditionItem: NextForecastSkyConditionItem?
}

final class DetailViewModel: ViewModelType {
   
    struct Input {}
    
    struct Output {
        let todayWeatherList: Driver<[TodayWeatherDataSection]>
        let nextForecastList: Driver<[NextForecastItem]>
    }
    
    func transform(input: Input) -> Output {
        let todayWeatherList = todayWeatherDataSectionListRelay.asDriver()
        let nextForecastList = nextForecastListRelay.asDriver()
        
        return Output(
            todayWeatherList: todayWeatherList,
            nextForecastList: nextForecastList
        )
    }
        
    private let realtimeForcastService: RealtimeForcastService
    private let dailyWeatherForecastService: DailyWeatherForecastService
    private let temperatureForecastService: TemperatureForecastService
    private let skyConditionForecastService: SkyConditionForecastService
    
    private var todayWeatherDataSectionListRelay = BehaviorRelay<[TodayWeatherDataSection]>(value: [])
    private var nextForecastListRelay = BehaviorRelay<[NextForecastItem]>(value: [])
    
    private var dispostBag = DisposeBag()
    
    private var userLocation: ConvertXY.LatXLngY?

    init(
        realtimeForcastService: RealtimeForcastService,
        dailyWeatherForecastService: DailyWeatherForecastService,
        temperatureForecastService: TemperatureForecastService,
        skyConditionForecastService: SkyConditionForecastService,
        userLocation: ConvertXY.LatXLngY
    ) {
        self.realtimeForcastService = realtimeForcastService
        self.dailyWeatherForecastService = dailyWeatherForecastService
        self.temperatureForecastService = temperatureForecastService
        self.skyConditionForecastService = skyConditionForecastService
        
        self.userLocation = userLocation
    
        setupTodayWeatherList(nx: userLocation.x, ny: userLocation.y)
        setupNextForecastList(regIdForTemp: "11B10101", regIdForSky: "11B00000", latitude: userLocation.lat ,longitude: userLocation.lng)
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
    
    func setupTodayWeatherList(nx: Int, ny: Int) {
        realtimeForcastService.fetchRealtimeForecastsRx(nx: nx, ny: ny)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
            .map { items -> [TodayWeatherDataSection] in
                let todayWeatherForecastList = items.getTodayWeatherForecastList()
                return [
                    TodayWeatherDataSection(items: todayWeatherForecastList )
                ]
            }
            .bind(to: todayWeatherDataSectionListRelay)
            .disposed(by: dispostBag)
    }
}

// MARK: - 다음 예보 관련 메소드
extension DetailViewModel {
    // TODO: - 아래 메소드 사용 위치별 latitude, longitude 사용 여부 처리하기
    func setupNextForecastList(regIdForTemp: String, regIdForSky: String, latitude: Double = 0.0, longitude: Double = 0.0) {
        
        guard latitude > 0.0 && longitude > 0.0 else { return }
        let now = Date()
        
        let convertedXY = ConvertXY().convertGRID_GPS(mode: .TO_GRID, lat_X: latitude, lng_Y: longitude)
                
        Observable.combineLatest(
            dailyWeatherForecastService.fetchDailyWeatherForecastInfosRx(
                nx: convertedXY.x,
                ny: convertedXY.y,
                base_time: now.getDateOfSelectedRegion.getBaseDateAndTimeForDailyWeatherForecast.baseTime
            ), dailyWeatherForecastService.fetchDailyWeatherForecastInfosRx(
                nx: convertedXY.x,
                ny: convertedXY.y,
                base_time: now.convertBaseTime.getBaseDateAndTimeForDailyWeatherForecast.baseTime
            ), temperatureForecastService.fetchTemperatureForcastsRx(
                regId: regIdForTemp, // TODO: - 예보구역코드 구현하기
                tmFc: now.getTimeForecast
            ), skyConditionForecastService.fetchSkyConditionForcastsRx(
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
            .bind(to: nextForecastListRelay)
            .disposed(by: dispostBag)
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
