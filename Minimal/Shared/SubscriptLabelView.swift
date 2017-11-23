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
        let boldAttribute = [
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12),
            NSAttributedStringKey.foregroundColor: UIColor.black
        ]
        
        let regularAttribute = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 8),
            NSAttributedStringKey.foregroundColor: UIColor.gray
        ]
        
        let highlightedAttribute = [
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 8),
            NSAttributedStringKey.foregroundColor: UIColor.orange
        ]
        
        let mutableAttributedTitleString = NSMutableAttributedString()
        if let title = listing.title {
            let boldAttributedString = NSAttributedString(string: title, attributes: boldAttribute)
            mutableAttributedTitleString.append(boldAttributedString)
        }
        if let domain = listing.domain {
            let regularAttributedString = NSAttributedString(string: " (\(domain))", attributes: regularAttribute)
            mutableAttributedTitleString.append(regularAttributedString)
        }
        
        titleLabel.attributedText = mutableAttributedTitleString
        detailLabel.text = listing.subredditNamePrefixed
        detailLabel.textColor = .blue
        
        var descriptionString = "\(listing.score) upvotes"
        if let author = listing.author {
            descriptionString += " submitted by \(author)"
        }
        if let dateCreated = listing.created {
            descriptionString += " \(dateCreated.timeAgoSinceNow())"
        }
        let descriptionAttributedString = NSMutableAttributedString(string: descriptionString)
        descriptionAttributedString.addAttributes(highlightedAttribute, range: (descriptionString as NSString).range(of: "\(listing.score)"))
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
        delegate?.didTapDetailLabel(subredditNamePrefixed: subredditNamePrefixed)
    }
}
