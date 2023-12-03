//
//  RealtimeForcastService.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/27.
//

import Alamofire
import RxSwift

final class RealtimeForcastService {
    static let shared = RealtimeForcastService()
    private let SERVICE_KEY = "tXma2V1mtyxRBkl0cL0LCpal1tBAJhM3WvCQHZf%2BP1LRscz8vEP1DYfPxnNb1cMmUjMc3bEsv8YHRkdNoA67YQ%3D%3D"
    
    private init() {}
    
    func fetchRealtimeForecastsRx(
        nx: Int,
        ny: Int
    ) -> Observable<Items> {
        return Observable.create { [weak self] emitter in
            guard let weakSelf = self else { return Disposables.create() }
            let baseDateAndTime = Date().getBaseDateAndTimeForRealtimeForecast
            weakSelf.fetchRealtimeForecasts(
                base_date: baseDateAndTime.baseDate,
                base_time: baseDateAndTime.baseTime,
                nx: nx,
                ny: ny
            ) { result in
                switch result {
                case .success(let items):
                    emitter.onNext(items)
                    emitter.onCompleted()
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}

private extension RealtimeForcastService {
    func fetchRealtimeForecasts(
        base_date: String,
        base_time: String,
        nx: Int,
        ny: Int,
        completionHandler: @escaping (Result<Items, AFError>) -> Void
    ) {
        guard let url = URL(string: "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst?ServiceKey=\(SERVICE_KEY)") else { return }
        
        let parameters = RealtimeForecastRequestModel(
            base_date: base_date,
            base_time: base_time,
            nx: nx,
            ny: ny
        )
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers)
            .responseDecodable(of: RealtimeForecastResponseModel.self) { response in
                switch response.result {
                case .success(let response):
                    completionHandler(.success(response.response.body.items))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
}
