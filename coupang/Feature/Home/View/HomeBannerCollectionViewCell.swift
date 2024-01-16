//
//  HomeBannerCollectionViewCell.swift
//  coupang
//
//  Created by 전율 on 2024/01/16.
//

import UIKit
import Kingfisher

struct HomeBannerCollectionViewCellViewModel:Hashable {
    let bannerImageUrl:String
}

class HomeBannerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setViewModel(_ viewModel:HomeBannerCollectionViewCellViewModel){
        imageView.kf.setImage(with: URL(string: viewModel.bannerImageUrl))
    }
}

extension HomeBannerCollectionViewCell {
    static func bannerLayout() -> NSCollectionLayoutSection {
        // 아이템 크기 정의
        let itemSize: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        // 정의한 크기를 가지는 아이템 생성
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // 그룹 크기 정의
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(165 / 393))
        // 가로 방향 그룹을 생성하고 아이템 추가
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        // 위에서 정의한 그룹을 포함하는 섹션을 생성
        let section = NSCollectionLayoutSection(group: group)
        // 섹션의 스크롤 동작을 그룹 페이징으로 설정
        section.orthogonalScrollingBehavior = .groupPaging
        // 컬렉션 뷰의 레이아웃 반환
        return section
    }
}
