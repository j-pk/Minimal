//
//  UITabBarExtensions.swift
//  Minimal
//
//  Created by Jameson Kirby on 1/2/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

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
