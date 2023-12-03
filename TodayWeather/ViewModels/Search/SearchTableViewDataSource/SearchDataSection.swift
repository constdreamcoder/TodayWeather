//
//  SearchDataSection.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/12/01.
//

import Foundation
import RxDataSources

struct SearchDataSection {
    var items: [SearchedRegion]
}

extension SearchDataSection: SectionModelType {
    typealias Item = SearchedRegion
    
    init(
        original: SearchDataSection,
        items: [SearchedRegion]
    ) {
        self = original
        self.items = items
    }
}
  
