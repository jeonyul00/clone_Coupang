//
//  HomeViewController.swift
//  coupang
//
//  Created by 전율 on 2024/01/16.
//

import UIKit

class HomeViewController: UIViewController {
    
    enum Section {
        case banner
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // UICollectionView의 데이터 소스를 관리하는 변수. 섹션 타입은 'Section', 아이템 타입은 'UIImage'
    private var dataSource:UICollectionViewDiffableDataSource<Section,UIImage>?
    // 컬렉션 뷰의 레이아웃을 정의하는 클로저.
    private var compositionalLayout:UICollectionViewCompositionalLayout = {
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
        return UICollectionViewCompositionalLayout(section: section)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let images: [UIImage] = [CPImage.silde1, CPImage.silde2, CPImage.silde3]
        
        // 데이터 소스 초기화
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeBannerCollectionViewCell", for: indexPath) as! HomeBannerCollectionViewCell
            cell.setImage(itemIdentifier)
            return cell
        })
        // Diffable Data Source 스냅샷을 생성
        var snapShot: NSDiffableDataSourceSnapshot<Section, UIImage> = NSDiffableDataSourceSnapshot<Section,UIImage>()
        // 스냅샷에 'banner' 섹션 추가
        snapShot.appendSections([.banner])
        // 'banner' 섹션에 이미지들을 아이템으로 추가
        snapShot.appendItems(images, toSection: .banner)
        // 데이터 소스에 스냅샷을 적용하여 데이터를 업데이트
        dataSource?.apply(snapShot)
        // 컬렉션 뷰의 레이아웃 설정
        collectionView.collectionViewLayout = compositionalLayout
    }
    
}
