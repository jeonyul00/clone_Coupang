//
//  HomeViewModel.swift
//  coupang
//
//  Created by 전율 on 2024/01/16.
//

import Foundation
import Combine

final class HomeViewModel {
    enum Action {
        case loadData
        case loadCoupon
        case getDataSuccess(HomeResponse)
        case getDataFailure(Error)
        case getCouponSuccess(Bool)
        case didTapCouponButton
    }
    
    final class State {
        struct CollectionViewModels {
            var bannerViewModels: [HomeBannerCollectionViewCellViewModel]?
            var horizontalProductViewModels: [HomeProductCollectionViewCellViewModel]?
            var verticalProductViewModels: [HomeProductCollectionViewCellViewModel]?
            var couponState: [HomeCouponButtonCollectionViewCellViewModel]?
        }
        @Published var collectionViewModels = CollectionViewModels()
    }
    // private(set): set만 private
    private(set) var state = State()
    
    private var loadDataTask: Task<Void,Never>?
    private let couponDownloadedKey = "CouponDownloaded"
    
    
    func process(action:Action){
        switch action {
        case .loadData:
            loadData()
        case .loadCoupon:
            loadCoupon()
        case let .getDataSuccess(response):
            transformResponse(response)
        case let .getDataFailure(error):
            print(error)
        case let .getCouponSuccess(isDownloaded):
            Task { await transformCoupon(isDownloaded) }
        case .didTapCouponButton:
            downloadCoupon()
        }
        
    }
    
    deinit {
        loadDataTask?.cancel()
    }
    
    
}
extension HomeViewModel {
    
    private func loadData() {
        loadDataTask = Task {
            do{
                let response = try await NetWorkService.shared.getHomeData()
                process(action: .getDataSuccess(response))
                
            } catch {
                process(action: .getDataFailure(error))
            }
            
        }
    }
    
    private func transformResponse(_ response: HomeResponse) {
        // 뱡렬처리 해도되지 않냐
        Task{ await transformBanner(response) }
        Task { await transformHorizontalProduct(response) }
        Task { await transformVerticalProduct(response) }
    }
    
    private func loadCoupon() {
        let couponState: Bool = UserDefaults.standard.bool(forKey: couponDownloadedKey)
        process(action: .getCouponSuccess(couponState))
    }
    
    // ui update는 메인 쓰레드에서 해야함 => @MainActor
    @MainActor
    private func transformBanner(_ response: HomeResponse) async {
        state.collectionViewModels.bannerViewModels = response.banners.map { HomeBannerCollectionViewCellViewModel(bannerImageUrl: $0.imageUrl) }
    }
    
    @MainActor
    private func transformHorizontalProduct(_ response: HomeResponse) async {
        state.collectionViewModels.horizontalProductViewModels = productToHomeProductCollectionViewCellViewMoel(response.horizontalProducts)
    }
    
    @MainActor
    private func transformVerticalProduct(_ response: HomeResponse) async {
        state.collectionViewModels.verticalProductViewModels = productToHomeProductCollectionViewCellViewMoel(response.verticalProducts)
    }
    
    @MainActor
    private func transformCoupon(_ isDownloaded:Bool) async {
        state.collectionViewModels.couponState = [.init(state: isDownloaded ? .disable : .enable)]
    }
    
    private func downloadCoupon(){
        UserDefaults.standard.setValue(true, forKey: couponDownloadedKey)
        process(action: .loadCoupon)
    }
    
    private func productToHomeProductCollectionViewCellViewMoel(_ product:[product]) -> [HomeProductCollectionViewCellViewModel] {
        return product.map { HomeProductCollectionViewCellViewModel(imageUrlString: $0.imageUrl, title: $0.title, reasonDiscountString: $0.discount, originalPrice: $0.originalPrice.moneyString, discountPrice: $0.discountPrice.moneyString) }
        
    }
    
}

