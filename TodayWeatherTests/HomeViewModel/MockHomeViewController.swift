//
//  MockHomeViewController.swift
//  TodayWeatherTests
//
//  Created by SUCHAN CHANG on 12/18/23.
//

@testable import TodayWeather
import Foundation

final class MockHomeViewController: HomeNavigator {
    var isCalledGotoSearchVC = false
    var isCalledGotoDetailVC = false

    func gotoSearchVC() {
        isCalledGotoSearchVC = true
    }
    
    func gotoDetailVC() {
        isCalledGotoDetailVC = true
    }
}
