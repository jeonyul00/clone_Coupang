//
//  HomeViewController.swift
//  coupang
//
//  Created by 전율 on 2024/01/16.
//

import UIKit
import Combine

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
    private var viewModel = HomeViewModel()
    private var cancellables: Set<AnyCancellable> = [] // 해 당 viewController가 사라질 때 사라짐
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDataSource()
        bindViewModel()
        viewModel.loadData()
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
    
    private func bindViewModel() {
        viewModel.$bannerViewModels.receive(on: DispatchQueue.main).sink {[weak self] _ in
            self?.applySnapShot()
        }.store(in: &cancellables) // cancellables의 생명주기가 끝나면, 관찰을 끊는다.
        viewModel.$horizontalProductViewModels.receive(on: DispatchQueue.main).sink {[weak self] _ in
            self?.applySnapShot()
        }.store(in: &cancellables)
        viewModel.$verticalProductViewModels.receive(on: DispatchQueue.main).sink {[weak self] _ in
            self?.applySnapShot()
        }.store(in: &cancellables)
        
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
    
    private func applySnapShot() {
        // Diffable Data Source 스냅샷을 생성
        var snapShot: NSDiffableDataSourceSnapshot<Section, AnyHashable> = NSDiffableDataSourceSnapshot<Section,AnyHashable>()
        if let bannerViewModels = viewModel.bannerViewModels {
            // 스냅샷에 'banner' 섹션 추가
            snapShot.appendSections([.banner])
            // 'banner' 섹션에 이미지들을 아이템으로 추가
            snapShot.appendItems(bannerViewModels, toSection: .banner)
        }
        
        if let verticalProductViewModels = viewModel.horizontalProductViewModels {
            snapShot.appendSections([.horizontalProductItem])
            snapShot.appendItems(verticalProductViewModels,toSection: .horizontalProductItem)
            
        }
        
        if let verticalProductViewModels = viewModel.verticalProductViewModels {
            snapShot.appendSections([.verticalProductItem])
            snapShot.appendItems(verticalProductViewModels,toSection: .verticalProductItem)
        }
        
                
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
