//
//  SubscribedCell.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 2/10/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

class SubscribedCell: UITableViewCell {
    @IBOutlet weak var subtitleLabel: SubtitleLabel!
    @IBOutlet weak var titleLabel: TitleLabel!
    @IBOutlet weak var subredditImageView: UIImageView!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        subredditImageView.layer.cornerRadius = subredditImageView.frame.width / 2
    }
}
