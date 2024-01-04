//
//  MockSkyConditionForecastService.swift
//  TodayWeatherTests
//
//  Created by SUCHAN CHANG on 12/18/23.
//

@testable import TodayWeather
import Foundation
import RxSwift

final class MockSkyConditionForecastService: SkyConditionForecastServiceModel {
    var isCalledFetchSkyConditionForcastsRx = false
    var error: Error?
    
    func fetchSkyConditionForcastsRx(regId: String, tmFc: String) -> Observable<SCItem> {
        return Observable.create { [weak self] emitter in
            guard let weakSelf = self else { return Disposables.create() }
            weakSelf.isCalledFetchSkyConditionForcastsRx = true
            
            if weakSelf.error == nil {
                // TODO: - 테스트용 Mock 데이터 생성하기
                //                emitter.onNext(SCItem())
                emitter.onCompleted()
            } else {
                emitter.onError(weakSelf.error!)
            }
            return Disposables.create()
        }
    }
}
