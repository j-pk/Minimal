//
//  AnnotationView.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/18/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import Nuke

class AnnotationView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var prefixedSubredditLabel: UILabel!
    @IBOutlet weak var upvoteCountLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    
    weak var delegate: UIViewTappableDelegate?
    private var data: [String: Any?] = [:]
    private let themeManager = ThemeManager()
    
    func setLabels(forListing listing: Listing) {
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
        iconImageView.clipsToBounds = true
        iconImageView.tintColor = themeManager.theme.tintColor
        
        if let subreddit = listing.subreddit, let urlString = subreddit.iconImage, let url = URL(string: urlString) {
            Nuke.loadImage(with: url, into: iconImageView)
        } else {
            iconImageView.image = #imageLiteral(resourceName: "placeholder")
        }
        
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
        
        let linkAttributes = [
            NSAttributedStringKey.font: themeManager.font(fontStyle: .secondaryBold),
            NSAttributedStringKey.foregroundColor: themeManager.linkTextColor
        ]
        
        let attributedTitleString = NSMutableAttributedString()
        if let title = listing.title {
            attributedTitleString.append(NSAttributedString(string: title, attributes: boldAttributes))
        }
        if let domain = listing.domain {
            attributedTitleString.append(NSAttributedString(string: " (\(domain))", attributes: regularAttributes))
        }
        
        let score = NumberFormatter.localizedString(from: NSNumber(value: listing.score), number: .decimal)
        let scoreAttributedString = NSAttributedString(string: score, attributes: scoreAttributes)
        
        let autherAttributedString = NSMutableAttributedString()
        
        if let author = listing.author {
            autherAttributedString.append(NSAttributedString(string: "u/\(author)", attributes: regularAttributes))
        }
        
        let dateCreatedAttributedString = NSMutableAttributedString()
        if let dateCreated = listing.created {
            dateCreatedAttributedString.append(NSAttributedString(string: dateCreated.timeAgoSinceNow().lowercased(), attributes: regularAttributes))
        }
        
        let linkAttributedString = NSMutableAttributedString()
        if let prefixedSubreddit = listing.subredditNamePrefixed {
            linkAttributedString.append(NSAttributedString(string: prefixedSubreddit, attributes: linkAttributes))
        }
        
        // Attributes don't take affect unless pushed on to the main thread 
        DispatchQueue.main.async {
            self.titleLabel.attributedText = attributedTitleString
            self.prefixedSubredditLabel.attributedText = linkAttributedString
            self.upvoteCountLabel.attributedText = scoreAttributedString
            self.authorLabel.attributedText = autherAttributedString
            self.dateCreatedLabel.attributedText = dateCreatedAttributedString
        }
        
        data = ["subreddit": listing.subredditNamePrefixed]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        prefixedSubredditLabel.isUserInteractionEnabled = true
        prefixedSubredditLabel.addGestureRecognizer(tapGestureRecognizer)
    }
}

extension AnnotationView: Tappable, Recognizer {
    func didTapView(_ sender: UITapGestureRecognizer) {
        delegate?.didTapView(sender: sender, data: data)
    }
}
