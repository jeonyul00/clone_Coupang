//
//  HomeViewController.swift
//  coupang
//
//  Created by 전율 on 2024/01/16.
//

import UIKit
import Combine

final class HomeViewController: UIViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<Section,AnyHashable>
    private typealias SnapShot = NSDiffableDataSourceSnapshot<Section,AnyHashable>
    private enum Section:Int {
        case banner
        case horizontalProductItem
        case couponButton
        case verticalProductItem
    }
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // UICollectionView의 데이터 소스를 관리하는 변수. 섹션 타입은 'Section', 아이템 타입은 'UIImage'
    private lazy var dataSource:DataSource = setDataSource()
    // 컬렉션 뷰의 레이아웃을 정의하는 클로저.
    private lazy var compositionalLayout:UICollectionViewCompositionalLayout = setCompositinalLayout()
    private var viewModel = HomeViewModel()
    private var cancellables: Set<AnyCancellable> = [] // 해 당 viewController가 사라질 때 사라짐
    private var currentSection: [Section] {
        dataSource.snapshot().sectionIdentifiers as [Section]
    }
    private var didTapCouponDownload: PassthroughSubject<Void,Never> = PassthroughSubject<Void,Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        // 컬렉션 뷰의 레이아웃 설정
        collectionView.collectionViewLayout = compositionalLayout
        
        viewModel.process(action: .loadData)
        viewModel.process(action: .loadCoupon)
    }
    
    private func setCompositinalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] section, _ in
            switch self?.currentSection[section]{
            case .banner:
                return HomeBannerCollectionViewCell.bannerLayout()
            case .horizontalProductItem:
                return HomeProductCollectionViewCell.horizontalProductItemLayout()
            case .verticalProductItem:
                return HomeProductCollectionViewCell.VerticalProductItemLayout()
            case .couponButton:
                return HomeCouponButtonCollectionViewCell.couponButtonItemLayout()
            case .none:
                return nil
            }
        }
    }
    
    private func bindViewModel() {
        viewModel.state.$collectionViewModels.receive(on: DispatchQueue.main).sink {[weak self] _ in
            self?.applySnapShot()
        }.store(in: &cancellables) // cancellables의 생명주기가 끝나면, 관찰을 끊는다.
        
        didTapCouponDownload.receive(on: DispatchQueue.main).sink {[weak self] _ in
            self?.viewModel.process(action: .didTapCouponButton)}.store(in: &cancellables)
        
    }
    
    private func setDataSource() -> DataSource {
        // CollectionViewCompositionalLayout: 섹션 > 그룹 > 아이템
        // 데이터 소스 초기화
        return UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, viewModel in
            switch self?.currentSection[indexPath.section] {
            case .banner:
                return self?.bannerCell(collectionView, indexPath, viewModel)
            case .horizontalProductItem,.verticalProductItem:
                return self?.productItemCell(collectionView, indexPath, viewModel)
            case .couponButton:
                return self?.couponButtonCell(collectionView, indexPath, viewModel)
            case .none:
                return .init()
            }
        })
        
    }
    
    private func applySnapShot() {
        // Diffable Data Source 스냅샷을 생성
        var snapShot: SnapShot = SnapShot()
        if let bannerViewModels = viewModel.state.collectionViewModels.bannerViewModels {
            // 스냅샷에 'banner' 섹션 추가
            snapShot.appendSections([.banner])
            // 'banner' 섹션에 이미지들을 아이템으로 추가
            snapShot.appendItems(bannerViewModels, toSection: .banner)
        }
        
        if let horizontalProductViewModels = viewModel.state.collectionViewModels.horizontalProductViewModels {
            snapShot.appendSections([.horizontalProductItem])
            snapShot.appendItems(horizontalProductViewModels,toSection: .horizontalProductItem)
            
        }
        
        if let couponViewmodels = viewModel.state.collectionViewModels.couponState {
            snapShot.appendSections([.couponButton])
            snapShot.appendItems(couponViewmodels, toSection: .couponButton)
        }
        
        
        if let verticalProductViewModels = viewModel.state.collectionViewModels.verticalProductViewModels {
            snapShot.appendSections([.verticalProductItem])
            snapShot.appendItems(verticalProductViewModels,toSection: .verticalProductItem)
        }
        
        // 데이터 소스에 스냅샷을 적용하여 데이터를 업데이트
        dataSource.apply(snapShot)
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
    
    private func couponButtonCell(_ collectionView:UICollectionView, _ indexPath:IndexPath, _ viewModel:AnyHashable) -> UICollectionViewCell {
        guard let viewModel = viewModel as? HomeCouponButtonCollectionViewCellViewModel, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCouponButtonCollectionViewCell", for: indexPath) as? HomeCouponButtonCollectionViewCell else { return .init() }
        cell.setViewModel(viewModel, didTapCouponDownload)
        return cell
    }
}
