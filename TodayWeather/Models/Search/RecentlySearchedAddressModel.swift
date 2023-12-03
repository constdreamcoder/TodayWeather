//
//  RecentlySearchedAddressModel.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/12/02.
//

import RealmSwift

final class RecentlySearchedAddressModel: Object {
    @Persisted var address: String
    @Persisted var longitude: String
    @Persisted var latitude: String
    @Persisted var createdAt: Double
    
    convenience init(
        address: String = "",
        longitude: String = "0",
        latitude: String = "0",
        createdAt: Double = Date().timeIntervalSince1970
    ) {
        self.init()
        self.address = address
        self.longitude = longitude
        self.latitude = latitude
        self.createdAt = createdAt
    }
}

