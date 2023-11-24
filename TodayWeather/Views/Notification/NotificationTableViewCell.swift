//
//  NotificationTableViewCell.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/24.
//

import UIKit
import SnapKit

final class NotificationTableViewCell: UITableViewCell {
    static let identifier = String(describing: NotificationTableViewCell.self)

    private lazy var skyConditionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "sun.max.fill")?.withTintColor(UIColor(named: Colors.textDark)!, renderingMode: .alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var skyConditionContainerView: UIView = {
        let view = UIView()
        view.addSubview(skyConditionImageView)
        return view
    }()
    
    private lazy var createdAtLabel: UILabel = {
        let label = UILabel()
        label.text = "10분 전"
        label.font = .systemFont(ofSize: 12.0)
        label.textColor = UIColor(named: Colors.textDark)
        return label
    }()
    
    private lazy var notificationLabel: UILabel = {
        let label = UILabel()
        label.text = "날씨가 화창한 날에는 자외선 차단제를 착용하는 것이 좋습니다."
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 14.0)
        label.textColor = UIColor(named: Colors.textDark)
        return label
    }()
    
    private lazy var middleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        [
            createdAtLabel,
            notificationLabel
        ].forEach { stackView.addArrangedSubview($0) }
        stackView.layoutMargins = UIEdgeInsets(top: 15, left: 0, bottom: 20, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var extensionIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Assets.upIcon)?.withTintColor(UIColor(named: Colors.textDark)!, renderingMode: .alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var extensionIconContainerView: UIView = {
        let view = UIView()
        view.addSubview(extensionIconImageView)
        return view
    }()
    
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        [
            skyConditionContainerView,
            middleStackView,
            extensionIconContainerView
        ].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NotificationTableViewCell {
    func configure() {
        addSubview(containerStackView)
        
        skyConditionImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(24.0)
        }
        
        skyConditionContainerView.snp.makeConstraints {
            $0.width.height.equalTo(96.0)
        }
        
        notificationLabel.setContentHuggingPriority(.init(1000), for: .vertical)
        
        extensionIconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(24.0)
        }
        
        extensionIconContainerView.snp.makeConstraints {
            $0.width.height.equalTo(96.0)
        }
        
        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
