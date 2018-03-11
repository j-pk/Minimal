//
//  ThemeManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/24/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

struct ThemeManager {
    
    var theme: Theme {
        set(newValue) {
            if var defaults = Defaults.retrieve() {
                defaults.theme = newValue.rawValue
                defaults.store()
                setGlobalTheme()
            }
        }
        get {
            if let defaults = Defaults.retrieve() {
                return Theme(rawValue: defaults.theme) ?? .minimalTheme
            }
            return .minimalTheme
        }
    }
    
    var font: FontType {
        set(newValue) {
            if var defaults = Defaults.retrieve() {
                defaults.font = newValue.rawValue
                defaults.store()
                setGlobalFont()
            }
        }
        get {
            if let defaults = Defaults.retrieve() {
                return FontType(rawValue: defaults.font) ?? .sanFrancisco
            }
            return .sanFrancisco
        }
    }
    
    var fontSize: FontSize {
        set(newValue) {
            if var defaults = Defaults.retrieve() {
                defaults.fontSize = newValue.rawValue
                defaults.store()
                setGlobalFont()
            }
        }
        get {
            if let defaults = Defaults.retrieve() {
                return FontSize(rawValue: defaults.fontSize) ?? .normal
            }
            return .normal
        }
    }
    
    let linkTextColor = #colorLiteral(red: 0.2389388382, green: 0.5892125368, blue: 0.8818323016, alpha: 1)
    let redditOrange = #colorLiteral(red: 0.987544477, green: 0.6673021317, blue: 0, alpha: 1)
    let redditBlue = #colorLiteral(red: 0.6029270887, green: 0.6671635509, blue: 0.8504692912, alpha: 1)
    
    func setGlobalTheme() {
        UINavigationBar.appearance().barStyle = theme.barStyle
        UINavigationBar.appearance().barTintColor = theme.primaryColor
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: theme.titleTextColor]

        UITabBar.appearance().barStyle = theme.barStyle
        UITabBar.appearance().tintColor = theme.tintColor
        UITabBar.appearance().barTintColor = theme.primaryColor
        UIVisualEffectView.appearance().effect = UIBlurEffect(style: theme.blurEffect)
        
        UIButton.appearance().setTitleColor(theme.titleTextColor, for: .normal)
        UIButton.appearance().setTitleColor(theme.subtitleTextColor, for: .selected)
        UIButton.appearance().tintColor = theme.tintColor
        
        UIApplication.shared.statusBarStyle = theme.statusBarStyle
        
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor = theme.titleTextColor
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = theme.titleTextColor
        HeaderLabel.appearance().textColor = redditOrange
        TitleLabel.appearance(whenContainedInInstancesOf: [SearchCell.self]).textColor = theme.titleTextColor
        SubtitleLabel.appearance(whenContainedInInstancesOf: [SearchCell.self]).textColor = theme.subtitleTextColor
        UIImageView.appearance(whenContainedInInstancesOf: [SubscribedCell.self]).tintColor = theme.tintColor
        HeaderImageView.appearance().tintColor = theme.titleTextColor
        
        UICollectionView.appearance().backgroundColor = theme.secondaryColor
        UITableViewCell.appearance().backgroundColor = theme.primaryColor
        UITableView.appearance().separatorColor = theme.backgroundColor
        UITableView.appearance().backgroundColor = theme.primaryColor
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = theme.tintColor
        SegmentedController.appearance().tintColor = theme.tintColor
        UILabel.appearance(whenContainedInInstancesOf: [SegmentedController.self]).defaultFont = font(fontStyle: .secondary)
    }
    
    func setGlobalFont() {
        UILabel.appearance().defaultFont = font(fontStyle: .primary)
        TitleLabel.appearance().defaultFontBold = font(fontStyle: .primaryBold)
        SubtitleLabel.appearance().defaultFont = font(fontStyle: .secondary)
        HeaderLabel.appearance().defaultFont = font(fontStyle: .primary)
        UILabel.appearance(whenContainedInInstancesOf: [SegmentedController.self]).defaultFont = font(fontStyle: .secondary)
    }
    
    func font(fontStyle: FontStyle) -> UIFont {
        switch fontStyle {
        case .primary:
            return UIFont(name: font.regular, size: fontSize.rawValue)!
        case .primaryBold:
            return UIFont(name: font.bold, size: fontSize.rawValue)!
        case .secondary:
            return UIFont(name: font.regular, size: fontSize.rawValue - 2)!
        }
    }
}

enum Theme: String {
    case minimalTheme
    case darkTheme
    case lightTheme

    static let allValues = [minimalTheme, darkTheme, lightTheme]
}

