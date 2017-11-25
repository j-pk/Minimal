//
//  ThemeManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/24/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import ChameleonFramework

final class ThemeManager {
    
    static let `default` = ThemeManager()
    
    static func setGlobalTheme() {
        Chameleon.setGlobalThemeUsingPrimaryColor(ThemeManager.default.primaryTheme, with: ThemeManager.default.contentStyle)
    }
    
    // MARK: - Theme
    let primaryTheme = #colorLiteral(red: 0.4274509804, green: 0.4470588235, blue: 0.4588235294, alpha: 1).flatten()
    let secondaryTheme = #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1).flatten()
    let tabBarTheme = #colorLiteral(red: 0.2117647059, green: 0.3098039216, blue: 0.3215686275, alpha: 1).flatten()
    let contentStyle: UIContentStyle = .contrast
    
    let primaryTextColor = #colorLiteral(red: 0.5215686275, green: 0.6588235294, blue: 0.5529411765, alpha: 1).flatten()
    let secondaryTextColor = #colorLiteral(red: 0.7921568627, green: 0.8235294118, blue: 0.7764705882, alpha: 1).flatten()
    
    let redditOrange = #colorLiteral(red: 0.8879843354, green: 0.5014117956, blue: 0, alpha: 1)
    
    // MARK: - Font
    static func fontName() -> String {
        return UIFont(name: FontType.primary.helveticaNeue, size: FontType.primary.fontSize)!.fontName
    }
    
    static func font(fontType: FontType) -> UIFont {
        return fontType.font
    }
}

//MARK: - FontType

enum FontType {
    case primary
    case primaryBold
    case secondary
}

extension FontType {
    var helveticaNeue: String {
        switch self {
        case .primary, .secondary:
            return "HelveticaNeue"
        case .primaryBold:
            return "HelveticaNeue-Bold"
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .primary, .primaryBold:
            return 14
        case .secondary:
            return 12
        }
    }
    
    var font: UIFont {
        switch self {
        case .primary:
            return UIFont(name: FontType.primary.helveticaNeue, size: FontType.primary.fontSize)!
        case .primaryBold:
            return UIFont(name: FontType.primaryBold.helveticaNeue, size: FontType.primaryBold.fontSize)!
        case .secondary:
            return UIFont(name: FontType.secondary.helveticaNeue, size: FontType.secondary.fontSize)!
        }
    }
}
