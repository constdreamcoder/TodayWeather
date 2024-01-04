//
//  MockDetailViewController.swift
//  TodayWeatherTests
//
//  Created by SUCHAN CHANG on 12/18/23.
//

@testable import TodayWeather
import Foundation

final class MockDetailViewController: DetailNavigator {
    var isCalledGotoSettings = false
    var isCalledGoBack = false
    
    func gotoSettings() {
        isCalledGotoSettings = true
    }
    
    func goBack() {
        isCalledGoBack = true
    }
}
