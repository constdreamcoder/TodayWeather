//
//  SearchedRegion.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/12/01.
//

import Foundation

struct SearchedRegion {
    var address: Address
    var addressForSearchNextForecast: String
    var lowestTemperatureForToday: Int
    var highestTemperatureForToday: Int
    var isSearchMode: Bool
}
