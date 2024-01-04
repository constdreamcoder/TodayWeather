//
//  HomeViewModelTests.swift
//  TodayWeatherTests
//
//  Created by SUCHAN CHANG on 12/14/23.
//
@testable import TodayWeather
import XCTest
import RxSwift
import RxCocoa
import CoreLocation

final class HomeViewModelTests: XCTestCase {
    
    private var sut: HomeViewModel!
    private var realtimeForcastService: MockRealtimeForecastService!
    private var koreanAddressService: MockKoreanAddressService!
    private var locationManager: CLLocationManager!
    private var delegate: MockHomeViewController!
    
    private var detailViewModel: DetailViewModel!
    private var dailyWeatherForecastService: MockDailyWeatherForecastService!
    private var temperatureForecastService: MockTemperatureForecastService!
    private var skyConditionForecastService: MockSkyConditionForecastService!
    private var regionCodeSearchingService: MockRegionCodeSearchingService!
    
    private let disposeBag = DisposeBag()
    
    override func setUpWithError() throws {
        realtimeForcastService = MockRealtimeForecastService()
        koreanAddressService = MockKoreanAddressService()
        locationManager = CLLocationManager()
        
        delegate = MockHomeViewController()
        
        sut = HomeViewModel(
            realtimeForecastService: realtimeForcastService,
            koreanAddressService: koreanAddressService,
            locationManager: locationManager
        )
        sut.delegate = delegate
        
        dailyWeatherForecastService = MockDailyWeatherForecastService()
        temperatureForecastService = MockTemperatureForecastService()
        skyConditionForecastService = MockSkyConditionForecastService()
        regionCodeSearchingService = MockRegionCodeSearchingService()
        
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        realtimeForcastService = nil
        koreanAddressService = nil
        locationManager = nil
        
        delegate = nil
        detailViewModel = nil
        dailyWeatherForecastService = nil
        temperatureForecastService = nil
        skyConditionForecastService = nil
        regionCodeSearchingService = nil
        
        try super.tearDownWithError()
    }
    
    func test_사용자_위치_조회가_완료되었을_때() {
        // given
        let input = createInput()
        let output = sut.transform(input: input)
        
        // when
        sut.locationManager(locationManager, didUpdateLocations: [CLLocation(latitude: 37.551582, longitude: 126.833965)])
        
        // then
        XCTAssertTrue(realtimeForcastService.isCalledFetchRealtimeForecastsRx)
        XCTAssertTrue(koreanAddressService.isCalledConvertLatAndLngToKoreanAddressRx)
    }
    
    func test_사용자_위치_조회_완료후_예보_리포트_버튼을_클릭했을_때() {
        // given
        let goToDetailVCTapped = PublishSubject<Void>()
        let input = createInput(goToDetailVCTapped: goToDetailVCTapped.asObservable())
        let output = sut.transform(input: input)
        
        output.triggerForecastReportAPIs
            .bind(onNext: { [weak self] userLocation, koreanFullAdress in
                guard let weakSelf = self else { return }
                weakSelf.detailViewModel = DetailViewModel(
                    realtimeForcastService: weakSelf.realtimeForcastService,
                    dailyWeatherForecastService: weakSelf.dailyWeatherForecastService,
                    temperatureForecastService: weakSelf.temperatureForecastService,
                    skyConditionForecastService: weakSelf.skyConditionForecastService, regionCodeSearchingService: weakSelf.regionCodeSearchingService,
                    userLocation: userLocation,
                    koreanFullAdress: koreanFullAdress
                )
            })
            .disposed(by: disposeBag)
        let convertedXY = ConvertXY().convertGRID_GPS(mode: .TO_GRID, lat_X: 37.551582, lng_Y: 126.833965)
        output.triggerForecastReportAPIs.accept((convertedXY, "서울특별시 강서구 발산1동"))
        
        // when
        output.goToDetailVC.drive().disposed(by: disposeBag)
        goToDetailVCTapped.onNext(())

        // then
        XCTAssertTrue(realtimeForcastService.isCalledFetchRealtimeForecastsRx)
        XCTAssertTrue(dailyWeatherForecastService.isCalledFetchDailyWeatherForecastInfosRx)
        XCTAssertTrue(temperatureForecastService.isCalledFetchTemperatureForcastsRx)
        XCTAssertTrue(skyConditionForecastService.isCalledFetchSkyConditionForcastsRx)
        XCTAssertTrue(regionCodeSearchingService.isCalledSearchRegionCodeForTemperature)
        XCTAssertTrue(regionCodeSearchingService.isCalledSearchRegionCodeForSkyCondition)
        XCTAssertTrue(delegate.isCalledGotoDetailVC)
    }
    
    func test_사용자_위치_조회_완료후_사용자_위치_버튼을_클릭했을_때() {
        // given
        let goToNMapTapped = PublishSubject<Void>()
        let input = createInput(goToNMapTapped: goToNMapTapped)
        let output = sut.transform(input: input)
        
        output.triggerForecastReportAPIs
            .bind(onNext: { [weak self] userLocation, koreanFullAdress in
                guard let weakSelf = self else { return }
                weakSelf.detailViewModel = DetailViewModel(
                    realtimeForcastService: weakSelf.realtimeForcastService,
                    dailyWeatherForecastService: weakSelf.dailyWeatherForecastService,
                    temperatureForecastService: weakSelf.temperatureForecastService,
                    skyConditionForecastService: weakSelf.skyConditionForecastService, regionCodeSearchingService: weakSelf.regionCodeSearchingService,
                    userLocation: userLocation,
                    koreanFullAdress: koreanFullAdress
                )
            })
            .disposed(by: disposeBag)
        let convertedXY = ConvertXY().convertGRID_GPS(mode: .TO_GRID, lat_X: 37.551582, lng_Y: 126.833965)
        output.triggerForecastReportAPIs.accept((convertedXY, "서울특별시 강서구 발산1동"))
        
        // when
        output.goToSearchVC.drive().disposed(by: disposeBag)
        goToNMapTapped.onNext(())

        // then
        XCTAssertTrue(realtimeForcastService.isCalledFetchRealtimeForecastsRx)
        XCTAssertTrue(dailyWeatherForecastService.isCalledFetchDailyWeatherForecastInfosRx)
        XCTAssertTrue(temperatureForecastService.isCalledFetchTemperatureForcastsRx)
        XCTAssertTrue(skyConditionForecastService.isCalledFetchSkyConditionForcastsRx)
        XCTAssertTrue(regionCodeSearchingService.isCalledSearchRegionCodeForTemperature)
        XCTAssertTrue(regionCodeSearchingService.isCalledSearchRegionCodeForSkyCondition)
        XCTAssertTrue(delegate.isCalledGotoSearchVC)
    }
    
    private func createInput(
        goToNMapTapped: Observable<Void> = Observable.never(),
        goToDetailVCTapped: Observable<Void> = Observable.never()
    ) -> HomeViewModel.Input {
        return HomeViewModel.Input(
            goToNMapTapped: goToNMapTapped.asDriverOnErrorJustComplete(),
            goToDetailVCTapped: goToDetailVCTapped.asDriverOnErrorJustComplete()
        )
    }
    
}
