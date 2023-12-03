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

struct NextForecastItem {
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
    func resetTodayWeatherForecastList(latitude: Double, longitude: Double) {
        print(latitude, longitude)
        let convertedXY = ConvertXY().convertGRID_GPS(mode: .TO_GRID, lat_X: latitude, lng_Y: longitude)
        print(convertedXY.x, convertedXY.y)
        HomeViewModel.shared.getWeatherConditionOfCurrentLocationObservable(nx: convertedXY.x, ny: convertedXY.y)
            .take(1)
            .subscribe { _ in
                self.bindDataToCollectionViewSection()
            }
    }
}

// 다음 예보 관련 메소드
extension DetailViewModel {
    func setupNextForecastList(regIdForTemp: String, regIdForSky: String) {
        print(regIdForTemp)
        Observable.combineLatest(
            TemperatureForecastService.shared.fetchTemperatureForcastsRx(
                regId: regIdForTemp, // TODO: - 예보구역코드 구현하기
                tmFc: Date().getTimeForecast
            ), SkyConditionForecastService.shared.fetchSkyConditionForcastsRx(
                regId: regIdForSky, // TODO: - 예보구역코드 구현하기
                tmFc: Date().getTimeForecast
            )) { tfItem, scItem -> [NextForecastItem] in
                
                let temperatureList = tfItem.getNextForecastTemperatureList()
                let skyConditionList = scItem.getNextForecastSkyCondtionList()
                
                var nextForecastList: [NextForecastItem] = []
                
                for index in 0..<min(temperatureList.count, skyConditionList.count) {
                    var nextForecastItem = NextForecastItem()
                    nextForecastItem.temperatureItem = temperatureList[index]
                    nextForecastItem.skyConditionItem = skyConditionList[index]
                    nextForecastList.append(nextForecastItem)
                }
                return nextForecastList
            }
            .take(1)
            .bind(to: nextForecastListRelay)
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
