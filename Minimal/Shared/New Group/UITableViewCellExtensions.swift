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
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        if value.rawValue == 0 {
            self.separatorInset = UIEdgeInsets.zero
        } else {
            self.separatorInset = UIEdgeInsetsMake(0, value.rawValue, 0, 0)
        }
    }
}
