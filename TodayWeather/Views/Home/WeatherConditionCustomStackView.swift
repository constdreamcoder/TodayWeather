//
//  WeatherConditionStackView.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/21.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class WeatherConditionCustomStackView: UIStackView {

    private var forecast: Forecast?
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        // TODO: 기본 이미지로 대체하기
        imageView.image = UIImage()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var windLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 18.0)
        label.textColor = .white
        return label
    }()
    
    private lazy var verticalDivierLabel: UILabel = {
        let label = UILabel()
        label.text = "|"
        label.font = .systemFont(ofSize: 18.0)
        label.textColor = .white
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 18.0)
        label.textColor = .white
        return label
    }()
    
    private var disposeBag = DisposeBag()
    
    init(forecast: Forecast) {
        super.init(frame: .zero)
        
        self.forecast = forecast
        
        initialize()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension WeatherConditionCustomStackView {
    func initialize() {
        
        switchForecast()
        
        axis = .horizontal
        
        spacing = 20.0
        
        alignment = .leading
        
        [
            iconImageView,
            windLabel,
            verticalDivierLabel,
            valueLabel
        ].forEach { addArrangedSubview($0) }
        
        iconImageView.snp.makeConstraints {
            $0.width.height.equalTo(24.0)
        }
        
        windLabel.setContentHuggingPriority(.init(1000), for: .horizontal)
        verticalDivierLabel.setContentHuggingPriority(.init(1000), for: .horizontal)
    }
    
    func switchForecast() {
        switch forecast {
        case .windy:
            iconImageView.image = UIImage(named: Assets.windIcon)
            windLabel.text = "바람"
            HomeViewModel.shared.currentWeatherConditionObservable
                .map { "\($0.windSpeed) m/s" }
                .bind(to: valueLabel.rx.text)
                .disposed(by: disposeBag)
        case .humidity:
            iconImageView.image = UIImage(named: Assets.humidityIcon)
            windLabel.text = "습도"
            HomeViewModel.shared.currentWeatherConditionObservable
                .map { "\(Int($0.humidity)) %" }
                .bind(to: valueLabel.rx.text)
                .disposed(by: disposeBag)
        default:
            break
        }
    }
}
