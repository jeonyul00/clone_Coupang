//
//  HomeBannerCollectionViewCell.swift
//  coupang
//
//  Created by 전율 on 2024/01/16.
//

import UIKit

struct HomeBannerCollectionViewCellViewModel:Hashable {
    let bannerImage:UIImage
}

class HomeBannerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setViewModel(_ viewModel:HomeBannerCollectionViewCellViewModel){
        imageView.image = viewModel.bannerImage
    }
}
