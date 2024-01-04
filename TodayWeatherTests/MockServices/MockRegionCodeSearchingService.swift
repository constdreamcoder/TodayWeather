//
//  MockRegionCodeSearchingService.swift
//  TodayWeatherTests
//
//  Created by SUCHAN CHANG on 12/18/23.
//

@testable import TodayWeather
import Foundation
import RxSwift

final class MockRegionCodeSearchingService: RegionCodeSearchingServiceModel {
    var isCalledSearchRegionCodeForTemperature = false
    var isCalledSearchRegionCodeForSkyCondition = false
    
    func searchRegionCodeForTemperature(koreanFullAdress: String) -> String {
        isCalledSearchRegionCodeForTemperature = true
        
        return "11B10101"
    }
    
    func searchRegionCodeForSkyCondition(koreanFullAdress: String) -> String {
        isCalledSearchRegionCodeForSkyCondition = true
        
        return "11B00000"
    }
}
