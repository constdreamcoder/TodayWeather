//
//  TodayWeatherDetailCollectionViewCell.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/22.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TodayWeatherDetailCollectionViewCell: UICollectionViewCell {
    static let identifier = String(describing: TodayWeatherDetailCollectionViewCell.self)
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "24°C"
        label.font = .systemFont(ofSize: 15.0)
        label.textColor = .white
        return label
    }()
    
    private lazy var skyConditionImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "cloud.moon.rain.fill")?.withRenderingMode(.alwaysOriginal)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "15:00"
        label.font = .systemFont(ofSize: 14.0)
        label.textColor = .white
        return label
    }()
    
    private lazy var todayWeatherInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
     
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(item: TodayWeatherDataSection.Item) {
        temperatureLabel.text = item.temperature + "°"
        // TODO: - 하늘 상태에 따른 skyConditionImageView 이미지 변경하기
        timeLabel.text = item.time
        switch item.skyCondition {
        case .clear:
            skyConditionImageView.image = UIImage(named: Assets.clearIcon)?.withRenderingMode(.alwaysOriginal)
        case .mostlyCloudy:
            skyConditionImageView.image = UIImage(named: Assets.mostlycloudyIcon)?.withRenderingMode(.alwaysOriginal)
        case .cloudy:
            skyConditionImageView.image = UIImage(named: Assets.cloudyIcon)?.withRenderingMode(.alwaysOriginal)
        }
       
    }
}

private extension TodayWeatherDetailCollectionViewCell {
    func configure() {
        layer.cornerRadius = 20

        [
            temperatureLabel,
            skyConditionImageView,
            timeLabel
        ].forEach { todayWeatherInfoStackView.addArrangedSubview($0) }
        
        addSubview(todayWeatherInfoStackView)
        
        skyConditionImageView.snp.makeConstraints {
            $0.width.height.equalTo(45.0)
        }
        
        todayWeatherInfoStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(13.0)
        }
    }
}
