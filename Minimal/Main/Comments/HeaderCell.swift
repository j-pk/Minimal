//
//  HeaderCell.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/18/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import SDWebImage

class HeaderCell: UITableViewCell {
    @IBOutlet weak var subscriptLabelView: SubscriptLabelView!
    @IBOutlet weak var presentationView: PresentationView!
    var url: URL?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(forListing listing: Listing) {
        subscriptLabelView.setLabels(forListing: listing)
        presentationView.setView(forListing: listing)
    }
}
