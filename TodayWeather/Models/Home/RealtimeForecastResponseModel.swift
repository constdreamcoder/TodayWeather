//
//  RealtimeForecastResponseModel.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/27.
//

import Foundation


// MARK: - Welcome
struct RealtimeForecastResponseModel: Codable {
    let response: Response
}

// MARK: - Response
struct Response: Codable {
    let header: Header
    let body: Body
}

// MARK: - Body
struct Body: Codable {
    let dataType: String
    let items: Items
    let pageNo, numOfRows, totalCount: Int
}

// MARK: - Items
struct Items: Codable {
    let item: [Item]
}

// MARK: - Item
struct Item: Codable {
    let baseDate, baseTime, category, fcstDate: String
    let fcstTime, fcstValue: String
    let nx, ny: Int
}

// MARK: - Header
struct Header: Codable {
    let resultCode, resultMsg: String
}

extension Items {
    func getTodayWeatherForecastList() -> [TodayWeatherForecasts] {
        var todayWeatherForecastList: [TodayWeatherForecasts] = []
        
        // 온도, 예보시간 추가
        item.forEach { item in
            if item.category == Category.T1H.rawValue {
                var todayWeatherForecast = TodayWeatherForecasts(temperature: "", skyCondition: .sunny, time: "00:00")
                todayWeatherForecast.temperature = item.fcstValue
                todayWeatherForecast.time = item.fcstTime.addColonInTheMiddle
                todayWeatherForecastList.append(todayWeatherForecast)
            }
        }
        
        // 하늘상태 추가
        var count = 0
        item.forEach { item in
            if item.category == Category.SKY.rawValue {
                todayWeatherForecastList[count].skyCondition = convertStringToSkyCondition(item)
                count += 1
            }
        }
        
        return todayWeatherForecastList
    }
    
    func getCurrentWeatherConditionInfos() -> WeatherConditionOfCurrentLocation {
        // TODO: - 검색 속도 향상 시키기
        guard let currentTemperatureItem = item.first(where: { $0.category == Category.T1H.rawValue }),
              let currentWindConditionItem = item.first(where: { $0.category == Category.WSD.rawValue }),
              let currentHumidityItem = item.first(where: { $0.category == Category.REH.rawValue }),
              let currentSkyConditionItem = item.first(where: { $0.category == Category.SKY.rawValue })
        else {
            print("네트워크 오류가 발생하였습니다!")
            return WeatherConditionOfCurrentLocation(todayDate: .now, temperature: 0, windSpeed: 0, humidity: 0, skyCondition: .sunny)
        }
//        print("현재온도: \(String(describing: currentTemperature))")
//        print("현재풍속: \(String(describing: currentWindCondition))")
//        print("현재습도: \(String(describing: currentHumidity))")
//        print("현재 하늘 상태: \(currentSkyConditionItem)")
        let currentSkyCondition = convertStringToSkyCondition(currentSkyConditionItem)
        
        return WeatherConditionOfCurrentLocation(
            todayDate: .now,
            temperature: Int(currentTemperatureItem.fcstValue)!,
            windSpeed: Float(currentWindConditionItem.fcstValue)!,
            humidity: Int(currentHumidityItem.fcstValue)!,
            skyCondition: currentSkyCondition
        )
    }
    
    private func convertStringToSkyCondition(_ currentSkyConditionItem: Item) -> SkyCondition {
        return SkyCondition.allCases.filter { skyCondition in
            return skyCondition.rawValue == Int(currentSkyConditionItem.fcstValue)
        }[0]
    }
    
    enum Category: String {
        case T1H // 기온
        case REH // 습도
        case SKY // 하늘상태
        case PTY // 강수상태
        case WSD // 풍속
    }
    
    enum SkyCondition: Int, CaseIterable {
        case sunny = 1
        case lotsOfClouds = 3
        case cloudy = 4
        
        var convertToKorean: String {
            switch self {
            case .sunny:
                return "맑음"
            case .lotsOfClouds:
                return "구름많음"
            case .cloudy:
                return "흐림"
            }
        }
    }
}




