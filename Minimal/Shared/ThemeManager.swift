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
    static func setUpTheme() {
        Chameleon.setGlobalThemeUsingPrimaryColor(primaryTheme(), withSecondaryColor: theme(), usingFontName: fontName(), andContentStyle: contentStyle())
    }
    
    // MARK: - Theme
    
    static func primaryTheme() -> UIColor {
        guard let bgTheme = HexColor("#6d7275") else { return FlatBlack() }
        return bgTheme
    }
    
    static func theme() -> UIColor {
        guard let bgTheme = HexColor("#354f52") else { return FlatCoffeeDark() }
        return bgTheme
    }
    
    static func tabBarTheme() -> UIColor {
        guard let bgTheme = HexColor("#2f3e46") else { return FlatCoffeeDark() }
        return bgTheme
    }
    
    static func tintTheme() -> UIColor {
        return FlatMint()
    }
    
    static func titleTextTheme() -> UIColor {
        return FlatWhite()
    }
    
    static func titleTheme() -> UIColor {
        guard let bgTheme = HexColor("#354f52") else { return FlatCoffeeDark() }
        return bgTheme
    }
    
    static func textTheme() -> UIColor {
        return FlatMint()
    }
    
    static func backgroudTheme() -> UIColor {
        guard let bgTheme = HexColor("#6d7275") else { return FlatBlack() }
        return bgTheme
    }
    
    static func positiveTheme() -> UIColor {
        return FlatMint()
    }
    
    static func negativeTheme() -> UIColor {
        return FlatRed()
    }
    
    static func clearTheme() -> UIColor {
        return UIColor.clear
    }
    
    // MARK: - Content
    
    static func contentStyle() -> UIContentStyle {
        return UIContentStyle.contrast
    }
    
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
    case secondary
}

extension FontType {
    var helveticaNeue: String {
        switch self {
        case .primary, .secondary:
            return "HelveticaNeue"
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .primary:
            return 14
        case .secondary:
            return 12
        }
    }
    
    var font: UIFont {
        switch self {
        case .primary:
            return UIFont(name: FontType.primary.helveticaNeue, size: FontType.primary.fontSize)!
        case .secondary:
            return UIFont(name: FontType.secondary.helveticaNeue, size: FontType.secondary.fontSize)!
        }
    }
}
