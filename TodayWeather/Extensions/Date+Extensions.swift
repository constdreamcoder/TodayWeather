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
        dateForematter.locale = Locale(identifier: "ko_kr")
        let tmp = dateForematter.string(from: self.addingTimeInterval(-3600)).split(separator: " ")
        return (String(tmp[0]), String(tmp[1]))
    }
    
    var getTodayDate: String {
        let dateForematter = DateFormatter()
        dateForematter.dateFormat = "M월 d일"
        return dateForematter.string(from: self)
    }
    
    var getTimeForecast: String {
        let calendar = Calendar.current
        
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        
        let dateForematter = DateFormatter()
        dateForematter.dateFormat = "yyyyMMddHHmm"
        
        var customizedDate: Date?
        
        if dateComponents.hour! >= 6 && dateComponents.hour! < 18 {
            dateComponents.hour = 6
            dateComponents.minute = 0
        } else if dateComponents.hour! >= 18 {
            dateComponents.hour = 18
            dateComponents.minute = 0
        } else if dateComponents.hour! >= 0 && dateComponents.hour! < 6 {
            dateComponents.hour = 18
            dateComponents.minute = 0
            customizedDate = calendar.date(from: dateComponents)
            return dateForematter.string(from: (customizedDate!.addingTimeInterval(-86400)))
        }
        
        customizedDate = calendar.date(from: dateComponents)
        return dateForematter.string(from: customizedDate!)
    }
}
