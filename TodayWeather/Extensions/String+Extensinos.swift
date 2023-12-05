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
}
