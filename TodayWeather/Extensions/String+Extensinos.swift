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
}
