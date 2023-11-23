//
//  NextForecastHeaderView.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/23.
//

import UIKit
import SnapKit

final class NextForecastHeaderView: UIView {
    private lazy var nextForecastLabel: UILabel = {
       let label = UILabel()
        label.text = "다음 예보"
        label.font = .systemFont(ofSize: 24.0, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private lazy var calendarIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Assets.calendarIcon)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    init() {
        super.init(frame: .zero)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NextForecastHeaderView {
    func configure() {
        [
            nextForecastLabel,
            calendarIconImageView
        ].forEach { addSubview($0) }
        
        nextForecastLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(5.0)
        }
        
        calendarIconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(24.0)
        }
    }
}
