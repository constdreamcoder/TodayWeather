//
//  NotificationViewController.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/24.
//

import UIKit
import SnapKit

final class NotificationViewController: UIViewController {
    
    private lazy var notificationTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: NotificationTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("노티피케이션")
        
        configure()
        setupTableView()
    }
    
    deinit {
        print("노티 사라짐")
    }
}

private extension NotificationViewController {
    func configure() {
        view.backgroundColor = .white
        navigationItem.title = "알림"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupTableView() {
        view.addSubview(notificationTableView)
        
        notificationTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    
}

extension NotificationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "새로운 알림"
        } else {
            return "이전 알림"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell else { return UITableViewCell() }
        return cell
    }
}

extension NotificationViewController: UITableViewDelegate {
    
}
