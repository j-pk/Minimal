//
//  CommentCell.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/22/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit
import Down

class CommentCell: UITableViewCell {
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var timeCreatedLabel: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    private var themeManager = ThemeManager()
    
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leadingConstraint.constant = 12
        authorLabel.isHidden = false
        votesLabel.isHidden = false
        timeCreatedLabel.isHidden = false
        authorLabel.text = nil
        votesLabel.text = nil
        timeCreatedLabel.text = nil
        bodyTextView.text = nil
        contentView.removeAttachedView()
    }
    
    func configure(for node: ChildData?) {
        setSeparatorInset(forInsetValue: .none)
        selectionStyle = .none
        guard let node = node else { return }
        
        var score: Int?
        if let nodeScore = node.score {
            score = nodeScore
        } else {
            votesLabel.isHidden =  true
        }
        var date: Date?
        if let createdUTC = node.createdUTC {
            date = Date(timeIntervalSince1970: TimeInterval(createdUTC))
        } else {
            timeCreatedLabel.isHidden = true
        }
        
        let textData = AnnotationTextFormatter().formatter(author: node.author, score: score ?? 0, date: date)
        let authorAttributedString = NSMutableAttributedString()
        if let author = textData.author {
            authorAttributedString.append(author)
            if let op = node.isSubmitter, op {
                let opAttributes = [NSAttributedString.Key.font: themeManager.font(fontStyle: .secondaryBold), NSAttributedString.Key.foregroundColor: themeManager.linkTextColor]
                authorAttributedString.append(NSAttributedString(string: " OP", attributes: opAttributes))
            }
        }
        let scoreAttributedString = NSMutableAttributedString()
        if let score = textData.score {
            let attributes = score.attributes(at: 0, effectiveRange: nil)
            scoreAttributedString.append(score)
            scoreAttributedString.append(NSAttributedString(string: " points", attributes: attributes))
        }
        let dateAttributedString = NSMutableAttributedString()
        if let date = textData.date {
            let attributes = date.attributes(at: 0, effectiveRange: nil)
            dateAttributedString.append(NSAttributedString(string: "∙  ", attributes: attributes))
            dateAttributedString.append(date)
        }
        let stylesheet = themeManager.stylesheet()
        if let body = node.body {
            let down = Down(markdownString: body)
            bodyTextView.attributedText = try? down.toAttributedString(.default, stylesheet: stylesheet)
        }
        DispatchQueue.main.async {
            self.authorLabel.attributedText = authorAttributedString
            self.votesLabel.attributedText = scoreAttributedString
            self.timeCreatedLabel.attributedText = dateAttributedString
        }

        if let depth = node.depth, depth > 0 {
            let leftPosition = leadingConstraint.constant * CGFloat(depth + 1)
            leadingConstraint.constant = leftPosition
            contentView.attachDividerLine(forDepth: depth)
        }
    }
}
