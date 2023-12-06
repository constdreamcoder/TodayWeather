//
//  HomeViewModel.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/27.
//

import Foundation
import RxSwift
import RxRelay
import CoreLocation

final class HomeViewModel: NSObject {
    
    static let shared = HomeViewModel()
    var locationManager = CLLocationManager()
    
    var currentWeatherConditionObservable = PublishRelay<WeatherConditionOfCurrentLocation>()
    var currentLocationRelay = PublishRelay<String>()
    
    var userLocation = ConvertXY.LatXLngY()
    
    var isInitialized: Bool = false
    
    private override init() {
        super.init()
        
        setLocationManager()
    }
    
    func getWeatherConditionOfCurrentLocationObservable(nx: Int, ny: Int) -> Observable<WeatherConditionOfCurrentLocation> {
        return RealtimeForcastService.shared.fetchRealtimeForecastsRx(nx: nx, ny: ny)
            .map { items in
                DetailViewModel.shared.todayWeatherForecastListSubject.onNext(items.getTodayWeatherForecastList())
                return items.getCurrentWeatherConditionInfos()
            }
    }
}

// MARK: - 사용자 위치 관련 메소드
extension HomeViewModel: CLLocationManagerDelegate {
    func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.global().async { [weak self] in
            guard let weakSelf = self else { return }
            let locationServiceEnabled = CLLocationManager.locationServicesEnabled()
            if locationServiceEnabled {
                weakSelf.locationManager.startUpdatingLocation()
            } else {
                print("위치 서비스 허용 off")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("위치 업데이트")
            print("위도 : \(location.coordinate.latitude)")
            print("경도 : \(location.coordinate.longitude)")
            
            if !isInitialized {
                isInitialized = true
                
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                
                KoreanAddressService.shared.convertLatAndLngToKoreanAddressRx(latitude: latitude, longitude: longitude)
                    .map { region in
                        return region.getAddress()
                    }
                    .take(1)
                    .bind(to: currentLocationRelay)
                
                userLocation = ConvertXY().convertGRID_GPS(mode: .TO_GRID, lat_X: latitude, lng_Y: longitude)
                let baseDateAndTime = Date().getBaseDateAndTimeForRealtimeForecast
                
                getWeatherConditionOfCurrentLocationObservable(nx: userLocation.x, ny: userLocation.y)
                    .take(1)
                    .bind(to: currentWeatherConditionObservable)
                
                // Search로 전달
                Observable.just([latitude, longitude], scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
                    .take(1)
                    .subscribe { userLocation in
                        SearchViewModel.shared.userLocationSubject.onNext(userLocation)
                    }
            } else {
                print("초기화됨")
            }
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
