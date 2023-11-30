//
//  TodayWeatherInfoStackView.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/21.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum Forecast {
    case windy
    case humidity
}

final class TodayWeatherInfoStackView: UIStackView {
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘, _월 _일"
        label.textColor = .white
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "_°C"
        label.font = .systemFont(ofSize: 100.0)
        label.textColor = .white
        return label
    }()
    
    private lazy var skyConditionLabel: UILabel = {
        let label = UILabel()
        label.text = "_"
        label.font = .systemFont(ofSize: 24.0)
        label.textColor = .white
        return label
    }()
    
    private lazy var todayWindInfoStackView: WeatherConditionCustomStackView = {
        let stackView = WeatherConditionCustomStackView(forecast: .windy)
        return stackView
    }()
    
    private lazy var todayHumidityInfoStackView: WeatherConditionCustomStackView = {
        let stackView = WeatherConditionCustomStackView(forecast: .humidity)
        return stackView
    }()
    
    private var disposeBag = DisposeBag()
        
    init() {
        super.init(frame: .zero)
        
        setupSubViews()
        updateViews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TodayWeatherInfoStackView {
    func setupSubViews() {
        axis = .vertical
        
        alignment = .center
        
        spacing = 15.0
        
        // Inset 설정
        layoutMargins = UIEdgeInsets(top: 17, left: 0, bottom: 17, right: 0)
        isLayoutMarginsRelativeArrangement = true
        
        layer.cornerRadius = 20.0
        
        [
            dateLabel,
            temperatureLabel,
            skyConditionLabel,
            todayWindInfoStackView,
            todayHumidityInfoStackView
        ].forEach { addArrangedSubview($0) }
        
        todayWindInfoStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(67.0)
        }
        
        todayHumidityInfoStackView.snp.makeConstraints {
            $0.leading.equalTo(todayWindInfoStackView.snp.leading)
        }
    }
    
    func updateViews() {
        HomeViewModel.shared.currentWeatherConditionObservable
            .map { "오늘, \($0.todayDate.getTodayDate)" }
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        HomeViewModel.shared.currentWeatherConditionObservable
            .map { "\($0.temperature)°C" }
            .bind(to: temperatureLabel.rx.text)
            .disposed(by: disposeBag)
        
        HomeViewModel.shared.currentWeatherConditionObservable
            .map { $0.skyCondition.convertToKorean }
            .bind(to: skyConditionLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
