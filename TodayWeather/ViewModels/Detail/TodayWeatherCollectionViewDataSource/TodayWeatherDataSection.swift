//
//  TodayWeatherDataSection.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/29.
//

import Foundation
import RxDataSources

struct TodayWeatherDataSection {
    var items: [TodayWeatherForecasts]
}

extension TodayWeatherDataSection: SectionModelType {
    typealias Item = TodayWeatherForecasts
    
    init(
        original: TodayWeatherDataSection,
        items: [TodayWeatherForecasts]
    ) {
        self = original
        self.items = items
    }
}
