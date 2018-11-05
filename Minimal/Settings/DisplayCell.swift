//
//  DisplayCell.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/1/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

class DisplayCell: UITableViewCell {
    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var checkmark: UIImageView!

    let themeManager = ThemeManager()
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setSeparatorInset(forInsetValue: .none)
        displayImageView.tintColor = themeManager.theme.tintColor
        checkmark.tintColor = themeManager.theme.tintColor
    }

}
