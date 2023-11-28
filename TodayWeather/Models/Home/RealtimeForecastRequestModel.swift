//
//  RealtimeForecastRequestModel.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/27.
//

import Foundation

struct RealtimeForecastRequestModel: Codable {
    var pageNo: Int
    var numOfRows: Int
    var dataType: String = "JSON"
    var base_date: String
    var base_time: String
    var nx: Int
    var ny: Int
    
    init(
        pageNo: Int = 1,
        numOfRows: Int = 60,
        dataType: String = "JSON",
        base_date: String = "20231127",
        base_time: String = "2230",
        nx: Int = 60,
        ny: Int = 127
    ) {
        self.pageNo = pageNo
        self.numOfRows = numOfRows
        self.dataType = dataType
        self.base_date = base_date
        self.base_time = base_time
        self.nx = nx
        self.ny = ny
    }
    
}

