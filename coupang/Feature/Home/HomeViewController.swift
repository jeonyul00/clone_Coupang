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
        case verticalProductItem
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // UICollectionView의 데이터 소스를 관리하는 변수. 섹션 타입은 'Section', 아이템 타입은 'UIImage'
    private var dataSource:UICollectionViewDiffableDataSource<Section,AnyHashable>?
    // 컬렉션 뷰의 레이아웃을 정의하는 클로저.
    private var compositionalLayout:UICollectionViewCompositionalLayout = setCompositinalLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setDataSource()
        
        // 컬렉션 뷰의 레이아웃 설정
        collectionView.collectionViewLayout = compositionalLayout
    }
    
    private static func setCompositinalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { section, _ in
            switch Section(rawValue: section) {
            case .banner:
                return HomeBannerCollectionViewCell.bannerLayout()
            case .horizontalProductItem:
                return HomeProductCollectionViewCell.horizontalProductItemLayout()
            case .verticalProductItem:
                return HomeProductCollectionViewCell.VerticalProductItemLayout()
            case .none:
                return nil
            }
        }
    }
    
    private func loadData() {
        Task {
            do{
                let response = try await NetWorkService.shared.getHomeData()
                let bannerViewModels = response.banners.map { HomeBannerCollectionViewCellViewModel(bannerImageUrl: $0.imageUrl) }
                let horizontalProductViewModels = response.horizontalProducts.map { HomeProductCollectionViewCellViewModel(imageUrlString: $0.imageUrl, title: $0.title, reasonDiscountString: $0.discount, originalPrice: "\($0.originalPrice)", discountPrice: "\($0.discountPrice)") }
                let verticalProductViewModels = response.verticalProducts.map { HomeProductCollectionViewCellViewModel(imageUrlString: $0.imageUrl, title: $0.title, reasonDiscountString: $0.discount, originalPrice: "\($0.originalPrice)", discountPrice: "\($0.discountPrice)") }
                
                applySnapShot(bannerViewModels: bannerViewModels, horizontalProductViewModels: horizontalProductViewModels, verticalProductViewModels: verticalProductViewModels)
            } catch {
                print(error)
            }
            
        }
        
    }
    
    private func setDataSource() {
        // CollectionViewCompositionalLayout: 섹션 > 그룹 > 아이템
        // 데이터 소스 초기화
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, viewModel in
            switch Section(rawValue: indexPath.section){
            case .banner:
                return self?.bannerCell(collectionView, indexPath, viewModel)
            case .horizontalProductItem,.verticalProductItem:
                return self?.productItemCell(collectionView, indexPath, viewModel)
            case .none:
                return .init()
            }
        })
        
    }
    
    private func applySnapShot(bannerViewModels: [HomeBannerCollectionViewCellViewModel], horizontalProductViewModels: [HomeProductCollectionViewCellViewModel], verticalProductViewModels: [HomeProductCollectionViewCellViewModel]) {
        // Diffable Data Source 스냅샷을 생성
        var snapShot: NSDiffableDataSourceSnapshot<Section, AnyHashable> = NSDiffableDataSourceSnapshot<Section,AnyHashable>()
        // 스냅샷에 'banner' 섹션 추가
        snapShot.appendSections([.banner])
        // 'banner' 섹션에 이미지들을 아이템으로 추가
        snapShot.appendItems(bannerViewModels, toSection: .banner)
        
        snapShot.appendSections([.horizontalProductItem])
        snapShot.appendItems(horizontalProductViewModels,toSection: .horizontalProductItem)
        
        snapShot.appendSections([.verticalProductItem])
        snapShot.appendItems(verticalProductViewModels,toSection: .verticalProductItem)
        
        // 데이터 소스에 스냅샷을 적용하여 데이터를 업데이트
        dataSource?.apply(snapShot)
    }
    
    private func bannerCell(_ collectionView:UICollectionView, _ indexPath:IndexPath, _ viewModel:AnyHashable) -> UICollectionViewCell {
        guard let viewModel = viewModel as? HomeBannerCollectionViewCellViewModel, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeBannerCollectionViewCell", for: indexPath) as? HomeBannerCollectionViewCell else { return .init() }
        cell.setViewModel(viewModel)
        return cell
    }
    
    private func productItemCell(_ collectionView:UICollectionView, _ indexPath:IndexPath, _ viewModel:AnyHashable) -> UICollectionViewCell {
        guard let viewModel = viewModel as? HomeProductCollectionViewCellViewModel, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeProductCollectionViewCell", for: indexPath) as? HomeProductCollectionViewCell else { return .init() }
        cell.setViewModel(viewModel)
        return cell
    }
}
