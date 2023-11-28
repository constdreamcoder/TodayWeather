//
//  SearchViewController.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/25.
//

import UIKit
import SnapKit
import NMapsMap
import CoreLocation

final class SearchViewController: UIViewController {
    
    // TODO: - 추후 ViewModel로 이동시키기
    var mapView: NMFMapView?
    var locationManager = CLLocationManager()
    var marker: NMFMarker?
    var currentLocationOfUser: NMGLatLng?
    var searchedLocation: NMGLatLng?
    var cameraUpdate: NMFCameraUpdate?
    
    private lazy var searchTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        
        tableView.isHidden = true
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        return tableView
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.placeholder = "지역명을 입력해보세요"
        searchBar.tintColor = .black
        searchBar.setImage(UIImage(), for: UISearchBar.Icon.search, state: .normal)
        searchBar.searchTextField.backgroundColor = UIColor.clear
        return searchBar
    }()
    
    private lazy var bottomSupplimentaryView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var moveToUserLocationButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 48 / 2
        button.setImage(UIImage(named: Assets.focusIcon)?.withTintColor(UIColor(named: Colors.textDark)!, renderingMode: .alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleToFill
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(moveToUser), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setLocationManager()
    }
}

// MARK: - UI 관련
private extension SearchViewController {
    func configure() {
        createMapView()
        
        [
            searchTableView,
            bottomSupplimentaryView,
            moveToUserLocationButton
        ].forEach { view.addSubview($0) }
        
        view.backgroundColor = .white

        setupNavigationBar()
        
        bottomSupplimentaryView.layer.cornerRadius = 30
        bottomSupplimentaryView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        bottomSupplimentaryView.layer.masksToBounds = true
        
        searchTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.lessThanOrEqualTo(240)
        }
        
        bottomSupplimentaryView.snp.makeConstraints {
            $0.top.equalTo(searchTableView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(35.0)
        }
        
        moveToUserLocationButton.snp.makeConstraints {
            $0.width.height.equalTo(48.0)
            $0.trailing.bottom.equalToSuperview().inset(36.0)
        }
    }
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left")?.withTintColor(UIColor(named: Colors.textDark)!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(goBackToHome))
        navigationItem.titleView = searchBar
        navigationItem.titleView?.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "mic.fill")?.withTintColor(UIColor(named: Colors.textDark)!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(voiceInput))
    }
    
    func showTableView(isHidden: Bool) {
        searchTableView.isHidden = isHidden
        bottomSupplimentaryView.isHidden = isHidden
    }
}

// MARK: - 이벤트 관련 메소드
private extension SearchViewController {
    @objc func goBackToHome() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func voiceInput() {
        print("마이크로 입력")
    }
    
    @objc func moveToUser() {
        updateCamera(latitude: currentLocationOfUser!.lat, longitude: currentLocationOfUser!.lng)
        resetCameraUpdate()
    }
}

// MARK: TableView 관련 메소드
extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "최근 검색"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as? SearchTableViewCell else { return UITableViewCell()}
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// Search Bar 관련 메소드
extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        showTableView(isHidden: false)
    }
}

// MARK: - 사용자 위치 관련 메소드
extension SearchViewController: CLLocationManagerDelegate {
    func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.global().async { [weak self] in
            guard let weakSelf = self else { return }
            let locationServiceEnabled = CLLocationManager.locationServicesEnabled()
            if locationServiceEnabled {
                weakSelf.locationManager.startUpdatingLocation()
            } else {
                print("위치 서비스 허용 off")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("위치 업데이트")
            print("위도 : \(location.coordinate.latitude)")
            print("경도 : \(location.coordinate.longitude)")
            currentLocationOfUser = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
            setupMarkerForCurrentLocationOfUser()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
    
    // 사용자 위치 접근 상태 확인 메소드
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse && manager.authorizationStatus == .authorizedAlways {
            
        }
    }
}

// MARK: - 맵 표시 관련 메소드
private extension SearchViewController {
    // 맵 생성
    func createMapView() {
        mapView = NMFMapView(frame: view.frame)
        view.addSubview(mapView!)
    }
    
    // 현재 사용자 위치 표시
    func setupMarkerForCurrentLocationOfUser() {
        let locationOverlay = mapView?.locationOverlay
        locationOverlay?.hidden = false
        locationOverlay?.location = currentLocationOfUser!
        
        updateCamera(latitude: currentLocationOfUser!.lat, longitude: currentLocationOfUser!.lng)
        resetCameraUpdate()
    }
    
    // 카메라 위치 업데이트
    func updateCamera(latitude: Double, longitude: Double) {
        cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude))
        cameraUpdate?.animation = .easeIn
        mapView?.moveCamera(cameraUpdate!)
    }
    
    /// 카메라 위치 리셋
    /// 왠만하면 카메라 위치 업데이트 후 리셋하기
    func resetCameraUpdate() {
        cameraUpdate = nil
    }
    
    // 지역 결과 지도에 표시
    func setupMarkerOnMap() {
        marker = NMFMarker()
        marker?.position = currentLocationOfUser!
        marker?.mapView = mapView
    }
}
