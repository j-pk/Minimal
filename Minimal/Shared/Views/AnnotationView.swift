//
//  AnnotationView.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/18/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

class AnnotationView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    weak var delegate: UIViewTappableDelegate?
    private var data: [String: Any?] = [:]
    private let themeManager = ThemeManager()
    
    func setLabels(forListing listing: Listing) {
        posLog(values: listing.subreddit)
        
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
        
        let attributedTitleString = NSMutableAttributedString()
        if let title = listing.title {
            attributedTitleString.append(NSAttributedString(string: title, attributes: boldAttributes))
        }
        if let domain = listing.domain {
            attributedTitleString.append(NSAttributedString(string: " (\(domain))", attributes: regularAttributes))
        }
        
        titleLabel.attributedText = attributedTitleString
        detailLabel.text = listing.subredditNamePrefixed
        detailLabel.textColor = themeManager.linkTextColor
        data = ["subreddit": listing.subredditNamePrefixed]
        
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

extension AnnotationView: Tappable, Recognizer {
    func didTapView(_ sender: UITapGestureRecognizer) {
        delegate?.didTapView(sender: sender, data: data)
    }
}
