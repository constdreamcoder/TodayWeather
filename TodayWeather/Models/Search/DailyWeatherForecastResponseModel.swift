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
    // TODO: - 성능 개선하기
    func getHighAndLowTemperatureForToday(baseDate: String) -> (lowestTemp: String, highestTemp: String, skyConditionAM: String, skyConditionPM: String) {
        var lowestTemperature: String = "0.0"
        var highestTemperature: String = "0.0"
        
        var skyConditionAM: String = "0"
        var skyConditionPM: String = "0"
        
        item.forEach { dwfItem in
            if dwfItem.fcstDate == baseDate {
                if dwfItem.category == .tmp && dwfItem.fcstTime == "0600" {
                    lowestTemperature = dwfItem.fcstValue
                }
                
                if dwfItem.category == .tmx && dwfItem.fcstTime == "1500" {
                    highestTemperature = dwfItem.fcstValue
                }
                
                if dwfItem.category == .sky && dwfItem.fcstTime == "0900" {
                    skyConditionAM = dwfItem.fcstValue
                }
                
                if dwfItem.category == .sky && dwfItem.fcstTime == "1600" {
                    skyConditionPM = dwfItem.fcstValue
                }
            }
        }
        
        return (lowestTemperature, highestTemperature, skyConditionAM, skyConditionPM)
    }
    
    func getTwoDaysWeatherForcastListSinceToday(
        now: Date
    ) -> (
        nextForecastTemperatureListForThreeDaysFromToday: [NextForecastTemperatureItem],
        nextForecastSkyConditionListForThreeDaysFromToday: [NextForecastSkyConditionItem]
    ) {
        var nextForecastTemperatureListForThreeDaysFromToday: [NextForecastTemperatureItem] = []
        var nextForecastSkyConditionListForThreeDaysFromToday: [NextForecastSkyConditionItem] = []

        //반환 타입([NextForecastTemperatureItem], [NextForecastSkyConditionItem])
        var nextForecastTemperatureAfterOnedaysItem: NextForecastTemperatureItem? = .init()
        var nextForecastTemperatureAfterTwodaysItem: NextForecastTemperatureItem? = .init()
           
        var nextForecastSkyConditionAfterOnedaysItem: NextForecastSkyConditionItem? = .init()
        var nextForecastSkyConditionAfterTwodaysItem: NextForecastSkyConditionItem? = .init()
        
        item.forEach { dwfItem in
            // 오전 5시 이후
            if dwfItem.baseTime.splitTwoPrefixAndConvertIntoInt >= "0500".splitTwoPrefixAndConvertIntoInt {
                // 내일 예보
                if dwfItem.fcstDate.converToInt == now.addingTimeInterval(86400).getBaseDateAndTimeForDailyWeatherForecast.baseDate.converToInt {
                    // 내일 최저 온도
                    if dwfItem.category == .tmn && dwfItem.fcstTime == "0600" {
                        nextForecastTemperatureAfterOnedaysItem?.min = Int(Double(dwfItem.fcstValue) ?? 0.0)
                    }
                    // 내일 최고 온도
                    if dwfItem.category == .tmx && dwfItem.fcstTime == "1500" {
                        nextForecastTemperatureAfterOnedaysItem?.max = Int(Double(dwfItem.fcstValue) ?? 0.0)
                    }
                    
                    if nextForecastTemperatureAfterOnedaysItem?.min != nil
                        && nextForecastTemperatureAfterOnedaysItem?.max != nil {
                        nextForecastTemperatureListForThreeDaysFromToday.append(nextForecastTemperatureAfterOnedaysItem!)
                        nextForecastTemperatureAfterOnedaysItem = nil
                    }
                    
                    // 내일 오전 하늘 상태
                    if dwfItem.category == .sky && dwfItem.fcstTime == "0900" {
                        nextForecastSkyConditionAfterOnedaysItem?.skyConditionAM = dwfItem.fcstValue
                    }
                    // 내일 오후 하늘 상태
                    if dwfItem.category == .sky && dwfItem.fcstTime == "1600" {
                        nextForecastSkyConditionAfterOnedaysItem?.skyConditionPM = dwfItem.fcstValue
                    }
                    
                    if nextForecastSkyConditionAfterOnedaysItem?.skyConditionAM != nil
                        && nextForecastSkyConditionAfterOnedaysItem?.skyConditionPM != nil {
                        nextForecastSkyConditionListForThreeDaysFromToday.append(nextForecastSkyConditionAfterOnedaysItem!)
                        nextForecastSkyConditionAfterOnedaysItem = nil
                    }
                }
                
                // 모레 예보
                if dwfItem.fcstDate.converToInt == now.addingTimeInterval(86400 * 2).getBaseDateAndTimeForDailyWeatherForecast.baseDate.converToInt {
                    // 내일 최저 온도
                    if dwfItem.category == .tmn && dwfItem.fcstTime == "0600" {
                        nextForecastTemperatureAfterTwodaysItem?.min = Int(Double(dwfItem.fcstValue) ?? 0.0)
                    }
                    // 내일 최고 온도
                    if dwfItem.category == .tmx && dwfItem.fcstTime == "1500" {
                        nextForecastTemperatureAfterTwodaysItem?.max = Int(Double(dwfItem.fcstValue) ?? 0.0)
                    }
                    if nextForecastTemperatureAfterTwodaysItem?.min != nil
                        && nextForecastTemperatureAfterTwodaysItem?.max != nil {
                        nextForecastTemperatureListForThreeDaysFromToday.append(nextForecastTemperatureAfterTwodaysItem!)
                        nextForecastTemperatureAfterTwodaysItem = nil
                    }
                    
                    // 모레 오전 하늘 상태
                    if dwfItem.category == .sky && dwfItem.fcstTime == "0900" {
                        nextForecastSkyConditionAfterTwodaysItem?.skyConditionAM = dwfItem.fcstValue
                    }
                    // 모레 오후 하늘 상태
                    if dwfItem.category == .sky && dwfItem.fcstTime == "1600" {
                        nextForecastSkyConditionAfterTwodaysItem?.skyConditionPM = dwfItem.fcstValue
                    }
                    
                    if nextForecastSkyConditionAfterTwodaysItem?.skyConditionAM != nil
                        && nextForecastSkyConditionAfterTwodaysItem?.skyConditionPM != nil {
                        nextForecastSkyConditionListForThreeDaysFromToday.append(nextForecastSkyConditionAfterTwodaysItem!)
                        nextForecastSkyConditionAfterTwodaysItem = nil
                    }
                }
    
                
            }
            // forEeach 문 끝
        }
     
        return (nextForecastTemperatureListForThreeDaysFromToday, nextForecastSkyConditionListForThreeDaysFromToday)
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
