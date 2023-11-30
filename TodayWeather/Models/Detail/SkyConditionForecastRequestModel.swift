//
//  SkyConditionForecastRequestModel.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/30.
//

import Foundation

struct SkyConditionForecastRequestModel: Codable {
    var pageNo: Int // 페이지 번호
    var numOfRows: Int // 한 페이지 결과 수
    var dataType: String // 응답자료형식
    var regId: String // 예보구역코드
    var tmFc: String // 발표시각
    
    init(
        pageNo: Int = 1,
        numOfRows: Int = 60,
        dataType: String = "JSON",
        regId: String = "11B00000",
        tmFc: String = "202311300600"
    ) {
        self.pageNo = pageNo
        self.numOfRows = numOfRows
        self.dataType = dataType
        self.regId = regId
        self.tmFc = tmFc
    }
}
