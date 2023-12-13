//
//  ViewModelType.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 12/7/23.
//

import Foundation
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
        
    func transform(input: Input) -> Output
}

