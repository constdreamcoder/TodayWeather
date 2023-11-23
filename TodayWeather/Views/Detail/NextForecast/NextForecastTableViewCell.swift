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
        label.text = "9월 13일"
        label.font = .systemFont(ofSize: 18.0)
        label.textColor = .white
        return label
    }()
    
    private lazy var forecastImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "cloud.sun.rain.fill")?.withRenderingMode(.alwaysOriginal)
        imageView.contentMode = .scaleAspectFill
        return imageView
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
}

private extension NextForecastTableViewCell {
    func configure() {
        
        backgroundColor = .clear
        selectionStyle = .none
        
        [
            dateLabel,
            forecastImageView,
            temperatureLabel
        ].forEach { addSubview($0) }
        
        dateLabel.snp.makeConstraints {
            $0.centerY.leading.equalToSuperview()
        }
        
        forecastImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(30.0)
        }
        
        temperatureLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(40.0)
        }
    }
}
