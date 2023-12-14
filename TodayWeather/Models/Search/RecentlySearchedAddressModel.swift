//
//  RecentlySearchedAddressModel.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/12/02.
//

import RealmSwift
import Foundation

final class RecentlySearchedAddressModel: Object {
    @Persisted var address: String
    @Persisted var addressForSearchNextForecast: String
    @Persisted var longitude: String
    @Persisted var latitude: String
    @Persisted var createdAt: Double
    
    convenience init(
        address: String = "",
        addressForSearchNextForecast: String = "",
        longitude: String = "0",
        latitude: String = "0",
        createdAt: Double = Date().timeIntervalSince1970
    ) {
        self.init()
        self.address = address
        self.addressForSearchNextForecast = addressForSearchNextForecast
        self.longitude = longitude
        self.latitude = latitude
        self.createdAt = createdAt
    }
}

