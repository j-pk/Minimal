//
//  SegmentedController.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 2/5/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

class SegmentedController: UISegmentedControl {
    /// This resolves the truncation of text in the UILabel found in the UISegmentedControl
    override func layoutSubviews() {
        super.layoutSubviews()
        self.subviews.forEach({ view in
            if let label = view.subviews.filter({ $0 is UILabel }).first as? UILabel {
                label.adjustsFontSizeToFitWidth = true
            }
        })
    }
}
