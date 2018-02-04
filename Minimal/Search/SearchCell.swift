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
        
        guard let urlString = subreddit.iconImage, let url = URL(string: urlString) else {
            iconImageView.isHidden = true
            return
        }
        Manager.shared.loadImage(with: url, into: iconImageView)
    }
}

