//
//  NextForecastTableView.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/23.
//

import UIKit

final class NextForecastTableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NextForecastTableView {
    func configure() {
        register(NextForecastTableViewCell.self, forCellReuseIdentifier: NextForecastTableViewCell.identifier)
        
        backgroundColor = .clear
        separatorStyle = .none
        // TODO: 나중에 스크롤바 커스터 마이징하기
        indicatorStyle = .white
    }
}
