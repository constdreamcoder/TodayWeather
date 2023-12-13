//
//  GeolocationService.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/12/01.
//

import Alamofire
import RxSwift
import Foundation

final class GeolocationService {
    init() {}
    
    func fetchGeolocationRx(
        query: String?
    ) -> Observable<[Address]> {
        return Observable.create { [weak self] emitter in
            guard let weakSelf = self else { return Disposables.create() }
            
            weakSelf.fetchGeolocation(
                query: query
            ) { result in
                switch result {
                case .success(let addressList):
                    emitter.onNext(addressList)
                    emitter.onCompleted()
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}

private extension GeolocationService {
    func fetchGeolocation(
        query: String?,
        completionHandler: @escaping (Result<[Address], AFError>) -> Void
    ) {
        guard let url = URL(string: "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode") else { return }
        
        // TODO: - 나중에 초기화값 넣어주기
        let parameters = GeolocationRequestModel(query: query!)
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-NCP-APIGW-API-KEY-ID": "06aiesyl8c",
            "X-NCP-APIGW-API-KEY": "nk2aD2cIqm1JJ4ZLar1xWNRcH1hPjL7Q8aKlE21V"
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: GeolocationResponseModel.self) { response in
            switch response.result {
            case .success(let response):
                completionHandler(.success(response.addresses))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}
