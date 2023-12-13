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
    
    init(
        todayDate: Date = Date(),
        temperature: Int = 0,
        windSpeed: Float = 0.0,
        humidity: Int = 0,
        skyCondition: Items.SkyCondition = .clear
    ) {
        self.todayDate = todayDate
        self.temperature = temperature
        self.windSpeed = windSpeed
        self.humidity = humidity
        self.skyCondition = skyCondition
    }
}
