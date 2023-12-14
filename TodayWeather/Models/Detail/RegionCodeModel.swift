//
//  RegionCodeModel.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 12/13/23.
//

import Foundation

struct RegionCodeModel: Codable {
    let regName: String
    let regId: String
    
    enum CodingKeys: String, CodingKey {
        case regName = "RegName"
        case regId = "RegId"
    }
}
