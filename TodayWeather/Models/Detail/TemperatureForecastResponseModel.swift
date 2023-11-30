//
//  TemperatureForecastResponseModel.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/29.
//

import Foundation

// MARK: - TemperatureForecastResponseModel
struct TemperatureForecastResponseModel: Codable {
    let response: TFResponse
}

// MARK: - Response
struct TFResponse: Codable {
    let header: TFHeader
    let body: TFBody
}

// MARK: - Body
struct TFBody: Codable {
    let dataType: String
    let items: TFItems
    let pageNo, numOfRows, totalCount: Int
}

// MARK: - Items
struct TFItems: Codable {
    let item: [TFItem]
}

// MARK: - Item
struct TFItem: Codable {
    let regID: String
    let taMin3, taMin3Low, taMin3High, taMax3: Int
    let taMax3Low, taMax3High, taMin4, taMin4Low: Int
    let taMin4High, taMax4, taMax4Low, taMax4High: Int
    let taMin5, taMin5Low, taMin5High, taMax5: Int
    let taMax5Low, taMax5High, taMin6, taMin6Low: Int
    let taMin6High, taMax6, taMax6Low, taMax6High: Int
    let taMin7, taMin7Low, taMin7High, taMax7: Int
    let taMax7Low, taMax7High, taMin8, taMin8Low: Int
    let taMin8High, taMax8, taMax8Low, taMax8High: Int
    let taMin9, taMin9Low, taMin9High, taMax9: Int
    let taMax9Low, taMax9High, taMin10, taMin10Low: Int
    let taMin10High, taMax10, taMax10Low, taMax10High: Int

    enum CodingKeys: String, CodingKey, CaseIterable {
        case regID = "regId"
        case taMin3, taMin3Low, taMin3High, taMax3, taMax3Low, taMax3High, taMin4, taMin4Low, taMin4High, taMax4, taMax4Low, taMax4High, taMin5, taMin5Low, taMin5High, taMax5, taMax5Low, taMax5High, taMin6, taMin6Low, taMin6High, taMax6, taMax6Low, taMax6High, taMin7, taMin7Low, taMin7High, taMax7, taMax7Low, taMax7High, taMin8, taMin8Low, taMin8High, taMax8, taMax8Low, taMax8High, taMin9, taMin9Low, taMin9High, taMax9, taMax9Low, taMax9High, taMin10, taMin10Low, taMin10High, taMax10, taMax10Low, taMax10High
    }
}

// TODO: - 알맞은 자리로 옮기기
struct NextForecastTemperatureItem {
    var min: Int?
    var max: Int?
}

extension TFItem {
    private func toDictionary() -> [String: Any] {
        let jsonData = try! JSONEncoder().encode(self)
        let dictionary = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String: Any]
        return dictionary
    }
    
    func getNextForecastTemperatureList() -> [NextForecastTemperatureItem] {
        var nextForecastTemperatureList: [NextForecastTemperatureItem] = []

        let MIN_CODE = "taMin"
        let MAX_CODE = "taMax"
        let dic = toDictionary()
        
        for num in 3...10 {
            var nextForecastTemperatureItem = NextForecastTemperatureItem()
            
            CodingKeys.allCases.forEach { codingKey in
                if nextForecastTemperatureItem.min != nil
                    && nextForecastTemperatureItem.max != nil {
                    return
                }
                
                guard let temperature = dic[codingKey.rawValue] as? Int else { return }
                
                if codingKey.rawValue == "\(MIN_CODE)\(num)" {
                    nextForecastTemperatureItem.min = temperature
                }
                
                if codingKey.rawValue == "\(MAX_CODE)\(num)" {
                    nextForecastTemperatureItem.max = temperature
                }
            }
            
            nextForecastTemperatureList.append(nextForecastTemperatureItem)
        }
        
        return nextForecastTemperatureList
    }
}

// MARK: - Header
struct TFHeader: Codable {
    let resultCode, resultMsg: String
}


