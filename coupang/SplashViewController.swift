//
//  SplashViewController.swift
//  coupang
//
//  Created by 전율 on 2024/01/16.
//

import UIKit
import Lottie

class SplashViewController: UIViewController {
    
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var lottieAnimationView: LottieAnimationView!
    
    // 메모리에 올라갔을 때 => 생성되고 초기화가 완료된 시점
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // 뷰가 화면에 보여진 직 후
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadViewIfNeeded()
        UIView.animate(withDuration: 1,delay: 1.5) { [weak self] in
            self?.appIcon.alpha = 0
        }
        lottieAnimationView.play()
    }
    
}
