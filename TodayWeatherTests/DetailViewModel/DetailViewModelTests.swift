//
//  DetailViewModelTests.swift
//  TodayWeatherTests
//
//  Created by SUCHAN CHANG on 12/18/23.
//

@testable import TodayWeather
import XCTest
import RxSwift
import RxCocoa
import CoreLocation

final class DetailViewModelTests: XCTestCase {
    
    private var sut: DetailViewModel!
    
    private var realtimeForcastService: MockRealtimeForecastService!
    private var dailyWeatherForecastService: MockDailyWeatherForecastService!
    private var temperatureForecastService: MockTemperatureForecastService!
    private var skyConditionForecastService: MockSkyConditionForecastService!
    private var regionCodeSearchingService: MockRegionCodeSearchingService!
    
    private var delegate: MockDetailViewController!
    private var convertedXY: ConvertXY.LatXLngY!
    
    private let disposeBag = DisposeBag()

    override func setUpWithError() throws {
        convertedXY = ConvertXY().convertGRID_GPS(mode: .TO_GRID, lat_X: 37.551582, lng_Y: 126.833965)
        
        realtimeForcastService = MockRealtimeForecastService()
        dailyWeatherForecastService = MockDailyWeatherForecastService()
        temperatureForecastService = MockTemperatureForecastService()
        skyConditionForecastService = MockSkyConditionForecastService()
        regionCodeSearchingService = MockRegionCodeSearchingService()
        
        delegate = MockDetailViewController()
        sut = DetailViewModel(
            realtimeForcastService: realtimeForcastService,
            dailyWeatherForecastService: dailyWeatherForecastService,
            temperatureForecastService: temperatureForecastService,
            skyConditionForecastService: skyConditionForecastService,
            regionCodeSearchingService: regionCodeSearchingService,
            userLocation: convertedXY,
            koreanFullAdress: "서울특별시 강서구 발산1동"
        )
        sut.delegate = delegate
        
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        convertedXY = nil
        
        realtimeForcastService = nil
        dailyWeatherForecastService = nil
        temperatureForecastService = nil
        skyConditionForecastService = nil
        regionCodeSearchingService = nil
        
        delegate = nil
        sut = nil
        
        try super.tearDownWithError()
    }

    func test_뒤로가기_버튼을_눌렀을_때() throws {
        let goBackBtnTapped = PublishSubject<Void>()
        let input = createInput(goBackBtnTapped: goBackBtnTapped)
        let output = sut.transform(input: input)
        
        output.goBack.drive().disposed(by: disposeBag)
        goBackBtnTapped.onNext(())
        
        XCTAssertTrue(delegate.isCalledGoBack)
    }

    private func createInput(
        goBackBtnTapped: Observable<Void> = Observable.never()
    ) -> DetailViewModel.Input {
        return DetailViewModel.Input(goBackBtnTapped: goBackBtnTapped.asDriverOnErrorJustComplete())
    }
}
