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
    
    var todayWeatherForecastListObservable = BehaviorSubject<[TodayWeatherForecasts]>(value: [])
    
    // CollectionView Section 데이터를 담고 있는 Relay
    var todayWeatherDataSectionListObservable = BehaviorRelay<[TodayWeatherDataSection]>(value: [])
        
    var nextForcastTemperatureListSubject = BehaviorSubject<[NextForecastTemperatureItem]>(value: [])
    
    var nextForecastSkyConditionListSubject = BehaviorSubject<[NextForecastSkyConditionItem]>(value: [])
    
    var nextForecastListRelay = BehaviorRelay<[NextForecastItem]>(value: [])
    
    private var disposeBag = DisposeBag()
    
    private init() {
        TemperatureForecastService.shared.fetchTemperatureForcastsRx(
                regId: "11B10101", // TODO: - 예보구역코드 구현하기
                tmFc: Date().getTimeForecast
            )
            .map { tfItem in
                return tfItem.getNextForecastTemperatureList()
            }
            .take(1)
            .bind(to: nextForcastTemperatureListSubject)
        
        SkyConditionForecastService.shared.fetchSkyConditionForcastsRx(
                regId: "11B00000", // TODO: - 예보구역코드 구현하기
                tmFc: Date().getTimeForecast
            )
        .map { scItem in
            return scItem.getNextForecastSkyCondtionList()
        }
        .take(1)
        .bind(to: nextForecastSkyConditionListSubject)
        
        Observable.combineLatest(
            nextForcastTemperatureListSubject.asObservable(),
            nextForecastSkyConditionListSubject.asObservable()
        )
        .subscribe { [weak self] temperatureList, skyConditionList in
            guard let weakSelf = self else { return }
            var nextForecastList: [NextForecastItem] = []

            for index in 0..<min(temperatureList.count, skyConditionList.count) {
                var nextForecastItem = NextForecastItem()
                nextForecastItem.temperatureItem = temperatureList[index]
                nextForecastItem.skyConditionItem = skyConditionList[index]
                nextForecastList.append(nextForecastItem)
            }
            weakSelf.nextForecastListRelay.accept(nextForecastList)
        }
        .disposed(by: disposeBag)
    }
}

// MARK: - TodayWeather DataSource 관련 메소드
extension DetailViewModel {
    func configureCollectionViewDataSource() -> RxCollectionViewSectionedReloadDataSource<TodayWeatherDataSection> {
        return RxCollectionViewSectionedReloadDataSource { dataSource, collectionView, indexPath, item in
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
        todayWeatherDataSectionListObservable.accept([
            TodayWeatherDataSection(items: try! todayWeatherForecastListObservable.value())
        ])
    }
}
