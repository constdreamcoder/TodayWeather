//
//  HomeViewModel.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/27.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay
import CoreLocation

protocol HomeNavigator: AnyObject {
    func gotoSearchVC()
    func gotoDetailVC()
}

final class HomeViewModel: NSObject, ViewModelType {
    struct Input {
//        let triggerAPI: Observable<Void>
        let goToNMapTapped: Driver<Void>
        let goToDetailVCTapped: Driver<Void>
    }
    
    struct Output {
        let currentWeatherCondition: Driver<WeatherConditionOfCurrentLocation>
        let currentAddressOfLocation: Driver<String>
        let gotoSearchVC: Driver<Void>
        let goToDetailVC: Driver<Void>
        let triggerForecastReportAPIs: BehaviorRelay
        <(userLocation:ConvertXY.LatXLngY, koreanFullAdress: String)>
    }
    
    func transform(input: Input) -> Output {
        let currentWeatherCondition = currentWeatherConditionRelay.asDriver()
        let currentAddressOfLocation = currentAddressOfLocationRelay.asDriver()
        let gotoSearchVC = input.goToNMapTapped.do { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.delegate?.gotoSearchVC()
        }
        let goToDetailVC = input.goToDetailVCTapped.do { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.delegate?.gotoDetailVC()
        }
        let triggerForecastReportAPIs = userLocationRelay
        
        return Output(
            currentWeatherCondition: currentWeatherCondition,
            currentAddressOfLocation: currentAddressOfLocation, 
            gotoSearchVC: gotoSearchVC,
            goToDetailVC: goToDetailVC, 
            triggerForecastReportAPIs: triggerForecastReportAPIs
        )
    }
    
    private let realtimeForcastService: RealtimeForcastService
    private let koreanAddressService: KoreanAddressService
    private let lManager: CLLocationManager
    
    weak var delegate: HomeNavigator?
    
    private var currentWeatherConditionRelay = BehaviorRelay<WeatherConditionOfCurrentLocation>(value: WeatherConditionOfCurrentLocation())
    private var currentAddressOfLocationRelay = BehaviorRelay<String>(value: "")
    private var userLocationRelay = BehaviorRelay
    <(userLocation:ConvertXY.LatXLngY, koreanFullAdress: String)>(value: (userLocation: ConvertXY.LatXLngY(), koreanFullAdress: ""))
    
    private var dispostBag = DisposeBag()

    var userLocation: ConvertXY.LatXLngY?
        
    init(
        realtimeForcastService: RealtimeForcastService,
        koreanAddressService: KoreanAddressService,
        locationManager: CLLocationManager
    ) {
        self.realtimeForcastService = realtimeForcastService
        self.koreanAddressService = koreanAddressService
        self.lManager = locationManager
        super.init()
        
        self.setLocationManager()
    }
}

// MARK: - 사용자 위치 관련 메소드
extension HomeViewModel: CLLocationManagerDelegate {
    func setLocationManager() {
        lManager.delegate = self
        lManager.desiredAccuracy = kCLLocationAccuracyBest
        lManager.requestWhenInUseAuthorization()
        DispatchQueue.global().async { [weak self] in
            guard let weakSelf = self else { return }
            let locationServiceEnabled = CLLocationManager.locationServicesEnabled()
            if locationServiceEnabled {
                weakSelf.lManager.startUpdatingLocation()
            } else {
                print("위치 서비스 허용 off")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            print("위치 업데이트")
            print("위도 : \(location.coordinate.latitude)")
            print("경도 : \(location.coordinate.longitude)")
            userLocation = ConvertXY().convertGRID_GPS(
                mode: .TO_GRID,
                lat_X: location.coordinate.latitude,
                lng_Y: location.coordinate.longitude
            )
            
            realtimeForcastService.fetchRealtimeForecastsRx(nx: userLocation!.x, ny: userLocation!.y)
                .observe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
                .map { items in
                    return items.getCurrentWeatherConditionInfos()
                }
                .bind(to: currentWeatherConditionRelay)
                .disposed(by: dispostBag)
            
            koreanAddressService.convertLatAndLngToKoreanAddressRx(latitude: userLocation!.lat, longitude: userLocation!.lng)
                .observe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
                .map { [weak self] region -> String in
                    guard let weakSelf = self else { return "" }
                    weakSelf.userLocationRelay.accept((weakSelf.userLocation!, region.getFullAdress()))
                    return region.getAddress()
                }
                .bind(to: currentAddressOfLocationRelay)
                .disposed(by: dispostBag)
            
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("사용자 위치 검색중 오류발생: \(error)")
    }
    
    // 사용자 위치 접근 상태 확인 메소드
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse && manager.authorizationStatus == .authorizedAlways {
            
        }
    }
}
