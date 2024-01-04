//
//  MockRecentlySearchedAddressService.swift
//  TodayWeatherTests
//
//  Created by SUCHAN CHANG on 12/23/23.
//

@testable import TodayWeather
import Foundation
import RxSwift
import RealmSwift

final class MockRecentlySearchedAddressService: RecentlySearchedAddressServiceModel {
    var isCalledAddNewlySearchedAddress = false
    var isCalledFetchRecentlySearchedAddressList = false
    var isCalledDeleteRecentlySearchedAddress = false
    
    private let database: Realm
    
    // 참고: https://declan.tistory.com/85
    init() {
        // 테스트용으로 구분짓기 위해 In-memory Identifier 설정
        self.database = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "testRealm"))
    }
    
    func addNewlySearchedAddress(newAddress: TodayWeather.Address, addressForSearchNextForecast: String) {
        isCalledAddNewlySearchedAddress = true
    }
    
    func fetchRecentlySearchedAddressList() -> Results<RecentlySearchedAddressModel> {
        isCalledFetchRecentlySearchedAddressList = true
        return database.objects(RecentlySearchedAddressModel.self)
    }
    
    func deleteRecentlySearchedAddress(index: Int) {
        isCalledDeleteRecentlySearchedAddress = true
    }
}
