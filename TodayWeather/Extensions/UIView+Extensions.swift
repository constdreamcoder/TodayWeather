//
//  UIView+Extensions.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/20.
//

import UIKit

extension UIView {
    func setMainBackgroundColor() {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [
            UIColor(named: Colors.linearBlueBG1)!.cgColor,
            UIColor(named: Colors.linearBlueBG2)!.cgColor
        ]
        gradient.frame = bounds
        layer.addSublayer(gradient)
    }
}
