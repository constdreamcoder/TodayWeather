//
//  String+Extensinos.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/29.
//

import Foundation

extension String {
    var addColonInTheMiddle: String {
        var baseTimeString = self
        let index = baseTimeString.index(baseTimeString.startIndex, offsetBy: 2)
        baseTimeString.insert(":", at: index)
        return baseTimeString
    }
    
    var splitTwoPrefixAndConvertIntoInt: Int {
        return Int(String(self.prefix(2)))!
    }
    
    var converToInt: Int {
        return Int(self) ?? 0
    }
    
    var convertToSkyCondition: Items.SkyCondition {
        if self == "흐림" {
            return .cloudy
        } else if self == "구름많음" {
            return .mostlyCloudy
        } else { // self == "맑음" 일 경우
            return .clear
        }
    }
    
    func hasCommonSubstring(_ str: String) -> Bool {
        // 문자열을 각 문자로 분해
        let set1 = Set(self)
        let set2 = Set(str)
        
        // 교집합을 구하고 공통된 문자가 있는지 확인
        let commonSet = set1.intersection(set2)
        
        return !commonSet.isEmpty
    }

}
