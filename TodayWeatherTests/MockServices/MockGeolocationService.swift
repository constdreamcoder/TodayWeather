//
//  MockGeolocationService.swift
//  TodayWeatherTests
//
//  Created by SUCHAN CHANG on 12/23/23.
//

@testable import TodayWeather
import Foundation
import RxSwift

final class MockGeolocationService: GeolocationServiceModel {
    var isCalledFetchGeolocationRx = false
    var error: Error?

    func fetchGeolocationRx(query: String?) -> Observable<[Address]> {
        return Observable.create { [weak self] emitter in
            guard let weakSelf = self else { return Disposables.create() }
            weakSelf.isCalledFetchGeolocationRx = true

            if weakSelf.error == nil {
                emitter.onNext([])
                emitter.onCompleted()
            } else {
                emitter.onError(weakSelf.error!)
            }
            return Disposables.create()
        }
    }
}
