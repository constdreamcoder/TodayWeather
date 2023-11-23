//
//  DetailViewController.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/22.
//

import UIKit
import SnapKit

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
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    private lazy var nextForecaseHeaderView: NextForecastHeaderView = {
        let view = NextForecastHeaderView()
        return view
    }()
    
    private lazy var nextForecastTableView: NextForecastTableView = {
        let tableView = NextForecastTableView()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.setMainBackgroundColor()
        
        setupNavigationBar()
        setupSubViews()
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
            nextForecaseHeaderView,
            nextForecastTableView
        ].forEach { view.addSubview($0) }
        
        todayWeatherCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(50.0)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(210.0)
        }
        
        nextForecaseHeaderView.snp.makeConstraints {
            $0.top.equalTo(todayWeatherCollectionView.snp.bottom).offset(50.0)
            $0.leading.trailing.equalToSuperview().inset(30.0)
            $0.height.equalTo(40.0)
        }
        
        nextForecastTableView.snp.makeConstraints {
            $0.top.equalTo(nextForecaseHeaderView.snp.bottom).offset(40.0)
            $0.leading.trailing.equalToSuperview().inset(30.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
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

// MARK: - TodayWeather 관련 DataSource, Delegate
extension DetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TodayWeatherDetailCollectionViewHeaderView.headerIdentifier, for: indexPath) as? TodayWeatherDetailCollectionViewHeaderView else {
            return UICollectionReusableView()
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayWeatherDetailCollectionViewCell.identifier, for: indexPath) as? TodayWeatherDetailCollectionViewCell else { return UICollectionViewCell() }
            
        if indexPath.row == 2 {
            cell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        }
        
        return cell
    }
}

extension DetailViewController: UICollectionViewDelegate {
    
}

// MARK: - NextForecast 관련 DataSource, Delegate
extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NextForecastTableViewCell.identifier, for: indexPath) as? NextForecastTableViewCell else { return UITableViewCell() }
        return cell
    }
}

extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
