//
//  Int+Extensions.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/12/05.
//

import Foundation

extension Int {
    var convertToSkyCondition: Items.SkyCondition {
        return Items.SkyCondition(rawValue: self) ?? .clear
    }
}
