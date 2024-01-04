//
//  MockDailyWeatherForecastService.swift
//  TodayWeatherTests
//
//  Created by SUCHAN CHANG on 12/18/23.
//

@testable import TodayWeather
import Foundation
import RxSwift

final class MockDailyWeatherForecastService: DailyWeatherForecastServiceModel {
    var isCalledFetchDailyWeatherForecastInfosRx = false
    var error: Error?
    
    func fetchDailyWeatherForecastInfosRx(nx: Int, ny: Int, base_time: String) -> Observable<DWFItems> {
        return Observable.create { [weak self] emitter in
            guard let weakSelf = self else { return Disposables.create() }
            weakSelf.isCalledFetchDailyWeatherForecastInfosRx = true

            if weakSelf.error == nil {
                // TODO: - 테스트용 Mock 데이터 생성하기
                emitter.onNext(DWFItems(item: []))
                emitter.onCompleted()
            } else {
                emitter.onError(weakSelf.error!)
            }
            return Disposables.create()
        }
    }
}
