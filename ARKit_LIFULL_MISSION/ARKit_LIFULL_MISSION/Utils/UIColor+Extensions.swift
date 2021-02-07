//
//  UIColor+Extensions.swift
//  ARKit_LIFULL_MISSION
//
//  Created by HIROKI IKEUCHI on 2021/01/26.
//

import UIKit

// MARK: - UIColor

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }

    static let lifullBrandColor = UIColor.rgb(red: 244, green: 86, blue: 32)  // LIFULLのブランドカラー
    static let lifullSecondaryBrandColor = UIColor.rgb(red: 253, green: 193, blue: 148)

    static func random() -> UIColor {
        UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
    }
}
