//
//  SearchCell.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/1/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import Nuke

class SearchCell: UITableViewCell {
    @IBOutlet weak var displayNamePrefixedLabel: TitleLabel!
    @IBOutlet weak var publicDescriptionLabel: SubtitleLabel!
    @IBOutlet weak var subscribersLabel: SubtitleLabel!
    @IBOutlet weak var iconImageView: UIImageView!
    let themeManager = ThemeManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
        iconImageView.clipsToBounds = true
        iconImageView.tintColor = themeManager.theme.tintColor
    }
    
    func setView(forSubreddit subreddit: Subreddit) {
        setSeparatorInset(forInsetValue: .zero)
        displayNamePrefixedLabel.text = subreddit.displayNamePrefixed
        publicDescriptionLabel.text = subreddit.publicDescription
        
        let subscribersAttributes = [
            NSAttributedStringKey.font: themeManager.font(fontStyle: .secondary),
            NSAttributedStringKey.foregroundColor: themeManager.redditOrange
        ]
        let regularAttributes = [
            NSAttributedStringKey.font: themeManager.font(fontStyle: .secondary),
            NSAttributedStringKey.foregroundColor: themeManager.theme.subtitleTextColor
        ]
        
        let attributedString = NSMutableAttributedString()
        let subscribers = NumberFormatter.localizedString(from: NSNumber(value: subreddit.subscribers), number: .decimal)
        attributedString.append(NSAttributedString(string: subscribers, attributes: subscribersAttributes))
        attributedString.append(NSAttributedString(string: " subscribers", attributes: regularAttributes))
        
        subscribersLabel.text = nil
        subscribersLabel.textColor = nil
        subscribersLabel.attributedText = attributedString
        
        if let urlString = subreddit.iconImage, let url = URL(string: urlString) {
            Nuke.loadImage(with: url, into: iconImageView)
        } else {
            iconImageView.image = #imageLiteral(resourceName: "placeholder")
        }
    }
}

