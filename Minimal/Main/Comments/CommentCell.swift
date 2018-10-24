//
//  CommentCell.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/22/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var timeCreatedLabel: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
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

        
        DispatchQueue.main.async {
            self.authorLabel.attributedText = textData.author
            self.votesLabel.attributedText = scoreAttributedString
            self.timeCreatedLabel.attributedText = dateAttributedString
        }
        bodyTextView.text = node.body
        
        if let depth = node.depth, depth > 0 {
            leadingConstraint.constant = leadingConstraint.constant * CGFloat(depth + 1)
        }
    }
}
