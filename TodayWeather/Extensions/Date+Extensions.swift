//
//  Date+Extensions.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/27.
//

import Foundation

extension Date {
    // TODO: - getBaseDateAndTimeForRealtimeForecast와 getBaseDateAndTimeForDailyWeatherForecast 합치기
    var getBaseDateAndTimeForRealtimeForecast: (baseDate: String, baseTime: String) {
        let dateForematter = DateFormatter()
        dateForematter.dateFormat = "yyyyMMdd HHmm"
        dateForematter.locale = Locale(identifier: "ko_KR")
        let tmp = dateForematter.string(from: self.addingTimeInterval(-3600)).split(separator: " ")
        return (String(tmp[0]), String(tmp[1]))
    }
    
    var getBaseDateAndTimeForDailyWeatherForecast: (baseDate: String, baseTime: String) {
        let dateForematter = DateFormatter()
        dateForematter.dateFormat = "yyyyMMdd HHmm"
        dateForematter.locale = Locale(identifier: "ko_KR")
        let tmp = dateForematter.string(from: self).split(separator: " ")
        return (String(tmp[0]), String(tmp[1]))
    }
    
    var convertBaseTime: Date {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour], from: self)
        let hour = dateComponents.hour!
                
        if hour >= 2 && hour < 5 {
            dateComponents.hour = 2
        } else if hour >= 5 && hour < 8 {
            dateComponents.hour = 5
        } else if hour >= 8 && hour < 11 {
            dateComponents.hour = 8
        } else if hour >= 11 && hour < 14 {
            dateComponents.hour = 11
        } else if hour >= 14 && hour < 17 {
            dateComponents.hour = 14
        } else if hour >= 17 && hour < 20 {
            dateComponents.hour = 17
        } else if hour >= 20 && hour < 23 {
            dateComponents.hour = 20
        } else {
            dateComponents.hour = 23
        }
        return calendar.date(from: dateComponents)!
    }
    
    var getTodayDate: String {
        let dateForematter = DateFormatter()
        dateForematter.locale = Locale(identifier: "ko_KR")
        dateForematter.dateFormat = "M월 d일(E)"
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
    
    var getDateOfSelectedRegion: Date {
        let now = self
        let calendar = Calendar.current
        var dateComponentsForNow = calendar.dateComponents([.year, .month, .day, .hour], from: now)
        let hour = dateComponentsForNow.hour!
        
        var convertedDate: Date!
        
        if hour >= 0 && hour < 2 {
            let yesterday = now.addingTimeInterval(-86400)
            var dateComponentsForYesterday = calendar.dateComponents([.year, .month, .day, .hour], from: yesterday)
            dateComponentsForYesterday.hour = 23
            convertedDate = calendar.date(from: dateComponentsForYesterday)
        } else if hour >= 2 && hour < 5 {
            dateComponentsForNow.hour = 2
            convertedDate = calendar.date(from: dateComponentsForNow)
        } else {
            dateComponentsForNow.hour = 5
            convertedDate = calendar.date(from: dateComponentsForNow)
        }
        return convertedDate
    }
}
