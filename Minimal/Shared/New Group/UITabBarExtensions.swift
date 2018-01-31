//
//  UITabBarExtensions.swift
//  Minimal
//
//  Created by Jameson Kirby on 1/2/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

extension UITabBarController {
    func tab<T>(toViewController viewController: T.Type) where T : UIViewController {
        self.viewControllers?.forEach({ (viewController) in
            if viewController is UINavigationController {
                if let navigationController = viewController as? UINavigationController {
                    if navigationController.viewControllers.filter({ $0 is T }).first != nil {
                        self.selectedViewController = navigationController
                    }
                }
            } else {
                if viewController is T {
                    self.selectedViewController = viewController
                }
            }
        })
    }
    
    func fetch<T>(viewController: T.Type) -> T? where T : UIViewController {
        var destination: T?
        self.viewControllers?.forEach({ (viewController) in
            if viewController is UINavigationController {
                if let navigationController = viewController as? UINavigationController {
                    if let filterViewController = navigationController.viewControllers.filter({ $0 is T }).first as? T {
                        destination = filterViewController
                    }
                }
            } else {
                if viewController is T {
                    destination = viewController as? T
                }
            }
        })
        return destination
    }
}

extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        guard let window = UIApplication.shared.keyWindow else {
            return super.sizeThatFits(size)
        }
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = window.safeAreaInsets.bottom + 40
        return sizeThatFits
    }
}

class TranslucentTabBar: UITabBar {
    override func awakeFromNib() {
        super.awakeFromNib()
        adjustTabBarBlurEffect()
    }
    
    func adjustTabBarBlurEffect() {
        let themeManager = ThemeManager()
        
        if let visualEffectView = self.subviews.filter({ $0 is UIVisualEffectView == true }).first {
            visualEffectView.removeFromSuperview()
        }
        
        let blurEffect = UIBlurEffect(style: themeManager.theme.blurEffect)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.backgroundImage = UIImage()
        self.addSubview(blurEffectView)
    }
}
