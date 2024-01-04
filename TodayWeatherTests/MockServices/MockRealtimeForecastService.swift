//
//  MockRealtimeForecastService.swift
//  TodayWeatherTests
//
//  Created by SUCHAN CHANG on 12/18/23.
//

@testable import TodayWeather
import Foundation
import RxSwift

final class MockRealtimeForecastService: RealtimeForecastServiceModel {
    var isCalledFetchRealtimeForecastsRx = false
    var error: Error?
    
    func fetchRealtimeForecastsRx(nx: Int, ny: Int) -> Observable<Items> {
        return Observable.create { [weak self] emitter in
            guard let weakSelf = self else { return Disposables.create() }
            weakSelf.isCalledFetchRealtimeForecastsRx = true
            if weakSelf.error == nil {
                // TODO: - 테스트용 Mock 데이터 생성하기
                emitter.onNext(Items(item: []))
                emitter.onCompleted()
            } else {
                emitter.onError(weakSelf.error!)
            }
            
            return Disposables.create()
        }
    }
    
}
