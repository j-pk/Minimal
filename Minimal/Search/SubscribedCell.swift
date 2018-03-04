//
//  SubscribedCell.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 2/10/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

class SubscribedCell: UITableViewCell {
    @IBOutlet weak var titleLabel: TitleLabel!
    @IBOutlet weak var subtitleLabel: SubtitleLabel!
    @IBOutlet weak var subredditImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func setView() {
        
    }
}
