//
//  RegionCodeSearchingService.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 12/13/23.
//

import Foundation

final class RegionCodeSearchingService {
    private let regIdForSkyUrl: URL! = Bundle.main.url(forResource: "RegIdForSky", withExtension: "plist")
    private let regIdForTempUrl: URL! = Bundle.main.url(forResource: "RegIdForTemp", withExtension: "plist")
    
    func searchRegionCodeForTemperature(koreanFullAdress: String = "") -> String {
        do {
            let data = try Data(contentsOf: regIdForTempUrl)
            let result = try PropertyListDecoder().decode([RegionCodeModel].self, from: data)
            let filteredArray = result.filter { regionCodeModel in
                let splittedString = regionCodeModel.regName.components(separatedBy: "(")
                return koreanFullAdress.contains(splittedString[0])
            }
            print(filteredArray[0].regId)
            return filteredArray[0].regId
        } catch {
            print(error)
            return ""
        }
    }
    
    func searchRegionCodeForSkyCondition(koreanFullAdress: String = "") -> String {
        do {
            let data = try Data(contentsOf: regIdForSkyUrl)
            let result = try PropertyListDecoder().decode([RegionCodeModel].self, from: data)
            let filteredArray = result.filter { regionCodeModel in
                let splittedString = regionCodeModel.regName.components(separatedBy: ", ")
                let count = splittedString.filter { region in
                    if region.contains("강원") {
                        return koreanFullAdress.contains("강원")
                    } else {
                        return koreanFullAdress.contains(region)
                    }
                }.count
                return count >= 1
            }
            print(filteredArray[0].regId)
            return filteredArray[0].regId
        } catch {
            print(error)
            return ""
        }
    }
}
