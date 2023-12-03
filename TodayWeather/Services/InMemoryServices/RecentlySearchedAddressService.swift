//
//  RecentlySearchedAddressService.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/12/02.
//

import RealmSwift
import RxSwift

final class RecentlySearchedAddressService {
    static let shared = RecentlySearchedAddressService()
    
    private let database: Realm
    
    private init() {
        self.database = try! Realm()
    }
    
    // Create
    func addNewlySearchedAddress(newAddress: Address) {
        let newAddressModel = RecentlySearchedAddressModel(
            address: newAddress.roadAddress,
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
