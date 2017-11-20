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
    
    func setLabels(forListing listing: Listing) {
        let mutableAttributedString = NSMutableAttributedString()
        
        if let title = listing.title {
            let boldAttribute = [
                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12),
                NSAttributedStringKey.foregroundColor: UIColor.black
            ]
            let boldAttributedString = NSAttributedString(string: title, attributes: boldAttribute)
            
            mutableAttributedString.append(boldAttributedString)
        }
        if let domain = listing.domain {
            let regularAttribute = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 8),
                NSAttributedStringKey.foregroundColor: UIColor.gray
            ]
            let regularAttributedString = NSAttributedString(string: " (\(domain))", attributes: regularAttribute)
            mutableAttributedString.append(regularAttributedString)
        }
        
        titleLabel.attributedText = mutableAttributedString
        detailLabel.text = listing.subredditNamePrefixed
        
        var descriptionString = "\(listing.score) upvotes"
        if let author = listing.author {
            descriptionString += " submitted by \(author)"
        }
        if let dateCreated = listing.created {
            descriptionString += " \(dateCreated.timeAgoSinceNow())"
        }
        descriptionLabel.text = descriptionString
    }
}
