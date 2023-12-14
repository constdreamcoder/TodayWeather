//
//  RecentlySearchedAddressService.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/12/02.
//

import RealmSwift
import RxSwift

final class RecentlySearchedAddressService {
    private let database: Realm
    
    init() {
        self.database = try! Realm()
    }
    
    // Create
    func addNewlySearchedAddress(newAddress: Address, addressForSearchNextForecast: String) {
        var temp: String = ""
        
        if newAddress.addressElements.isEmpty {
            // 최근 검색을 조회하는 경우
            temp = addressForSearchNextForecast
        } else {
            // 주소로 검색한 경우
            let siDo = newAddress.addressElements[0].shortName
            let siGuGun = newAddress.addressElements[1].shortName
            temp = siDo + " " + siGuGun
        }
        
        let newAddressModel = RecentlySearchedAddressModel(
            address: newAddress.roadAddress,
            addressForSearchNextForecast: temp,
            longitude: newAddress.x,
            latitude: newAddress.y
        )
        try! database.write {
            database.add(newAddressModel)
        }
    }
    
    // Read
    func fetchRecentlySearchedAddressList() -> Results<RecentlySearchedAddressModel> {
        return database.objects(RecentlySearchedAddressModel.self).sorted(byKeyPath: "createdAt", ascending: false)
    }
    
    // delete
    func deleteRecentlySearchedAddress(index: Int) {
        let addressToBeDeleted = fetchRecentlySearchedAddressList()[index]
        try! database.write {
            database.delete(addressToBeDeleted)
        }
    }
}
