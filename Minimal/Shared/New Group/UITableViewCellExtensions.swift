//
//  UITableViewCellExtensions.swift
//  Minimal
//
//  Created by Jameson Kirby on 12/4/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

enum InsetValue: CGFloat {
    case zero = 0
    case none = 1000
}

extension UITableViewCell {
    func setSeparatorInset(forInsetValue value: InsetValue) {
        layoutMargins = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        if value.rawValue == 0 {
            separatorInset = UIEdgeInsets.zero
        } else {
            separatorInset = UIEdgeInsets.init(top: 0, left: value.rawValue, bottom: 0, right: 0)
        }
    }
}
