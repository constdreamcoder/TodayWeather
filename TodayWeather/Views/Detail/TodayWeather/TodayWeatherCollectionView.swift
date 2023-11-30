//
//  TodayWeatherCollectionView.swift
//  TodayWeather
//
//  Created by SUCHAN CHANG on 2023/11/23.
//

import UIKit

final class TodayWeatherCollectionView: UICollectionView {
    
    private lazy var layout = UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection? in
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2), heightDimension: .absolute(155.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets.trailing = 12.0
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(155.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets.leading = 12.0
        
        section.orthogonalScrollingBehavior = .continuous
        
        section.boundarySupplementaryItems = [
            .init(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50)), elementKind: TodayWeatherDetailCollectionViewHeaderView.headerViewOfKind, alignment: .topLeading)
        ]
        
        return section
    }
    
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        
        collectionViewLayout = layout

        backgroundColor = .clear
        
        alwaysBounceVertical = false
        alwaysBounceHorizontal = false
        
        register(TodayWeatherDetailCollectionViewHeaderView.self, forSupplementaryViewOfKind: TodayWeatherDetailCollectionViewHeaderView.headerViewOfKind, withReuseIdentifier: TodayWeatherDetailCollectionViewHeaderView.headerIdentifier)
        register(TodayWeatherDetailCollectionViewCell.self, forCellWithReuseIdentifier: TodayWeatherDetailCollectionViewCell.identifier)
    }
}
