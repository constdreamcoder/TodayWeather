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
    var marker = NMFMarker()
    var currentLocationOfUser: NMGLatLng?
    var searchedLocation: NMGLatLng?
    var cameraUpdate: NMFCameraUpdate?
    var infoWindow: NMFInfoWindow?
    
    private lazy var leftBarButton: UIButton = {
        let button = UIButton()
        button.setImage(
            UIImage(systemName: "arrow.left")?
                .withTintColor(
                    UIColor(named: Colors.textDark)!,
                    renderingMode: .alwaysOriginal),
            for: .normal
        )
        button.setTitle("", for: .normal)
        return button
    }()
    
    private lazy var searchTableView: UITableView = {
        let tableView = UITableView()
                
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        
        tableView.isHidden = true
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 60
        
        return tableView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.returnKeyType = .done
        searchBar.placeholder = "지역명을 입력해보세요"
        searchBar.tintColor = .black
        searchBar.setImage(UIImage(), for: UISearchBar.Icon.search, state: .normal)
        searchBar.searchTextField.backgroundColor = .clear
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
        return button
    }()
    
    private var searchTableViewDataSource: RxTableViewSectionedReloadDataSource<SearchDataSection>!
    
    private var searchViewModel: SearchViewModel
    private var detailViewModel: DetailViewModel
    
    private lazy var input = SearchViewModel.Input(
        goBackBtnTapped: leftBarButton.rx.tap.asDriver(),
        searchBarTextInput: searchBar.rx.text.orEmpty.asDriver(),
        textDidBeginEditing: searchBar.rx.textDidBeginEditing.asDriver(),
        textDidEndEditing: searchBar.rx.textDidEndEditing.asDriver(),
        searchButtonClicked: searchBar.rx.searchButtonClicked.asDriver(),
        addressSelected: searchTableView.rx.itemSelected.asDriver(),
        moveToUserBtnTapped: moveToUserLocationButton.rx.tap.asDriver()
    )
    private lazy var output = searchViewModel.transform(input: input)
    
    private var disposeBag = DisposeBag()

    init(
        searchViewModel: SearchViewModel,
        detailViewModel: DetailViewModel
    ) {
        self.searchViewModel = searchViewModel
        self.detailViewModel = detailViewModel
        
        super.init(nibName: nil, bundle: nil)
        
        searchViewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchViewModel.isSearchMode = false
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
        navigationItem.leftBarButtonItem = .init(customView: leftBarButton)
        navigationItem.titleView = searchBar
        navigationItem.titleView?.backgroundColor = .white
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "mic.fill")?.withTintColor(UIColor(named: Colors.textDark)!, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(voiceInput))
    }
    
    func updateViews() {
        output.userLocation
            .drive(onNext: { [weak self] userLocation in
                guard let weakSelf = self else { return }
                weakSelf.currentLocationOfUser = NMGLatLng(lat: userLocation.lat, lng: userLocation.lng)
                weakSelf.setupMarkerForCurrentLocationOfUser()
            })
            .disposed(by: disposeBag)
        
        searchTableViewDataSource = searchViewModel.configureTableViewDataSource()
        output.searchDataSectionList
            .drive(searchTableView.rx.items(dataSource: searchTableViewDataSource))
            .disposed(by: disposeBag)
        
        output.goBackToHome
            .drive()
            .disposed(by: disposeBag)
        
        output.textDidBeginEditing
            .drive()
            .disposed(by: disposeBag)
        
        output.textDidEndEditing
            .drive()
            .disposed(by: disposeBag)
        
        output.searchButtonClicked
            .drive()
            .disposed(by: disposeBag)
        
        output.addressSelected
            .drive()
            .disposed(by: disposeBag)
        
        output.moveToUser
            .drive()
            .disposed(by: disposeBag)
    }
}

// MARK: - 이벤트 관련 메소드
extension SearchViewController: SearchUserEvent {
    func goBackToHome() {
        navigationController?.popViewController(animated: true)
    }
    
    func resignSearchBarFromFirstResponder() {
        searchBar.resignFirstResponder()
    }
    
    func showTableView(isHidden: Bool) {
        searchTableView.isHidden = isHidden
        bottomSupplimentaryView.isHidden = isHidden
    }
    
    // MARK: - 맵 표시 메소드
    // 정보창 표시
    func showInfoWindowOnMarker(latitude: Double, longitude: Double, address: Address, addressForSearchNextForecast: String) {
        
        resetInfoView()
        
        infoWindow = NMFInfoWindow()
        
        // 터치 이벤트 추가
        let handler = { [weak self] (overlay: NMFOverlay) -> Bool in
            guard let weakSelf = self else { return false }
            if let infoWindow = overlay as? NMFInfoWindow {
                let detailVC = DetailViewController(detailViewModel: weakSelf.detailViewModel)
                weakSelf.navigationController?.pushViewController(detailVC, animated: true)
            }
            return true
        }
        infoWindow?.touchHandler = handler
        
        let dataSource = NMFInfoWindowDefaultTextSource.data()
        
        DispatchQueue.global().async { [weak self, address] in
            guard let weakSelf = self else { return }
            let convertedXY = ConvertXY().convertGRID_GPS(mode: .TO_GRID, lat_X: latitude, lng_Y: longitude)
           
            print("address: \(address.roadAddress)")
            var koreanFullAdress: String = ""
            if address.addressElements.isEmpty {
                // 최근 검색을 조회하는 경우
                koreanFullAdress = addressForSearchNextForecast
            } else {
                // 주소로 검색한 경우
                koreanFullAdress = address.addressElements[0].shortName + " " + address.addressElements[1].shortName
            }
            print("koreanFullAdress: \(koreanFullAdress)")
            weakSelf.detailViewModel.setupNextForecastList(koreanFullAdress: addressForSearchNextForecast, latitude: latitude, longitude: longitude)
            
            // 오늘 예보 및 내일 예보 데이터 호출
            weakSelf.detailViewModel.setupTodayWeatherList(nx: convertedXY.x, ny: convertedXY.y)
        }
        
        // TODO: - 성능 개선하기
        output.infoWindowContents.asObservable()
            .observe(on: MainScheduler.instance)
            .catchAndReturn("")
            .take(1)
            .bind(onNext: { [weak self, dataSource, latitude, longitude, address] title in
                guard let weakSelf = self else { return }
                
                // 마커 표시를 위한 설정
                weakSelf.setupMarkerOnMap(latitude: latitude, longitude: longitude)
                dataSource.title = title
                weakSelf.infoWindow?.dataSource = dataSource
                weakSelf.infoWindow?.open(with: weakSelf.marker)
                
                weakSelf.searchBar.text = address.roadAddress
                weakSelf.output.searchedTextData.accept(address.roadAddress)
                weakSelf.updateCamera(latitude: latitude, longitude: longitude)
                weakSelf.resetCameraUpdate()
                print("drive")
            })
            .disposed(by: disposeBag)
    }
    
    func moveToUser() {
        updateCamera(latitude: currentLocationOfUser!.lat, longitude: currentLocationOfUser!.lng)
        resetCameraUpdate()
    }
}

private extension SearchViewController {
    @objc func voiceInput() {
        print("마이크로 입력")
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
    
    
    // 정보창 초기화
    func resetInfoView() {
        infoWindow?.close()
        infoWindow = nil
    }
}
