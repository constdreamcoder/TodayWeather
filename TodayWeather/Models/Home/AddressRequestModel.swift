//
//  AddressRequestModel.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/28.
//

import Foundation

struct AddressRequestModel: Codable {
    var output: String // 출력 형식
    var coords: String // 입력 좌표
    var orders: String // 변환 작업 이름
    
    init(
        output: String = "json", // json 형식으로 출력
        coords: String = "126.833965,37.551582", // 현재 사용자 위도,경도
        orders: String = "admcode" // 좌표 to 행정동
    ) {
        self.output = output
        self.coords = coords
        self.orders = orders
    }
}
