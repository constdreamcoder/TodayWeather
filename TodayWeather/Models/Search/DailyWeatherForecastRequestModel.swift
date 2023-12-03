//
//  DailyWeatherForecastRequestModel.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/12/03.
//

import Foundation

struct DailyWeatherForecastRequestModel: Codable {
    var pageNo: Int
    var numOfRows: Int
    var dataType: String = "JSON"
    var base_date: String
    var base_time: String
    var nx: Int
    var ny: Int
    
    init(
        pageNo: Int = 1,
        numOfRows: Int = 1000,
        dataType: String = "JSON",
        base_date: String = "20231203",
        base_time: String = "0500",
        nx: Int = 57,
        ny: Int = 126
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
