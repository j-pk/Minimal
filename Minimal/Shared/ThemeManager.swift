//
//  ThemeManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/24/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

struct ThemeManager {
    var theme: Theme
    
    let linkTextColor = #colorLiteral(red: 0.2389388382, green: 0.5892125368, blue: 0.8818323016, alpha: 1)
    let redditOrange = #colorLiteral(red: 0.987544477, green: 0.6673021317, blue: 0, alpha: 1)
    let redditBlue = #colorLiteral(red: 0.6029270887, green: 0.6671635509, blue: 0.8504692912, alpha: 1)
    
    init() {
        if let themeRawValue = UserDefaults.standard.value(forKey: UserSettingsDefaultKey.theme) as? String {
            self.theme = Theme(rawValue: themeRawValue) ?? .minimalTheme
        } else {
            self.theme = .minimalTheme
        }
    }
    
    func setGlobalTheme(theme: Theme) {
        UserDefaults.standard.setValue(theme.rawValue, forKey: UserSettingsDefaultKey.theme)

        UINavigationBar.appearance().barStyle = theme.barStyle
        UINavigationBar.appearance().tintColor = theme.primaryColor
        
        UITabBar.appearance().barStyle = theme.barStyle
        UITabBar.appearance().tintColor = theme.primaryColor
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: theme.titleTextColor], for:  .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: theme.subtitleTextColor], for:  .selected)
    }
    
    // MARK: - Font
    func fontName() -> String {
        return UIFont(name: FontType.primary.helveticaNeue, size: FontType.primary.fontSize)!.fontName
    }
    
    func font(fontType: FontType) -> UIFont {
        return fontType.font
    }
}

enum Theme: String {
    case minimalTheme
    case darkTheme
    case lightTheme
}

extension Theme {
    var primaryColor: UIColor {
        switch self {
        case .minimalTheme:
            return #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)
        case .darkTheme:
            return #colorLiteral(red: 0.1490027606, green: 0.1490303874, blue: 0.1489966214, alpha: 1)
        case .lightTheme:
            return #colorLiteral(red: 0.926155746, green: 0.9410773516, blue: 0.9455420375, alpha: 1)
        }
    }
    
    var secondaryColor: UIColor {
        switch self {
        case .minimalTheme:
            return #colorLiteral(red: 0.4274509804, green: 0.4470588235, blue: 0.4588235294, alpha: 1)
        case .darkTheme:
            return #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        case .lightTheme:
            return #colorLiteral(red: 0.9382581115, green: 0.8733785748, blue: 0.684623003, alpha: 1)
        }
    }
    
    var titleTextColor: UIColor {
        switch self {
        case .minimalTheme:
            return #colorLiteral(red: 0.7921568627, green: 0.8235294118, blue: 0.7764705882, alpha: 1)
        case .darkTheme:
            return #colorLiteral(red: 0.926155746, green: 0.9410773516, blue: 0.9455420375, alpha: 1)
        case .lightTheme:
            return #colorLiteral(red: 0.1490027606, green: 0.1490303874, blue: 0.1489966214, alpha: 1)
        }
    }
    
    var subtitleTextColor: UIColor {
        switch self {
        case .minimalTheme:
            return #colorLiteral(red: 0.5215686275, green: 0.6588235294, blue: 0.5529411765, alpha: 1)
        case .darkTheme:
            return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        case .lightTheme:
            return #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }
    }
    
    var barStyle: UIBarStyle {
        switch self {
        case .minimalTheme, .lightTheme:
            return .default
        case .darkTheme:
            return .black
        }
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
