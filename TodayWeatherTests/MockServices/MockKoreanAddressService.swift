//
//  MockKoreanAddressService.swift
//  TodayWeatherTests
//
//  Created by SUCHAN CHANG on 12/18/23.
//

@testable import TodayWeather
import Foundation
import RxSwift

final class MockKoreanAddressService: KoreanAddressServiceModel {
    var isCalledConvertLatAndLngToKoreanAddressRx = false
    var error: Error?

    func convertLatAndLngToKoreanAddressRx(latitude: Double, longitude: Double) -> Observable<Region> {
        
        return Observable.create { [weak self] emitter in
            guard let weakSelf = self else { return Disposables.create() }
            weakSelf.isCalledConvertLatAndLngToKoreanAddressRx = true
            
            if weakSelf.error == nil {
                // TODO: - 테스트용 Mock 데이터 생성하기
//                emitter.onNext(Region())
                emitter.onCompleted()
            } else {
                emitter.onError(weakSelf.error!)
            }
            return Disposables.create()
        }
    }
    
}
