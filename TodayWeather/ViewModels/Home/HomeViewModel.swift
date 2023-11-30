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
    private var locationManager = CLLocationManager()
    
    var currentWeatherConditionObservable = PublishRelay<WeatherConditionOfCurrentLocation>()
    var currentLocationObservable = PublishRelay<String>()
        
    private override init() {
        super.init()
        
        setLocationManager()
    }
}

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
 
            KoreanAddressService.shared.convertLatAndLngToKoreanAddressRx(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                .map { region in
                    return region.getAddress()
                }
                .take(1)
                .bind(to: currentLocationObservable)
                
            let convertedXY = ConvertXY().convertGRID_GPS(mode: .TO_GRID, lat_X: location.coordinate.latitude, lng_Y: location.coordinate.longitude)
            print(convertedXY.x, convertedXY.y)
            let itemObservable = RealtimeForcastService.shared.fetchRealtimeForecastsRx(nx: convertedXY.x, ny: convertedXY.y)
            itemObservable
                .map { items in
                    return items.getCurrentWeatherConditionInfos()
                }
                .take(1)
                .bind(to: currentWeatherConditionObservable)
            
            itemObservable
                .map { items in
                    return items.getTodayWeatherForecastList()
                }
                .take(1)
                .bind(to: DetailViewModel.shared.todayWeatherForecastListObservable)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
    
    // 사용자 위치 접근 상태 확인 메소드
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse && manager.authorizationStatus == .authorizedAlways {
            
        }
    }
}
