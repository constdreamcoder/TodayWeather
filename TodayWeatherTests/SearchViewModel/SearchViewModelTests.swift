//
//  SearchViewModelTests.swift
//  TodayWeatherTests
//
//  Created by SUCHAN CHANG on 12/18/23.
//

@testable import TodayWeather
import XCTest
import RxSwift
import RxCocoa
import CoreLocation

final class SearchViewModelTests: XCTestCase {

    private var sut: SearchViewModel!
    
    private var geolocationService: MockGeolocationService!
    private var dailyWeatherForecastService: MockDailyWeatherForecastService!
    private var realtimeForcastService: MockRealtimeForecastService!
    private var recentlySearchedAddressService: MockRecentlySearchedAddressService!
    
    private var delegate: MockSearchViewComtroller!
    private var convertedXY: ConvertXY.LatXLngY!

    private let disposeBag = DisposeBag()

    override func setUpWithError() throws {
        geolocationService = MockGeolocationService()
        dailyWeatherForecastService = MockDailyWeatherForecastService()
        realtimeForcastService = MockRealtimeForecastService()
        recentlySearchedAddressService = MockRecentlySearchedAddressService()
        
        delegate = MockSearchViewComtroller()
        convertedXY = ConvertXY().convertGRID_GPS(mode: .TO_GRID, lat_X: 37.551582, lng_Y: 126.833965)

        sut = SearchViewModel(
            geolocationService: geolocationService,
            dailyWeatherForecastService: dailyWeatherForecastService,
            realtimeForcastService: realtimeForcastService,
            recentlySearchedAddressService: recentlySearchedAddressService,
            userLocation: convertedXY
        )
        
        sut.delegate = delegate
        
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        convertedXY = nil

        geolocationService = nil
        dailyWeatherForecastService = nil
        realtimeForcastService = nil
        recentlySearchedAddressService = nil
        
        delegate = nil

        sut = nil
            
        try super.tearDownWithError()
    }

    func test_홈으로_되돌아_가기() throws {
        // given
        let goBackBtnTapped = PublishSubject<Void>()
        let input = createInput(goBackBtnTapped: goBackBtnTapped)
        let output = sut.transform(input: input)
        
        // when
        output.goBackToHome.drive().disposed(by: disposeBag)
        goBackBtnTapped.onNext(())
        
        // then
        XCTAssertTrue(delegate.isCalledGoBackToHome)
    }
    
    func test_검색어를_입력되어_있지_않고_서치바_터치한_경우() {
        // given
        let searchBarTextInput = PublishSubject<String>()
        let textDidBeginEditing = PublishSubject<Void>()
        let input = createInput(
            searchBarTextInput: searchBarTextInput,
            textDidBeginEditing: textDidBeginEditing
        )
        let output = sut.transform(input: input)
                
        // when
        output.textDidBeginEditing.drive().disposed(by: disposeBag)
        
        searchBarTextInput.onNext("")
        textDidBeginEditing.onNext(())
        
        // then
        XCTAssertTrue(delegate.isCalledShowTableView)
        XCTAssertTrue(recentlySearchedAddressService.isCalledFetchRecentlySearchedAddressList)
    }
    
    func test_검색어를_입력되어_있고_서치바_터치한_경우() {
        // given
        let searchBarTextInput = PublishSubject<String>()
        let textDidBeginEditing = PublishSubject<Void>()
        let input = createInput(
            searchBarTextInput: searchBarTextInput,
            textDidBeginEditing: textDidBeginEditing
        )
        let output = sut.transform(input: input)

        // when
        output.textDidBeginEditing.drive().disposed(by: disposeBag)
        
        searchBarTextInput.onNext("발산1동")
        textDidBeginEditing.onNext(())
        
        // then
        XCTAssertTrue(delegate.isCalledShowTableView)
        XCTAssertFalse(recentlySearchedAddressService.isCalledFetchRecentlySearchedAddressList)
        XCTAssertTrue(geolocationService.isCalledFetchGeolocationRx)
    }
    
    func test_검색어_입력하는_경우() {
        // given
        let searchBarTextInput = PublishSubject<String>()
        let input = createInput(searchBarTextInput: searchBarTextInput)
        let output = sut.transform(input: input)
        
        // when
        searchBarTextInput.onNext("발")
        searchBarTextInput.onNext("발산")
        searchBarTextInput.onNext("발산1")
        searchBarTextInput.onNext("발산1동")
        
        // then
        XCTAssertFalse(recentlySearchedAddressService.isCalledFetchRecentlySearchedAddressList)
    }
    
    func test_검색어를_모두_지우는_경우() {
        // given
        let searchBarTextInput = PublishSubject<String>()
        let input = createInput(searchBarTextInput: searchBarTextInput)
        let output = sut.transform(input: input)
        
        // when
        searchBarTextInput.onNext("발산1동")
        searchBarTextInput.onNext("발산1")
        searchBarTextInput.onNext("발산")
        searchBarTextInput.onNext("발")
        searchBarTextInput.onNext("")

        // then
        XCTAssertTrue(recentlySearchedAddressService.isCalledFetchRecentlySearchedAddressList)
    }
    