extension Theme {
    var titleValue: String {
        switch self {
        case .minimalTheme:
            return "Minimal Theme"
        case .darkTheme:
            return "Dark Theme"
        case .lightTheme:
            return "Light Theme"
        }
    }
    
    var primaryColor: UIColor {
        switch self {
        case .minimalTheme:
            return #colorLiteral(red: 0.2352941176, green: 0.2352941176, blue: 0.2352941176, alpha: 1)
        case .darkTheme:
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .lightTheme:
            return #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        }
    }
    
    var secondaryColor: UIColor {
        switch self {
        case .minimalTheme:
            return #colorLiteral(red: 0.4274509804, green: 0.4470588235, blue: 0.4588235294, alpha: 1)
        case .darkTheme:
            return #colorLiteral(red: 0.01176470588, green: 0.06274509804, blue: 0.09803921569, alpha: 1)
        case .lightTheme:
            return #colorLiteral(red: 0.9176470588, green: 0.9176470588, blue: 0.9176470588, alpha: 1)
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .minimalTheme:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .darkTheme:
            return #colorLiteral(red: 0.1647058824, green: 0.2745098039, blue: 0.3607843137, alpha: 1)
        case .lightTheme:
            return #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
        }
    }
    
    var selectionColor: UIColor {
        switch self {
        case .minimalTheme:
            return #colorLiteral(red: 0.2117647059, green: 0.3098039216, blue: 0.3215686275, alpha: 1)
        case .darkTheme:
            return #colorLiteral(red: 0.1921568627, green: 0.4274509804, blue: 0.5725490196, alpha: 1)
        case .lightTheme:
            return #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .minimalTheme:
            return #colorLiteral(red: 0.5215686275, green: 0.6588235294, blue: 0.5529411765, alpha: 1)
        case .darkTheme:
            return #colorLiteral(red: 0.1647058824, green: 0.2745098039, blue: 0.3607843137, alpha: 1)
        case .lightTheme:
            return #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
        }
    }
    
    
    var titleTextColor: UIColor {
        switch self {
        case .minimalTheme:
            return #colorLiteral(red: 0.7921568627, green: 0.8235294118, blue: 0.7764705882, alpha: 1)
        case .darkTheme:
            return #colorLiteral(red: 0.1921568627, green: 0.4274509804, blue: 0.5725490196, alpha: 1)
        case .lightTheme:
            return #colorLiteral(red: 0.1490027606, green: 0.1490303874, blue: 0.1489966214, alpha: 1)
        }
    }
    
    var subtitleTextColor: UIColor {
        switch self {
        case .minimalTheme:
            return  #colorLiteral(red: 0.5215686275, green: 0.6588235294, blue: 0.5529411765, alpha: 1)
        case .darkTheme:
            return #colorLiteral(red: 0.5529411765, green: 0.6196078431, blue: 0.6470588235, alpha: 1)
        case .lightTheme:
            return #colorLiteral(red: 0.4666666667, green: 0.4666666667, blue: 0.4666666667, alpha: 1)
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
    
    var statusBarStyle: UIStatusBarStyle {
        switch self {
        case .minimalTheme, .darkTheme:
            return .lightContent
        case .lightTheme:
            return .default
        }
    }
    
    var blurEffect: UIBlurEffectStyle {
        switch self {
        case .minimalTheme, .darkTheme:
            return .dark
        case .lightTheme:
            return .light
        }
    }
}

//MARK: - FontType
//TODO: Change FontType
enum FontStyle {
    case primary
    case primaryBold
    case secondary
}

enum FontType: Int {
    case avenir
    case sanFrancisco
    case georgia
    case helveticaNeue
    
    static let allValues = [avenir, sanFrancisco, georgia, helveticaNeue]
    
    var font: UIFont {
        return UIFont(name: self.regular, size: FontSize.normal.rawValue)!
    }
}

enum FontSize: CGFloat {
    case small = 14
    case normal = 16
    case large = 20
    case huge = 22
    case gigantic = 24
}

extension FontType {
    var regular: String {
        switch self {
        case .avenir:
            return "Avenir-Light"
        case .georgia:
            return "Georgia"
        case .helveticaNeue:
            return "HelveticaNeue"
        default:
            return UIFont.systemFont(ofSize: 12).fontName
        }
    }
    
    var bold: String {
        switch self {
        case .avenir:
            return "Avenir-Heavy"
        case .georgia:
            return "Georgia-Bold"
        case .helveticaNeue:
            return "HelveticaNeue-Bold"
        default:
            return UIFont.boldSystemFont(ofSize: 12).fontName
        }
    }
}
