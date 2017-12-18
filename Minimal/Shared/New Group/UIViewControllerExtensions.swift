//
//  UIViewControllerExtensions.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/11/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

extension UIViewController {
    static func make<T: UIViewController>(storyboard: UIStoryboard.Storyboard) -> T {
        return UIStoryboard.storyboard(storyboard).instantiateViewController(withIdentifier: T.typeName) as! T
    }
}

extension UIStoryboard {
    enum Storyboard: String {
        case main
        case search
        case settings
        case subscribed
        
        var filename: String {
            return rawValue.capitalized
        }
    }
    
    convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.filename, bundle: bundle)
    }
    
    class func storyboard(_ storyboard: Storyboard, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: storyboard.filename, bundle: bundle)
    }
}
