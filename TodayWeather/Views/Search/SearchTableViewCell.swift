//
//  SearchTableViewCell.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/25.
//

import UIKit
import SnapKit

final class SearchTableViewCell: UITableViewCell {
    static let identifier = String(describing: SearchTableViewCell.self)
    
    private lazy var timerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "clock")?.withTintColor(UIColor(named: Colors.textDark)!, renderingMode: .alwaysOriginal)
        return imageView
    }()
    
    private lazy var locationNameLabel: UILabel = {
       let label = UILabel()
        label.text = "서울 종로구 사직동"
        label.font = .systemFont(ofSize: 18.0, weight: .semibold)
        label.textColor = UIColor(named: Colors.textDark)
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
       let label = UILabel()
        label.text = "23°C / 34°C"
        label.font = .systemFont(ofSize: 14.0, weight: .semibold)
        label.textColor = UIColor(named: Colors.textDark)
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

private extension SearchTableViewCell {
    func configure() {
        [
            timerImageView,
            locationNameLabel,
            temperatureLabel
        ].forEach { addSubview($0) }
        
        timerImageView.snp.makeConstraints {
            $0.width.height.equalTo(20.0)
            $0.leading.equalToSuperview().inset(30.0)
            $0.centerY.equalToSuperview()
        }
        
        locationNameLabel.snp.makeConstraints {
            $0.leading.equalTo(timerImageView.snp.trailing).offset(28.0)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(temperatureLabel.snp.leading).offset(-5.0)
        }
        
        temperatureLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(30.0)
            $0.centerY.equalToSuperview()
        }
    }
}
