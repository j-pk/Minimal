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
    @IBOutlet weak var bodyLabel: UILabel!
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
    }
    
    func configure(for node: ChildData?) {
        authorLabel.text = node?.author
        if let score = node?.score {
            votesLabel.text = "\(score)"
        } else {
            votesLabel.isHidden =  true
        }
        if let createdUTC = node?.createdUTC {
            timeCreatedLabel.text = Date(timeIntervalSince1970: TimeInterval(createdUTC)).timeAgoSinceNow().lowercased()
        } else {
            timeCreatedLabel.isHidden = true
        }
        bodyLabel.text = node?.body

        if let depth = node?.depth, depth > 0 {
            leadingConstraint.constant = leadingConstraint.constant * CGFloat(depth + 1)
        }
    }
}
