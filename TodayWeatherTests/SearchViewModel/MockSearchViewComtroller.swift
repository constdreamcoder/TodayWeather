//
//  MockSearchViewComtroller.swift
//  TodayWeatherTests
//
//  Created by SUCHAN CHANG on 12/23/23.
//

@testable import TodayWeather
import Foundation

final class MockSearchViewComtroller: SearchUserEvent {
    var isCalledShowTableView = false
    var isCalledGoBackToHome = false
    var isCalledResignSearchBarFromFirstResponder = false
    var isCalledShowInfoWindowOnMarker = false
    var isCalledMoveToUser = false
    
    func showTableView(isHidden: Bool) {
        isCalledShowTableView = true
    }
    
    func goBackToHome() {
        isCalledGoBackToHome = true
    }
    
    func resignSearchBarFromFirstResponder() {
        isCalledResignSearchBarFromFirstResponder = true
    }
    
    func showInfoWindowOnMarker(latitude: Double, longitude: Double, address: Address, addressForSearchNextForecast: String) {
        isCalledShowInfoWindowOnMarker = true
    }
    
    func moveToUser() {
        isCalledMoveToUser = true
    }
}
