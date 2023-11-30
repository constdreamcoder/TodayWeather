//
//  SkyConditionForecastService.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/30.
//

import Alamofire
import RxSwift

final class SkyConditionForecastService {
    static let shared = SkyConditionForecastService()
    private let SERVICE_KEY = "tXma2V1mtyxRBkl0cL0LCpal1tBAJhM3WvCQHZf%2BP1LRscz8vEP1DYfPxnNb1cMmUjMc3bEsv8YHRkdNoA67YQ%3D%3D"
    
    private init() {}
    
    func fetchSkyConditionForcastsRx(
        regId: String,
        tmFc: String
    ) -> Observable<SCItem> {
        return Observable.create { [weak self] emitter in
            guard let weakSelf = self else { return Disposables.create() }
            
            weakSelf.fetchSkyConditionForcasts(
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

extension SkyConditionForecastService {
    func fetchSkyConditionForcasts(
        regId: String,
        tmFc: String,
        completionHandler: @escaping (Result<SCItem, AFError>) -> Void
    ) {
        guard let url = URL(string: "http://apis.data.go.kr/1360000/MidFcstInfoService/getMidLandFcst?ServiceKey=\(SERVICE_KEY)") else { return }
        
        // TODO: - 나중에 초기화값 넣어주기
        let parameters = SkyConditionForecastRequestModel(regId: regId, tmFc: tmFc)
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: SkyConditionResponseModel.self) { response in
            switch response.result {
            case .success(let response):
                completionHandler(.success(response.response.body.items.item[0]))
            case .failure(let error):
                print(error)
                completionHandler(.failure(error))
            }
        }
    }
}
