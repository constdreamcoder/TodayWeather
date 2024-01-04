//
//  DailyWeatherForecastService.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/12/03.
//

import Alamofire
import RxSwift
import Foundation

protocol DailyWeatherForecastServiceModel {
    func fetchDailyWeatherForecastInfosRx(nx: Int, ny: Int, base_time: String) -> Observable<DWFItems>
}

final class DailyWeatherForecastService: DailyWeatherForecastServiceModel {
    private let SERVICE_KEY = "tXma2V1mtyxRBkl0cL0LCpal1tBAJhM3WvCQHZf%2BP1LRscz8vEP1DYfPxnNb1cMmUjMc3bEsv8YHRkdNoA67YQ%3D%3D"
    
    init() {}
    
    func fetchDailyWeatherForecastInfosRx(
        nx: Int,
        ny: Int,
        base_time: String
    ) -> Observable<DWFItems> {
        return Observable.create { [weak self] emitter in
            guard let weakSelf = self else { return Disposables.create() }
            let baseDateAndTime = Date().getBaseDateAndTimeForDailyWeatherForecast
            weakSelf.fetchDailyWeatherForecastInfos(
                base_date: baseDateAndTime.baseDate,
                base_time: base_time,
                nx: nx,
                ny: ny
            ) { result in
                switch result {
                case .success(let item):
                    emitter.onNext(item)
                    emitter.onCompleted()
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}

private extension DailyWeatherForecastService {
    func fetchDailyWeatherForecastInfos(
        base_date: String,
        base_time: String,
        nx: Int,
        ny: Int,
        completionHandler: @escaping (Result<DWFItems, AFError>) -> Void
    ) {
        guard let url = URL(string: "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?ServiceKey=\(SERVICE_KEY)") else { return }
        
        // TODO: - 나중에 초기화값 넣어주기
        let parameters = DailyWeatherForecastRequestModel(
            base_date: base_date,
            base_time: base_time,
            nx: nx,
            ny: ny
        )
                
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: DailyWeatherForecastResponseModel.self) { response in
            switch response.result {
            case .success(let response):
                completionHandler(.success(response.response.body.items))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}
