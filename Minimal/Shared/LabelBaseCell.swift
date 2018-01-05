//
//  LabelBaseCell.swift
//  Minimal
//
//  Created by Jameson Kirby on 12/3/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

class LabelBaseCell: UITableViewCell {
    enum SelectionImage {
        case checkmark
        case arrow
        case none
        
        var image: UIImage? {
            switch self {
            case .checkmark:
                return #imageLiteral(resourceName: "checkmark")
            case .arrow:
                return #imageLiteral(resourceName: "rightArrow")
            case .none:
                return nil
            }
        }
    }
    
    var titleLabel = UILabel()
    var detailLabel = UILabel()
    var descriptionLabel = UILabel()
    var selectionImage: SelectionImage = .none {
        willSet {
            configure(selectionImage: newValue)
        }
    }
    let selectionImageButton = UIButton()
    var mainStackView = UIStackView()
    var labelStackView = UIStackView()
    
    var themeManager = ThemeManager()
    
    override func awakeFromNib() {
        setupBaseView()
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

        mainStackView.addArrangedSubview(labelStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        selectionImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(selectionImageButton)
        contentView.addSubview(mainStackView)
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[selectionImageButton(20)]",
                                                                  options: NSLayoutFormatOptions.alignAllLeading,
                                                                  metrics: nil,
                                                                  views: ["selectionImageButton": selectionImageButton]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selectionImageButton(20)]",
                                                                  options: NSLayoutFormatOptions.alignAllLeading,
                                                                  metrics: nil,
                                                                  views: ["selectionImageButton": selectionImageButton]))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[mainStackView]-12-|",
                                                                  options: NSLayoutFormatOptions.alignAllLeading,
                                                                  metrics: nil,
                                                                  views: ["mainStackView": mainStackView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[mainStackView]-[selectionImageButton]-|",
                                                                  options: NSLayoutFormatOptions.alignAllCenterY,
                                                                  metrics: nil,
                                                                  views: ["mainStackView": mainStackView, "selectionImageButton": selectionImageButton]))
        
    }
    
    private func configure(selectionImage: SelectionImage) {
        if let image = selectionImage.image {
            selectionImageButton.setImage(image, for: UIControlState())
            selectionImageButton.imageView?.contentMode = .scaleAspectFit
        } else {
            selectionImageButton.isHidden = true
        }
    }
}

