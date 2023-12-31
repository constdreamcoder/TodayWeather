//
//  HomeViewController.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/20.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import CoreLocation

final class HomeViewController: UIViewController {
    private lazy var searchLocationButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        button.setImage(UIImage(named: Assets.loctionaIcon)?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        // TODO: 사용자가 터치 시 색깔 정하기
        button.setImage(UIImage(named: Assets.loctionaIcon)?.withTintColor(.clear, renderingMode: .alwaysOriginal), for: .highlighted)
        button.setInsets(forContentPadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), imageTitlePadding: 20)
        button.setTitle("_", for: .normal)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(.white, for: .normal)
        // TODO: 사용자가 터치 시 색깔 정하기
        button.setTitleColor(.clear, for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 23.0, weight: .bold)
        return button
    }()
    
    // TODO: - 하늘 상태에 따른 이미지 구현하기
    private lazy var skyConditionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Assets.sun)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var todayWeatherInfoView: TodayWeatherInfoStackView = {
        let view = TodayWeatherInfoStackView(homeViewModel: homeViewModel, output: output)
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
        return button
    }()
    
    private var homeViewModel: HomeViewModel
    private var detailViewModel: DetailViewModel?
    private lazy var input = HomeViewModel.Input(
        goToNMapTapped: searchLocationButton.rx.tap.asDriver(),
        goToDetailVCTapped: forecastReportButton.rx.tap.asDriver()
    )
    private lazy var output = homeViewModel.transform(input: input)
    private var disposeBag = DisposeBag()
    
    init(homeViewModel: HomeViewModel) {
        self.homeViewModel = homeViewModel
        super.init(nibName: nil, bundle: nil)
        self.homeViewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.setMainBackgroundColor()
        
        setupNavigationBar()
        setupViews()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        output.triggerForecastReportAPIs
            .bind(onNext: { [weak self] userLocation, koreanFullAdress in
                guard let weakSelf = self else { return }
                guard userLocation.x > 0 && userLocation.y > 0,
                      koreanFullAdress != "" else { return }
                
                weakSelf.detailViewModel = nil
                weakSelf.detailViewModel = DetailViewModel(
                    realtimeForcastService: RealtimeForecastService(),
                    dailyWeatherForecastService: DailyWeatherForecastService(),
                    temperatureForecastService: TemperatureForecastService(),
                    skyConditionForecastService: SkyConditionForecastService(), regionCodeSearchingService: RegionCodeSearchingService(), 
                    userLocation: userLocation,
                    koreanFullAdress: koreanFullAdress
                )
            })
            .disposed(by: disposeBag)
    }
}

private extension HomeViewController {
    func setupNavigationBar() {
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "bell")?.withTintColor(.white, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(gotoNotifications))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchLocationButton)
    }
    
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
    
    func updateViews() {
        output.currentAddressOfLocation
            .drive(searchLocationButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        output.goToSearchVC
            .drive()
            .disposed(by: disposeBag)
        
        output.goToDetailVC
            .drive()
            .disposed(by: disposeBag)
        
        output.currentWeatherCondition
            .map { currentWeatherCondition -> UIImage? in
                switch currentWeatherCondition.skyCondition {
                case .clear:
                    return UIImage(named: Assets.sun)
                case .mostlyCloudy:
                    return UIImage(named: Assets.sunClouds)
                case .cloudy:
                    return UIImage(named: Assets.clouds)
                }
            }.drive(skyConditionImageView.rx.image)
            .disposed(by: disposeBag)
    }
}

// MARK: - 이벤트 관련 메소드
private extension HomeViewController {
    @objc func gotoNotifications() {
        let notificationVC = UINavigationController(rootViewController: NotificationViewController())
        if let sheet = notificationVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 30.0
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        navigationController?.present(notificationVC, animated: true, completion: nil)
    }
    
    @objc func gotoSearchLocations() {
        
    }
}

extension HomeViewController: HomeNavigator {
    func gotoSearchVC() {
        print("눌림")
        guard let detailViewModel = detailViewModel else { return }
        guard let userLocation = homeViewModel.userLocation else { return }
        let searchViewModel = SearchViewModel(
            geolocationService: GeolocationService(),
            dailyWeatherForecastService: DailyWeatherForecastService(),
            realtimeForcastService: RealtimeForecastService(),
            recentlySearchedAddressService: RecentlySearchedAddressService(),
            userLocation: userLocation
        )
        let searchVC = SearchViewController(
            searchViewModel: searchViewModel,
            detailViewModel: detailViewModel
        )
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    func gotoDetailVC() {
        guard let detailViewModel = detailViewModel else { return }
        guard let userLocation = homeViewModel.userLocation else { return }
        let detailVC = UINavigationController(rootViewController: DetailViewController(detailViewModel: detailViewModel))
        detailVC.modalPresentationStyle = .overFullScreen
        present(detailVC, animated: true, completion: nil)
    }
}
