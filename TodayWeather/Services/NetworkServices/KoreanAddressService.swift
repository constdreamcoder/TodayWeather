//
//  KoreanAddressService.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/28.
//

import Alamofire
import RxSwift
import Foundation

protocol KoreanAddressServiceModel {
    func convertLatAndLngToKoreanAddressRx(latitude: Double, longitude: Double) -> Observable<Region>
}

final class KoreanAddressService: KoreanAddressServiceModel {
    private let CLIENT_ID = "06aiesyl8c"
    private let CLIENT_SECRET = "nk2aD2cIqm1JJ4ZLar1xWNRcH1hPjL7Q8aKlE21V"
    
    init() {}
    
    func convertLatAndLngToKoreanAddressRx(
        latitude: Double,
        longitude: Double
    ) -> Observable<Region> {
        return Observable.create { [weak self] emitter in
            guard let weakSelf = self else { return Disposables.create() }
            
            let coords = weakSelf.combineAndConvertToString(latitude: latitude, longitude: longitude)

            weakSelf.convertLatAndLngToKoreanAddress(coords: coords) { result in
                switch result {
                case .success(let region):
                    emitter.onNext(region)
                    emitter.onCompleted()
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}

private extension KoreanAddressService {
    func convertLatAndLngToKoreanAddress(
        coords: String,
        completionHandler: @escaping (Result<Region, AFError>) -> Void
    ) {
        guard let url = URL(string: "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc") else { return }
        
        let parameters = AddressRequestModel(coords: coords)
        
        let headers: HTTPHeaders = [
            "X-NCP-APIGW-API-KEY-ID": "\(CLIENT_ID)",
            "X-NCP-APIGW-API-KEY": "\(CLIENT_SECRET)",
            "Content-Type": "application/json"
        ]
                
        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: AddressResponseModel.self) { response in
            switch response.result {
            case .success(let response):
                completionHandler(.success(response.results[0].region))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func combineAndConvertToString(
        latitude: Double,
        longitude: Double
    ) -> String {
        return "\(longitude),\(latitude)"
    }
}
