//
//  Date+Extensions.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/27.
//

import Foundation

extension Date {
    var getBaseDateAndTimeForRealtimeForecast: (baseDate: String, baseTime: String) {
        let dateForematter = DateFormatter()
        dateForematter.dateFormat = "yyyyMMdd HHmm"
        let tmp = dateForematter.string(from: self.addingTimeInterval(-3600)).split(separator: " ")
        return (String(tmp[0]), String(tmp[1]))
    }
    
    var getTodayDate: String {
        let dateForematter = DateFormatter()
        dateForematter.dateFormat = "오늘, M월 d일"
        return dateForematter.string(from: self)
    }
}
