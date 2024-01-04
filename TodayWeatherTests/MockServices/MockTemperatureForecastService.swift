//
//  MockTemperatureForecastService.swift
//  TodayWeatherTests
//
//  Created by SUCHAN CHANG on 12/18/23.
//

@testable import TodayWeather
import Foundation
import RxSwift

final class MockTemperatureForecastService: TemperatureForecastServiceModel {
    var isCalledFetchTemperatureForcastsRx = false
    var error: Error?
    
    func fetchTemperatureForcastsRx(regId: String, tmFc: String) -> Observable<TFItem> {
        return Observable.create { [weak self] emitter in
            guard let weakSelf = self else { return Disposables.create() }
            weakSelf.isCalledFetchTemperatureForcastsRx = true

            if weakSelf.error == nil {
                // TODO: - 테스트용 Mock 데이터 생성하기
//                emitter.onNext(TFItem())
                emitter.onCompleted()
            } else {
                emitter.onError(weakSelf.error!)
            }
            return Disposables.create()
        }
    }
}
