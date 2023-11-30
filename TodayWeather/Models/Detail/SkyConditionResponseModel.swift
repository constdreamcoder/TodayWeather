//
//  SkyConditionResponseModel.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/30.
//

import Foundation

// MARK: - SkyConditionResponseModel
struct SkyConditionResponseModel: Codable {
    let response: SCResponse
}

// MARK: - Response
struct SCResponse: Codable {
    let header: SCHeader
    let body: SCBody
}

// MARK: - Body
struct SCBody: Codable {
    let dataType: String
    let items: SCItems
    let pageNo, numOfRows, totalCount: Int
}

// MARK: - Items
struct SCItems: Codable {
    let item: [SCItem]
}

// MARK: - Item
struct SCItem: Codable {
    let regID: String
    let rnSt3Am, rnSt3Pm, rnSt4Am, rnSt4Pm: Int
    let rnSt5Am, rnSt5Pm, rnSt6Am, rnSt6Pm: Int
    let rnSt7Am, rnSt7Pm, rnSt8, rnSt9: Int
    let rnSt10: Int
    let wf3Am, wf3Pm, wf4Am, wf4Pm: String
    let wf5Am, wf5Pm, wf6Am, wf6Pm: String
    let wf7Am, wf7Pm, wf8, wf9: String
    let wf10: String
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case regID = "regId"
        case rnSt3Am, rnSt3Pm, rnSt4Am, rnSt4Pm, rnSt5Am, rnSt5Pm, rnSt6Am, rnSt6Pm, rnSt7Am, rnSt7Pm, rnSt8, rnSt9, rnSt10, wf3Am, wf3Pm, wf4Am, wf4Pm, wf5Am, wf5Pm, wf6Am, wf6Pm, wf7Am, wf7Pm, wf8, wf9, wf10
    }
}

// TODO: - 알맞은 자리로 옮기기
struct NextForecastSkyConditionItem {
    var skyConditionAM: String?
    var skyConditionPM: String?
}

extension SCItem {
    private func toDictionary() -> [String: Any] {
        let jsonData = try! JSONEncoder().encode(self)
        let dictionary = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String: Any]
        return dictionary
    }
    
    func getNextForecastSkyCondtionList() -> [NextForecastSkyConditionItem] {
        var nextForecastSkyConditionList: [NextForecastSkyConditionItem] = []
        
        let SC_CODE = "wf"
        let dic = toDictionary()
        
        for num in 3...10 {
            var nextForecastSkyConditionItem = NextForecastSkyConditionItem()
            
            CodingKeys.allCases.forEach { codingKey in
                guard let skyCondition = dic[codingKey.rawValue] as? String else { return }
                
                let skyConditionKey = codingKey.rawValue
                
                if skyConditionKey == "\(SC_CODE)\(num)Am"
                    || (skyConditionKey.contains("\(SC_CODE)\(num)") && skyConditionKey != "\(SC_CODE)\(num)Pm") {
                    nextForecastSkyConditionItem.skyConditionAM = skyCondition
                }
                
                if skyConditionKey == "\(SC_CODE)\(num)Pm" {
                    nextForecastSkyConditionItem.skyConditionPM = skyCondition
                }
            }
            
            nextForecastSkyConditionList.append(nextForecastSkyConditionItem)
        }
        
        return nextForecastSkyConditionList
    }
}

// MARK: - Header
struct SCHeader: Codable {
    let resultCode, resultMsg: String
}