    func test_서치바_터치하고_검색어_입력한_후_엔터를_누른_경우() {
        // given
        let searchBarTextInput = PublishSubject<String>()
        let textDidBeginEditing = PublishSubject<Void>()
        let textDidEndEditing = PublishSubject<Void>()
        let searchButtonClicked = PublishSubject<Void>()
        let input = createInput(
            searchBarTextInput: searchBarTextInput, 
            textDidBeginEditing: textDidBeginEditing,
            textDidEndEditing: textDidEndEditing,
            searchButtonClicked: searchButtonClicked
        )
        let output = sut.transform(input: input)
        
        // when
        output.textDidBeginEditing.drive().disposed(by: disposeBag)
        output.searchButtonClicked.drive().disposed(by: disposeBag)
        output.textDidEndEditing.drive().disposed(by: disposeBag)
        
        textDidBeginEditing.onNext(())
        searchBarTextInput.onNext("강서구 발산1동")
        searchButtonClicked.onNext(())
        textDidEndEditing.onNext(())
        
        // then
        XCTAssertTrue(delegate.isCalledShowTableView)
        XCTAssertTrue(recentlySearchedAddressService.isCalledFetchRecentlySearchedAddressList)
        XCTAssertTrue(output.searchedTextData.value == "강서구 발산1동")
        XCTAssertTrue(geolocationService.isCalledFetchGeolocationRx)
        XCTAssertTrue(delegate.isCalledResignSearchBarFromFirstResponder)
    }
    
    func test_서치바_터치하고_검색어_입력하고_엔터를_누르고_검색결과로_나온_주소_중_하나를_선택한_경우() {
        // given
        let searchBarTextInput = PublishSubject<String>()
        let textDidBeginEditing = PublishSubject<Void>()
        let textDidEndEditing = PublishSubject<Void>()
        let searchButtonClicked = PublishSubject<Void>()
        let addressSelected = PublishSubject<IndexPath>()
        let input = createInput(
            searchBarTextInput: searchBarTextInput,
            textDidBeginEditing: textDidBeginEditing,
            textDidEndEditing: textDidEndEditing,
            searchButtonClicked: searchButtonClicked,
            addressSelected: addressSelected
        )
        let output = sut.transform(input: input)
        
        // when
        output.textDidBeginEditing.drive().disposed(by: disposeBag)
        output.searchButtonClicked.drive().disposed(by: disposeBag)
        output.textDidEndEditing.drive().disposed(by: disposeBag)
        output.addressSelected.drive().disposed(by: disposeBag)
        
        textDidBeginEditing.onNext(())
        searchBarTextInput.onNext("강서구 발산1동")
        searchButtonClicked.onNext(())
        textDidEndEditing.onNext(())
        addressSelected.onNext(IndexPath(row: 0, section: 0))
        
        // then
        XCTAssertTrue(delegate.isCalledShowTableView)
        XCTAssertTrue(recentlySearchedAddressService.isCalledFetchRecentlySearchedAddressList)
        XCTAssertTrue(output.searchedTextData.value == "강서구 발산1동")
        XCTAssertTrue(geolocationService.isCalledFetchGeolocationRx)
        XCTAssertTrue(delegate.isCalledResignSearchBarFromFirstResponder)
        XCTAssertTrue(false)
        // 테스트 중 오류: 주소 검색 결과 Mock 데이터 설정 어려움으로 인해 테스트에 어려움이 있음
//        XCTAssertTrue(dailyWeatherForecastService.isCalledFetchDailyWeatherForecastInfosRx)
//        XCTAssertTrue(realtimeForcastService.isCalledFetchRealtimeForecastsRx)
//        XCTAssertTrue(delegate.isCalledShowInfoWindowOnMarker)
//        XCTAssertTrue(delegate.isCalledShowTableView)
//        XCTAssertTrue(recentlySearchedAddressService.isCalledAddNewlySearchedAddress)
//        XCTAssertTrue(delegate.isCalledResignSearchBarFromFirstResponder)
    }

    private func createInput(
        goBackBtnTapped: Observable<Void> = Observable.never(),
        searchBarTextInput: Observable<String> = Observable.never(),
        textDidBeginEditing: Observable<Void> = Observable.never(),
        textDidEndEditing: Observable<Void> = Observable.never(),
        searchButtonClicked: Observable<Void> = Observable.never(),
        addressSelected: Observable<IndexPath> = Observable.never(),
        moveToUserBtnTapped: Observable<Void> = Observable.never()
    ) -> SearchViewModel.Input {
        return SearchViewModel.Input(
            goBackBtnTapped: goBackBtnTapped.asDriverOnErrorJustComplete(),
            searchBarTextInput: searchBarTextInput.asDriverOnErrorJustComplete(),
            textDidBeginEditing: textDidBeginEditing.asDriverOnErrorJustComplete(),
            textDidEndEditing: textDidEndEditing.asDriverOnErrorJustComplete(),
            searchButtonClicked: searchButtonClicked.asDriverOnErrorJustComplete(),
            addressSelected: addressSelected.asDriverOnErrorJustComplete(),
            moveToUserBtnTapped: moveToUserBtnTapped.asDriverOnErrorJustComplete()
        )
    }
}
