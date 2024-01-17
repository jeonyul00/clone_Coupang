//
//  HomeViewModel.swift
//  coupang
//
//  Created by 전율 on 2024/01/16.
//

import Foundation
import Combine

class HomeViewModel {
    enum Action {
        case loadData
        case getDataSuccess(HomeResponse)
        case getDataFailure(Error)
    }
    
    final class State {
        struct CollectionViewModels {
            var bannerViewModels: [HomeBannerCollectionViewCellViewModel]?
            var horizontalProductViewModels: [HomeProductCollectionViewCellViewModel]?
            var verticalProductViewModels: [HomeProductCollectionViewCellViewModel]?
        }
        @Published var collectionViewModels = CollectionViewModels()
    }
    // private(set): set만 private
    private(set) var state = State()
    
    private var loadDataTask: Task<Void,Never>?
    
    func process(action:Action){
        switch action {
        case .loadData:
            loadData()
        case let .getDataSuccess(response):
            transformResponse(response)
        case let .getDataFailure(error):
            print(error)
        }
    }
    
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
    
    deinit {
        loadDataTask?.cancel()
    }
    
    private func transformResponse(_ response: HomeResponse) {
        // 뱡렬처리 해도되지 않냐
        Task{ await transformBanner(response) }
        Task { await transformHorizontalProduct(response) }
        Task { await transformVerticalProduct(response) }
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
    
    private func productToHomeProductCollectionViewCellViewMoel(_ product:[product]) -> [HomeProductCollectionViewCellViewModel] {
        return product.map { HomeProductCollectionViewCellViewModel(imageUrlString: $0.imageUrl, title: $0.title, reasonDiscountString: $0.discount, originalPrice: $0.originalPrice.moneyString, discountPrice: $0.discountPrice.moneyString) }
        
    }
    
}
