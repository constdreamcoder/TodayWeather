//
//  TemperatureForecastService.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/29.
//

import Alamofire
import RxSwift
import Foundation

final class TemperatureForecastService {
    static let shared = TemperatureForecastService()
    private let SERVICE_KEY = "tXma2V1mtyxRBkl0cL0LCpal1tBAJhM3WvCQHZf%2BP1LRscz8vEP1DYfPxnNb1cMmUjMc3bEsv8YHRkdNoA67YQ%3D%3D"
    
    private init() {}
    
    func fetchTemperatureForcastsRx(
        regId: String,
        tmFc: String
    ) -> Observable<TFItem> {
        return Observable.create { [weak self] emitter in
            guard let weakSelf = self else { return Disposables.create() }
            
            weakSelf.fetchTemperatureForcasts(
                regId: regId,
                tmFc: tmFc
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

private extension TemperatureForecastService {
    func fetchTemperatureForcasts(
        regId: String,
        tmFc: String,
        completionHandler: @escaping (Result<TFItem, AFError>) -> Void
    ) {
        guard let url = URL(string: "http://apis.data.go.kr/1360000/MidFcstInfoService/getMidTa?ServiceKey=\(SERVICE_KEY)") else { return }
        
        // TODO: - 나중에 초기화값 넣어주기
        let parameters = TemperatureForecastRequestModel(regId: regId, tmFc: tmFc)
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: TemperatureForecastResponseModel.self) { response in
            switch response.result {
            case .success(let response):
                completionHandler(.success(response.response.body.items.item[0]))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}
