//
//  SubscriptLabelView.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/18/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

class SubscriptLabelView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    weak var delegate: UIViewTappableDelegate?
    private var data: [String:Any?] = [:]
    fileprivate let themeManager = ThemeManager()
    
    func setLabels(forListing listing: Listing) {
        let boldAttributes = [
            NSAttributedStringKey.font: themeManager.font(fontStyle: .primaryBold),
            NSAttributedStringKey.foregroundColor: themeManager.theme.titleTextColor
        ]
        
        let regularAttributes = [
            NSAttributedStringKey.font: themeManager.font(fontStyle: .secondary),
            NSAttributedStringKey.foregroundColor: themeManager.theme.subtitleTextColor
        ]
        
        let scoreAttributes = [
            NSAttributedStringKey.font: themeManager.font(fontStyle: .secondary),
            NSAttributedStringKey.foregroundColor: themeManager.redditOrange
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
        detailLabel.textColor = themeManager.linkTextColor
        data = ["subreddit":listing.subredditNamePrefixed]
        
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
        detailLabel.isUserInteractionEnabled = true
        detailLabel.addGestureRecognizer(tapGestureRecognizer)
    }
}

extension SubscriptLabelView: Tappable, Recognizer {
    func didTapView(_ sender: UITapGestureRecognizer) {
        delegate?.didTapView(sender: sender, data: data)
    }
}
