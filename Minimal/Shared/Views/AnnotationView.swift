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
    
    func setAnnotations(forListing listing: Listing) {
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
        iconImageView.clipsToBounds = true
        iconImageView.tintColor = themeManager.theme.tintColor
        
        if let subreddit = listing.subreddit, let urlString = subreddit.iconImage, let url = URL(string: urlString) {
            Nuke.loadImage(with: url, into: iconImageView)
        } else {
            iconImageView.image = #imageLiteral(resourceName: "placeholder")
        }
        
        let boldAttributes = [
            NSAttributedString.Key.font: themeManager.font(fontStyle: .primaryBold),
            NSAttributedString.Key.foregroundColor: themeManager.theme.titleTextColor
        ]
        
        let regularAttributes = [
            NSAttributedString.Key.font: themeManager.font(fontStyle: .secondary),
            NSAttributedString.Key.foregroundColor: themeManager.theme.subtitleTextColor
        ]
        
        let linkAttributes = [
            NSAttributedString.Key.font: themeManager.font(fontStyle: .secondaryBold),
            NSAttributedString.Key.foregroundColor: themeManager.linkTextColor
        ]
        
        let attributedTitleString = NSMutableAttributedString()
        if let title = listing.title {
            attributedTitleString.append(NSAttributedString(string: title, attributes: boldAttributes))
        }
        if let domain = listing.domain {
            attributedTitleString.append(NSAttributedString(string: " (\(domain))", attributes: regularAttributes))
        }
        let linkAttributedString = NSMutableAttributedString()
        if let prefixedSubreddit = listing.subredditNamePrefixed {
            linkAttributedString.append(NSAttributedString(string: prefixedSubreddit, attributes: linkAttributes))
        }
        
        let textData = AnnotationTextFormatter().formatter(subreddit: nil, author: listing.author, score: Int(listing.score), date: listing.created)

        // Attributes don't take affect unless pushed on to the main thread 
        DispatchQueue.main.async {
            self.titleLabel.attributedText = attributedTitleString
            self.prefixedSubredditLabel.attributedText = linkAttributedString
            self.upvoteCountLabel.attributedText = textData.score
            self.authorLabel.attributedText = textData.author
            self.dateCreatedLabel.attributedText = textData.date
        }
        
        data = ["subredditId": listing.subredditId]
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
