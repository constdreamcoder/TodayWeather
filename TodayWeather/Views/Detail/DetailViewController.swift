//
//  DetailViewController.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/22.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class DetailViewController: UIViewController {
    
    private lazy var searchLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        // TODO: 사용자가 터치 시 색깔 정하기
        button.setImage(UIImage(named: Assets.loctionaIcon)?.withTintColor(.clear, renderingMode: .alwaysOriginal), for: .highlighted)
        button.setInsets(forContentPadding: UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10), imageTitlePadding: 5)
        button.setTitle("뒤로 가기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        // TODO: 사용자가 터치 시 색깔 정하기
        button.setTitleColor(.clear, for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 23.0)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return button
    }()
    
    private lazy var todayWeatherCollectionView: TodayWeatherCollectionView = {
        let collectionView = TodayWeatherCollectionView()
        return collectionView
    }()
    
    private var todayWeatherCollectionViewDataSource: RxCollectionViewSectionedReloadDataSource<TodayWeatherDataSection>!
    
    private lazy var nextForecastHeaderView: NextForecastHeaderView = {
        let view = NextForecastHeaderView()
        return view
    }()
    
    private lazy var nextForecastTableView: NextForecastTableView = {
        let tableView = NextForecastTableView()
        
        tableView.delegate = self
        
        return tableView
    }()
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.setMainBackgroundColor()
        
        setupNavigationBar()
        setupSubViews()
        
        updateViews()
    }
}

private extension DetailViewController {
    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: Assets.settingsIcon)?.withTintColor(.white, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(gotoSettings))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchLocationButton)
    }
    
    func setupSubViews() {
        [
            todayWeatherCollectionView,
            nextForecastHeaderView,
            nextForecastTableView
        ].forEach { view.addSubview($0) }
        
        todayWeatherCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(50.0)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(210.0)
        }
        
        nextForecastHeaderView.snp.makeConstraints {
            $0.top.equalTo(todayWeatherCollectionView.snp.bottom).offset(50.0)
            $0.leading.trailing.equalToSuperview().inset(30.0)
            $0.height.equalTo(40.0)
        }
        
        nextForecastTableView.snp.makeConstraints {
            $0.top.equalTo(nextForecastHeaderView.snp.bottom).offset(40.0)
            $0.leading.trailing.equalToSuperview().inset(30.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func updateViews() {
        // TodayWeatherCollectionView 설정
        todayWeatherCollectionViewDataSource = DetailViewModel.shared.configureCollectionViewDataSource()
        DetailViewModel.shared.todayWeatherDataSectionListObservable
            .bind(to: todayWeatherCollectionView.rx.items(dataSource: todayWeatherCollectionViewDataSource))
            .disposed(by: disposeBag)
        DetailViewModel.shared.bindDataToCollectionViewSection()
        
        // NextForecastTableView 설정
        DetailViewModel.shared.nextForecastListRelay
            .bind(to: nextForecastTableView.rx.items(cellIdentifier: NextForecastTableViewCell.identifier, cellType: NextForecastTableViewCell.self)) { row, element, cell in
                cell.bind(item: element)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - 이벤트 관련 메소드
private extension DetailViewController {
    @objc func gotoSettings() {
        print("설정으로 이동!!")
    }
    
    @objc func goBack() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - NextForecast 관련 DataSource, Delegate
extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
