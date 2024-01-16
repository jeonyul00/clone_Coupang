//
//  HomeViewModel.swift
//  coupang
//
//  Created by 전율 on 2024/01/16.
//

import Foundation
import Combine

class HomeViewModel {
    @Published var bannerViewModels: [HomeBannerCollectionViewCellViewModel]?
    @Published var horizontalProductViewModels: [HomeProductCollectionViewCellViewModel]?
    @Published var verticalProductViewModels: [HomeProductCollectionViewCellViewModel]?
    
    private var loadDataTask: Task<Void,Never>?
    
    func loadData() {
        loadDataTask = Task {
            do{
                let response = try await NetWorkService.shared.getHomeData()
                let bannerViewModels = response.banners.map { HomeBannerCollectionViewCellViewModel(bannerImageUrl: $0.imageUrl) }
                let horizontalProductViewModels = response.horizontalProducts.map { HomeProductCollectionViewCellViewModel(imageUrlString: $0.imageUrl, title: $0.title, reasonDiscountString: $0.discount, originalPrice: "\($0.originalPrice)", discountPrice: "\($0.discountPrice)") }
                let verticalProductViewModels = response.verticalProducts.map { HomeProductCollectionViewCellViewModel(imageUrlString: $0.imageUrl, title: $0.title, reasonDiscountString: $0.discount, originalPrice: "\($0.originalPrice)", discountPrice: "\($0.discountPrice)") }
                self.bannerViewModels = bannerViewModels
                self.horizontalProductViewModels = horizontalProductViewModels
                self.verticalProductViewModels = verticalProductViewModels
                
            } catch {
                print(error)
            }
            
        }
    }
    
    deinit {
        loadDataTask?.cancel()
    }
}
