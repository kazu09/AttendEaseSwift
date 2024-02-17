//
//  UiColor.swift
//  AttendEase
//
//  Created by kazu on 2024/02/17.
//

import Foundation
import UIKit
extension UIColor {
    convenience init(colorCode: String, alpha: CGFloat = 1.0) {
        let v = Int("000000" + colorCode, radix: 16) ?? 0
        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }
}
