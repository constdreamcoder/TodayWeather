//
//  Reactive+Extensions.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/28.
//

import UIKit
import RxSwift

extension Reactive where Base: UIButton {
    /// `setTitle(_:for:)` 에 대한 Reactive wrapper
    public func title(for controlState: UIControl.State = []) -> Binder<String?> {
        Binder(self.base) { button, title in
            button.setTitle(title, for: controlState)
        }
    }
}
