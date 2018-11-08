//
//  AnnotationTextFormatter.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

typealias FormattedAnnotationText = (subreddit: NSAttributedString?, author: NSAttributedString?, score: NSAttributedString?, date: NSAttributedString?)

struct AnnotationTextFormatter {
    func formatter(subreddit: String?, author: String?, score: Int, date: Date?) -> FormattedAnnotationText {
        let themeManager = ThemeManager()
        var data: FormattedAnnotationText = (subreddit: nil, author: nil, score: nil, date: nil)
        
        let regularAttributes = [
            NSAttributedString.Key.font: themeManager.font(fontStyle: .secondary),
            NSAttributedString.Key.foregroundColor: themeManager.theme.subtitleTextColor
        ]
        
        let scoreAttributes = [
            NSAttributedString.Key.font: themeManager.font(fontStyle: .secondary),
            NSAttributedString.Key.foregroundColor: themeManager.redditOrange
        ]
        
        data.score = NSAttributedString(string: score.abbrevation(), attributes: scoreAttributes)
        if let subreddit = subreddit {
            data.subreddit = NSAttributedString(string: subreddit, attributes: regularAttributes)
        }
        if let author = author {
            data.author = NSAttributedString(string: "u/\(author)", attributes: regularAttributes)
        }
        if let dateCreated = date {
            data.date = NSAttributedString(string: dateCreated.timeAgoSinceNow().lowercased(), attributes: regularAttributes)
        }
        
        return data
    }
}
