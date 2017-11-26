//
//  SubscriptLabelView.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/18/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

protocol SubscriptLabelViewDelegate: class {
    func didTapDetailLabel(subredditNamePrefixed: String)
}

class SubscriptLabelView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    weak var delegate: SubscriptLabelViewDelegate?
    
    func setLabels(forListing listing: Listing) {
        let boldAttributes = [
            NSAttributedStringKey.font: ThemeManager.font(fontType: .primaryBold),
            NSAttributedStringKey.foregroundColor: ThemeManager.default.primaryTextColor
        ]
        
        let regularAttributes = [
            NSAttributedStringKey.font: ThemeManager.font(fontType: .secondary),
            NSAttributedStringKey.foregroundColor: ThemeManager.default.secondaryTextColor
        ]
        
        let scoreAttributes = [
            NSAttributedStringKey.font: ThemeManager.font(fontType: .secondary),
            NSAttributedStringKey.foregroundColor: ThemeManager.default.redditOrange
        ]
        
        let mutableAttributedTitleString = NSMutableAttributedString()
        if let title = listing.title {
            let titleAttributedString = NSAttributedString(string: title, attributes: boldAttributes)
            mutableAttributedTitleString.append(titleAttributedString)
        }
        if let domain = listing.domain {
            let domainAttributedString = NSAttributedString(string: " (\(domain))", attributes: regularAttributes)
            mutableAttributedTitleString.append(domainAttributedString)
        }
        titleLabel.attributedText = mutableAttributedTitleString
        
        detailLabel.text = listing.subredditNamePrefixed
        detailLabel.textColor = ThemeManager.default.linkTextColor
        
        let descriptionAttributedString = NSMutableAttributedString()
        let scoreAttributedString = NSAttributedString(string: "\(listing.score)", attributes: scoreAttributes) 
        descriptionAttributedString.append(scoreAttributedString)
        
        if let author = listing.author {
            let authorAttributedString = NSAttributedString(string: " upvotes submitted by \(author)", attributes: regularAttributes)
            descriptionAttributedString.append(authorAttributedString)
        }
        if let dateCreated = listing.created {
            let dateCreatedAttributedString = NSAttributedString(string: " \(dateCreated.timeAgoSinceNow())", attributes: regularAttributes)
            descriptionAttributedString.append(dateCreatedAttributedString)
        }
        descriptionLabel.attributedText = descriptionAttributedString
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapDetailLabel))
        detailLabel.addGestureRecognizer(tapGestureRecognizer)
        detailLabel.isUserInteractionEnabled = true
    }
    
    @objc func didTapDetailLabel(sender: UITapGestureRecognizer) {
        guard let subredditNamePrefixed = (sender.view as? UILabel)?.text else { return }
        if let delegate = delegate {
            delegate.didTapDetailLabel(subredditNamePrefixed: subredditNamePrefixed)
        }
    }
}
