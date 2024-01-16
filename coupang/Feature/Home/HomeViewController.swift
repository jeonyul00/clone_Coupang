//
//  HomeViewController.swift
//  coupang
//
//  Created by 전율 on 2024/01/16.
//

import UIKit

class HomeViewController: UIViewController {
    
    enum Section:Int {
        case banner
        case horizontalProductItem
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // UICollectionView의 데이터 소스를 관리하는 변수. 섹션 타입은 'Section', 아이템 타입은 'UIImage'
    private var dataSource:UICollectionViewDiffableDataSource<Section,AnyHashable>?
    // 컬렉션 뷰의 레이아웃을 정의하는 클로저.
    private var compositionalLayout:UICollectionViewCompositionalLayout = {
        UICollectionViewCompositionalLayout { section, _ in
            switch Section(rawValue: section) {
            case .banner:
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
            case .horizontalProductItem:
                let itemSize: NSCollectionLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(117), heightDimension: .estimated(224))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 20, leading: 33, bottom: 0, trailing: 33)
                section.orthogonalScrollingBehavior = .continuous
                return section
            case .none:
                return nil
            }
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // CollectionViewCompositionalLayout: 섹션 > 그룹 > 아이템
        // 데이터 소스 초기화
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, viewModel in
            switch Section(rawValue: indexPath.section){
            case .banner:
                guard let viewModel = viewModel as? HomeBannerCollectionViewCellViewModel, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeBannerCollectionViewCell", for: indexPath) as? HomeBannerCollectionViewCell else { return .init() }
                cell.setViewModel(viewModel)
                return cell
            case .horizontalProductItem:
                guard let viewModel = viewModel as? HomeProductCollectionViewCellViewModel, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeProductCollectionViewCell", for: indexPath) as? HomeProductCollectionViewCell else { return .init() }
                cell.setViewModel(viewModel)
                return cell
            case .none:
                return .init()
            }
        })
        // Diffable Data Source 스냅샷을 생성
        var snapShot: NSDiffableDataSourceSnapshot<Section, AnyHashable> = NSDiffableDataSourceSnapshot<Section,AnyHashable>()
        // 스냅샷에 'banner' 섹션 추가
        snapShot.appendSections([.banner])
        // 'banner' 섹션에 이미지들을 아이템으로 추가
        snapShot.appendItems([
            HomeBannerCollectionViewCellViewModel(bannerImage: CPImage.silde1),
            HomeBannerCollectionViewCellViewModel(bannerImage: CPImage.silde2),
            HomeBannerCollectionViewCellViewModel(bannerImage: CPImage.silde3)], toSection: .banner)
        snapShot.appendSections([.horizontalProductItem])
        snapShot.appendItems([
            HomeProductCollectionViewCellViewModel(imageUrlString: "", title: "아이폰", reasonDiscountString: "쿠폰 할인", originalPrice: "1000000", discountPrice: "950000"),
            HomeProductCollectionViewCellViewModel(imageUrlString: "", title: "맥북", reasonDiscountString: "쿠폰 할인", originalPrice: "2000000", discountPrice: "1900000"),
            HomeProductCollectionViewCellViewModel(imageUrlString: "", title: "비전프로", reasonDiscountString: "쿠폰 할인", originalPrice: "6000000", discountPrice: "5900000"),
            HomeProductCollectionViewCellViewModel(imageUrlString: "", title: "아이패드", reasonDiscountString: "쿠폰 할인", originalPrice: "1000000", discountPrice: "900000")],toSection: .horizontalProductItem)
        
        // 데이터 소스에 스냅샷을 적용하여 데이터를 업데이트
        dataSource?.apply(snapShot)
        // 컬렉션 뷰의 레이아웃 설정
        collectionView.collectionViewLayout = compositionalLayout
    }
    
}
