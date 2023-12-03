//
//  DailyWeatherForecastResponseModel.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/12/03.
//

import Foundation

// MARK: - DailyWeatherForecastResponseModel
struct DailyWeatherForecastResponseModel: Codable {
    let response: DWFResponse
}

// MARK: - Response
struct DWFResponse: Codable {
    let header: DWFHeader
    let body: DWFBody
}

// MARK: - Body
struct DWFBody: Codable {
    let dataType: String
    let items: DWFItems
    let pageNo, numOfRows, totalCount: Int
}

// MARK: - Items
struct DWFItems: Codable {
    let item: [DWFItem]
}

extension DWFItems {
    func getHighAndLowTemperatureForToday(today: String) -> (lowestTemp: String, highestTemp: String) {
        guard let lowestTemperature = item.first(where: { $0.category == .tmp && $0.fcstDate == today && $0.fcstTime == "0600" })?.fcstValue,
              let highestTemperature = item.first(where: { $0.category == .tmx && $0.fcstDate == today && $0.fcstTime == "1500" })?.fcstValue else {
            return ("0.0", "0.0")
        }
        
        return (lowestTemperature, highestTemperature)
    }
}

// MARK: - Item
struct DWFItem: Codable {
    let baseDate, baseTime: String
    let category: Category
    let fcstDate, fcstTime, fcstValue: String
    let nx, ny: Int
}

enum Category: String, Codable {
    case pcp = "PCP"
    case pop = "POP"
    case pty = "PTY"
    case reh = "REH"
    case sky = "SKY"
    case sno = "SNO"
    case tmn = "TMN"
    case tmp = "TMP"
    case tmx = "TMX"
    case uuu = "UUU"
    case vec = "VEC"
    case vvv = "VVV"
    case wav = "WAV"
    case wsd = "WSD"
}

// MARK: - Header
struct DWFHeader: Codable {
    let resultCode, resultMsg: String
}
