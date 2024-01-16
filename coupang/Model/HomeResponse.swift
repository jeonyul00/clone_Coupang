//
//  HomeResponse.swift
//  coupang
//
//  Created by 전율 on 2024/01/16.
//

import Foundation

struct HomeResponse:Codable {
    let banners:[banner]
    let themes: [banner]
    let horizontalProducts:[product]
    let verticalProducts:[product]
}

struct banner:Codable {
    let id: Int
    let imageUrl:String
}

struct product:Codable {
    let id: Int
    let imageUrl: String
    let title: String
    let discount: String
    let originalPrice: Int
    let discountPrice: Int
}
