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
    
    func setRadialGradient() {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.type = .radial
        gradient.colors = [
            UIColor(named: Colors.radialSuhu1)!.cgColor,
            UIColor(named: Colors.radialSuhu2)!.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = bounds
        layer.addSublayer(gradient)
    }
}
