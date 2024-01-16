//
//  HomeBannerCollectionViewCell.swift
//  coupang
//
//  Created by 전율 on 2024/01/16.
//

import UIKit

class HomeBannerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setImage(_ image:UIImage){
        imageView.image = image
    }
}
