//
//  Numeric.swift
//  coupang
//
//  Created by 전율 on 2024/01/17.
//

import Foundation
extension Numeric {
    var moneyString: String {
        let formtter = NumberFormatter()
        formtter.locale = .current // 현재 로케일을 설정합니다. 한국
        formtter.numberStyle = .decimal // 숫자 형식을 소수점 형식으로 설정합니다.
        formtter.maximumFractionDigits = 0 // 소수점 이하 자릿수를 0으로 설정하여 소수점을 표시하지 않습니다.
        return (formtter.string(for: self) ?? "") + "원"
    }
}
