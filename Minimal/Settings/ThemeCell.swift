//
//  ThemeCell.swift
//  Minimal
//
//  Created by Jameson Kirby on 12/17/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

class ThemeCell: UITableViewCell {
    @IBOutlet weak var themeColorPrimary: UIView!
    @IBOutlet weak var themeColorSecondary: UIView!
    @IBOutlet weak var themeColorBackground: UIView!
    @IBOutlet weak var themeColorSelection: UIView!
    @IBOutlet weak var themeColorTint: UIView!
    @IBOutlet weak var checkmark: UIImageView!
    let themeManager = ThemeManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        let topLineView = UIView()
        topLineView.backgroundColor = .black
        topLineView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(topLineView)
        
        let bottomLineView = UIView()
        bottomLineView.backgroundColor = .black
        bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomLineView)
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[lineView(1)]",
                                                                  options: NSLayoutConstraint.FormatOptions.alignAllLeading,
                                                                  metrics: nil,
                                                                  views: ["lineView":topLineView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[lineView]-0-|",
                                                                  options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                                  metrics: nil,
                                                                  views: ["lineView":topLineView]))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLineView(1)]-0-|",
                                                                  options: NSLayoutConstraint.FormatOptions.alignAllLeading,
                                                                  metrics: nil,
                                                                  views: ["bottomLineView":bottomLineView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bottomLineView]-0-|",
                                                                  options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                                  metrics: nil,
                                                                  views: ["bottomLineView":bottomLineView]))
    }
}
