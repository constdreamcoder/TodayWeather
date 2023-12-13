//
//  NextForecastTableViewCell.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/23.
//

import UIKit
import SnapKit

class NextForecastTableViewCell: UITableViewCell {
    static let identifier = String(describing: NextForecastTableViewCell.self)
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 18.0)
        label.textColor = .white
        return label
    }()
    
    private lazy var forecastAMImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "cloud.sun.rain.fill")?.withRenderingMode(.alwaysOriginal)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var forecastPMImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "cloud.sun.rain.fill")?.withRenderingMode(.alwaysOriginal)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var forecastImageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 7
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        [
            forecastAMImageView,
            forecastPMImageView
        ].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "21°C"
        label.font = .systemFont(ofSize: 18.0)
        label.textColor = .white
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(item: NextForecastItem) {
        guard let date = item.date,
              let minTemperature = item.temperatureItem?.min,
              let maxTemperature = item.temperatureItem?.max
        else { return }
        dateLabel.text = date.getTodayDate
        temperatureLabel.text = "\(minTemperature)° / \(maxTemperature)°"

        switch item.skyConditionItem?.skyConditionAM?.convertToSkyCondition {
            case .mostlyCloudy:
                forecastAMImageView.image = UIImage(named: Assets.mostlycloudyIcon)?.withRenderingMode(.alwaysOriginal)
            case .cloudy:
                forecastAMImageView.image = UIImage(named: Assets.cloudyIcon)?.withRenderingMode(.alwaysOriginal)
            case .clear, .none:
                forecastAMImageView.image = UIImage(named: Assets.clearIcon)?.withRenderingMode(.alwaysOriginal)
        }
        
        switch item.skyConditionItem?.skyConditionPM?.convertToSkyCondition {
        case .mostlyCloudy:
            forecastPMImageView.image = UIImage(named: Assets.mostlycloudyIcon)?.withRenderingMode(.alwaysOriginal)
        case .cloudy:
            forecastPMImageView.image = UIImage(named: Assets.cloudyIcon)?.withRenderingMode(.alwaysOriginal)
        case .clear, .none:
            forecastPMImageView.image = UIImage(named: Assets.clearIcon)?.withRenderingMode(.alwaysOriginal)
        }
    }
}

private extension NextForecastTableViewCell {
    func configure() {
        
        backgroundColor = .clear
        selectionStyle = .none
        
        [
            dateLabel,
            forecastImageStackView,
            temperatureLabel
        ].forEach { addSubview($0) }
        
        dateLabel.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
        }
        
        forecastAMImageView.snp.makeConstraints {
            $0.width.height.equalTo(30.0)
        }
        
        forecastPMImageView.snp.makeConstraints {
            $0.width.height.equalTo(30.0)
        }
        
        forecastImageStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        temperatureLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(30.0)
        }
    }
}
