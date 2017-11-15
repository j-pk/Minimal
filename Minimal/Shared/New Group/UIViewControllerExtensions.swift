//
//  UIViewControllerExtensions.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/11/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

extension UIViewController {
    static func make<T: UIViewController>() -> T {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: T.typeName) as! T
    }
}
