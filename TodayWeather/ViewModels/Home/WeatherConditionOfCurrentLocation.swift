//
//  WeatherConditionOfCurrentLocation.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/28.
//

import Foundation

struct WeatherConditionOfCurrentLocation {
    let todayDate: Date
    let temperature: Int // TODO: - 나중에 바꾸기
    let windSpeed: Float
    let humidity: Int
    let skyCondition: Items.SkyCondition
}
