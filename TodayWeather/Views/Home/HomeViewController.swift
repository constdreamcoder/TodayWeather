//
//  HomeViewController.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/20.
//

import UIKit
import SnapKit

final class HomeViewController: UIViewController {
    
    private lazy var searchLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: Assets.loctionaIcon)?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        // TODO: 사용자가 터치 시 색깔 정하기
        button.setImage(UIImage(named: Assets.loctionaIcon)?.withTintColor(.clear, renderingMode: .alwaysOriginal), for: .highlighted)
        button.setInsets(forContentPadding: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10), imageTitlePadding: 20)
        button.setTitle("서울 강서구", for: .normal)
        button.setTitleColor(.white, for: .normal)
        // TODO: 사용자가 터치 시 색깔 정하기
        button.setTitleColor(.clear, for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 23.0, weight: .bold)
        button.addTarget(self, action: #selector(gotoSearchLocations), for: .touchUpInside)
        return button
    }()
    
    private lazy var skyConditionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Assets.sunnyWeather)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var todayWeatherInfoView: TodayWeatherInfoStackView = {
        let view = TodayWeatherInfoStackView()
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        return view
    }()
    
    private lazy var forecastReportButton: UIButton = {
        let button = UIButton()
        button.layer.backgroundColor = UIColor.white.cgColor
        button.setTitle("예보 리포트", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18.0)
        button.setTitleColor(UIColor(named: Colors.textDark), for: .normal)
        // TODO: 사용자가 터치 시 색깔 정하기
        button.setTitleColor(.clear, for: .highlighted)
        button.layer.cornerRadius = 20.0
        button.addTarget(self, action: #selector(gotoSearchLocations), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.setMainBackgroundColor()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "bell")?.withTintColor(.white, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(gotoNotifications))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchLocationButton)
        
        setupViews()
    }
    
    @objc func gotoNotifications() {
        print("알림 센터로 이동")
    }
    
    @objc func gotoSearchLocations() {
        print("위치 검색으로 이동")
    }
}

private extension HomeViewController {
    func setupViews() {
        [
            skyConditionImageView,
            todayWeatherInfoView,
            forecastReportButton
        ].forEach { view.addSubview($0) }
        
        skyConditionImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(172.0)
        }
        
        todayWeatherInfoView.snp.makeConstraints {
            $0.top.equalTo(skyConditionImageView.snp.bottom).offset(40.0)
            $0.leading.trailing.equalToSuperview().inset(30.0)
        }
        
        forecastReportButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(36.0)
            $0.height.equalTo(64.0)
            $0.width.equalTo(220.0)
        }
    }
}

