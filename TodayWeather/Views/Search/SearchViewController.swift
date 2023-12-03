//
//  SearchViewController.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/25.
//

import UIKit
import SnapKit
import NMapsMap
import RxSwift
import RxCocoa
import RxDataSources
//import CoreLocation

final class SearchViewController: UIViewController {
    
    // TODO: - 추후 ViewModel로 이동시키기
    var mapView: NMFMapView?
    var locationManager: CLLocationManager = HomeViewModel.shared.locationManager
    var marker = NMFMarker()
    var currentLocationOfUser: NMGLatLng?
    var searchedLocation: NMGLatLng?
    var cameraUpdate: NMFCameraUpdate?
    var infoWindow: NMFInfoWindow?
    
    private lazy var searchTableView: UITableView = {
        let tableView = UITableView()
        
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
        searchBar.returnKeyType = .done
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
    
    private var searchTableViewDataSource: RxTableViewSectionedReloadDataSource<SearchDataSection>!
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setLocationManager()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SearchViewModel.shared.isSearchMode = false
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
        
        SearchViewModel.shared.userLocationRelay
            .subscribe { [weak self] userLocation in
                guard let weakSelf = self else { return }
                weakSelf.currentLocationOfUser = NMGLatLng(lat: userLocation[0], lng: userLocation[1])
                weakSelf.setupMarkerForCurrentLocationOfUser()
            }
            .disposed(by: disposeBag)
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
    
    func updateViews() {
        searchTableViewDataSource = SearchViewModel.shared.configureTableViewDataSource()
        SearchViewModel.shared.searchDataSectionListRelay
            .bind(to: searchTableView.rx.items(dataSource: searchTableViewDataSource))
            .disposed(by: disposeBag)
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
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // TODO: - SearchViewModel로 옮기기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAddress = SearchViewModel.shared.searchDataSectionListRelay.value[0].items[indexPath.row].address
        guard let longitude = Double(selectedAddress.x),
              let latitude = Double(selectedAddress.y)
        else { return }
         
        SearchViewModel.shared.getWeatherForecastInfosOfSelectedRegion(latitude: latitude, longitude: longitude)
    
        showInfoWindowOnMarker(latitude: latitude, longitude: longitude, address: selectedAddress.roadAddress)

        showTableView(isHidden: true)
        RecentlySearchedAddressService.shared.addNewlySearchedAddress(newAddress: selectedAddress)
        
        searchBar.resignFirstResponder()
    }
}

// Search Bar 관련 메소드
extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        showTableView(isHidden: false)
        if searchBar.text != "" {
            SearchViewModel.shared.searchAddressList()
        } else if searchBar.text == "" {
            SearchViewModel.shared.getRecentlySearchedResultList()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        SearchViewModel.shared.searchText = searchText
        SearchViewModel.shared.isSearchMode = false
        if searchText == "" {
            SearchViewModel.shared.getRecentlySearchedResultList()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("끝남")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            print("클릭")
            SearchViewModel.shared.isSearchMode = true
            SearchViewModel.shared.searchAddressList()
            searchBar.resignFirstResponder()
        }
    }
}

// MARK: - 사용자 위치 관련 메소드
extension SearchViewController {
    func setLocationManager() {
        locationManager.delegate = HomeViewModel.shared
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
        cameraUpdate?.animationDuration = 0.35
        cameraUpdate?.animation = .easeIn
        mapView?.moveCamera(cameraUpdate!)
    }
    
    /// 카메라 위치 리셋
    /// 왠만하면 카메라 위치 업데이트 후 리셋하기
    func resetCameraUpdate() {
        cameraUpdate = nil
    }
    
    // 지역 결과 지도에 표시
    func setupMarkerOnMap(latitude: Double, longitude: Double) {
        marker.position = NMGLatLng(lat: latitude, lng: longitude)
        marker.mapView = mapView
    }
    
    // 정보창 표시
    func showInfoWindowOnMarker(latitude: Double, longitude: Double, address: String) {

        resetInfoView()
        
        infoWindow = NMFInfoWindow()
        
        // 터치 이벤트 추가
        let handler = { [weak self,latitude, longitude] (overlay: NMFOverlay) -> Bool in
            guard let weakSelf = self else { return false }
            if let infoWindow = overlay as? NMFInfoWindow {
                print("터치됨")
                let detailVC = DetailViewController()
                weakSelf.navigationController?.pushViewController(detailVC, animated: true)
            }
            return true
        }
        infoWindow?.touchHandler = handler
        
        let dataSource = NMFInfoWindowDefaultTextSource.data()

        // TODO: - 성능 개선하기
        SearchViewModel.shared.infoWindowContentsRelay
            .take(1)
            .subscribe(onNext: { [weak self, dataSource] title in
                guard let weakSelf = self else { return }
                
                // 오늘 예보 및 내일 예보 데이터 호출
                DetailViewModel.shared.resetTodayWeatherForecastList(latitude: latitude, longitude: longitude)
                DetailViewModel.shared.setupNextForecastList(regIdForTemp: "21F20801", regIdForSky: "11D20000")
                
                // 마커 표시를 위한 설정
                weakSelf.setupMarkerOnMap(latitude: latitude, longitude: longitude)
                dataSource.title = title
                weakSelf.infoWindow?.dataSource = dataSource
                weakSelf.infoWindow?.open(with: weakSelf.marker)
            }, onCompleted: { [weak self, latitude, longitude, address] in
                guard let weakSelf = self else { return }
                weakSelf.searchBar.text = address
                SearchViewModel.shared.searchText = address
                weakSelf.updateCamera(latitude: latitude, longitude: longitude)
                weakSelf.resetCameraUpdate()
            })
            .disposed(by: disposeBag)
    }
    
    // 정보창 초기화
    func resetInfoView() {
        infoWindow?.close()
        infoWindow = nil
    }
}
