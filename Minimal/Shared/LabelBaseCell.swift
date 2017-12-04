//
//  LabelBaseCell.swift
//  Minimal
//
//  Created by Jameson Kirby on 12/3/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

class LabelBaseCell: UITableViewCell {
    var titleLabel = UILabel()
    var detailLabel = UILabel()
    var descriptionLabel = UILabel()
    
    var mainStackView = UIStackView()
    var labelStackView = UIStackView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupBaseView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setupBaseView() {
        guard !self.subviews.contains(self.mainStackView) else { return }
        self.selectionStyle = .none

        mainStackView.axis = .horizontal
        mainStackView.distribution = .fill
        mainStackView.alignment = .center
        mainStackView.spacing = 0
        
        labelStackView.axis = .vertical
        labelStackView.distribution = .fillProportionally
        labelStackView.alignment = .leading
        labelStackView.spacing = 0
        
        labelStackView.addArrangedSubview(titleLabel)
        labelStackView.addArrangedSubview(detailLabel)
        labelStackView.addArrangedSubview(descriptionLabel)

        let arrow = UIButton()
        arrow.setImage(UIImage(named: "rightArrow"), for: UIControlState())
        arrow.imageView?.contentMode = .scaleAspectFit
        
        mainStackView.addArrangedSubview(labelStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        arrow.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(arrow)
        contentView.addSubview(mainStackView)
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[arrow(14)]",
                                                           options: NSLayoutFormatOptions.alignAllLeading,
                                                           metrics: nil,
                                                           views: ["arrow": arrow]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[arrow(14)]",
                                                           options: NSLayoutFormatOptions.alignAllLeading,
                                                           metrics: nil,
                                                           views: ["arrow": arrow]))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[mainStackView]-12-|",
                                                           options: NSLayoutFormatOptions.alignAllLeading,
                                                           metrics: nil,
                                                           views: ["mainStackView": mainStackView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[mainStackView]-[arrow]-|",
                                                           options: NSLayoutFormatOptions.alignAllCenterY,
                                                           metrics: nil,
                                                           views: ["mainStackView": mainStackView, "arrow": arrow]))
        
    }
}

