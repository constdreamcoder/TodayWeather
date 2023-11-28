//
//  WeatherConditionOfCurrentLocation.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/28.
//

import Foundation

struct WeatherConditionOfCurrentLocation {
    var todayDate: Date
    var temperature: Int
    var windSpeed: Float
    var humidity: Int
    var skyCondition: Items.SkyCondition
}
