//
//  SubscriptLabelView.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/18/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

class SubscriptLabelView: XibView {
    @IBOutlet weak var titleLabel: TitleLabel!
    @IBOutlet weak var subtitleLabel: SubtitleLabel!
    @IBOutlet weak var detailLabel: SubtitleLabel!
    @IBOutlet weak var descriptionLabel: SubtitleLabel!
    
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
        
        if let title = listing.title {
            let titleAttributedString = NSAttributedString(string: title, attributes: boldAttributes)
            titleLabel.attributedText = titleAttributedString
        }
        if let domain = listing.domain {
            let domainAttributedString = NSAttributedString(string: "(\(domain))", attributes: regularAttributes)
            subtitleLabel.attributedText = domainAttributedString
        }
        
        detailLabel.text = listing.subredditNamePrefixed
        detailLabel.textColor = themeManager.linkTextColor
        data = ["subreddit":listing.subredditNamePrefixed]
        
        let descriptionAttributedString = NSMutableAttributedString()
        let score = NumberFormatter.localizedString(from: NSNumber(value: listing.score), number: .decimal)
        let scoreAttributedString = NSAttributedString(string: score, attributes: scoreAttributes)
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

extension IntegerLiteralType {
    func string() {
        
    }
}
