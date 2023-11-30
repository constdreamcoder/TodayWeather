//
//  TodayWeatherDetailCollectionViewHeaderView.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/23.
//

import UIKit
import SnapKit

final class TodayWeatherDetailCollectionViewHeaderView: UICollectionReusableView {
    static let headerViewOfKind = String(describing: TodayWeatherDetailCollectionViewHeaderView.self) + "OfKind"
    static let headerIdentifier = String(describing: TodayWeatherDetailCollectionViewHeaderView.self)
    
    private lazy var todayLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘"
        label.font = .systemFont(ofSize: 24.0, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private lazy var todayDateLabel: UILabel = {
        let label = UILabel()
        label.text = Date().getTodayDate
        label.font = .systemFont(ofSize: 18.0)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TodayWeatherDetailCollectionViewHeaderView {
    func configure() {
        [
            todayLabel,
            todayDateLabel
        ].forEach { addSubview($0) }
        
        todayLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(15.0)
        }
        
        todayDateLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(27.0)
        }
    }
}
