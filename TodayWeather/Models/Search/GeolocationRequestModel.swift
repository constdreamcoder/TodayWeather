//
//  GeolocationRequestModel.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/12/01.
//

import Foundation

struct GeolocationRequestModel: Codable {
    var query: String?
    
    init(
        query: String = "서울시 강서구 내발산"
    ) {
        self.query = query
    }
}
