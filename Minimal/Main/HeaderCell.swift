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
    @IBOutlet var sdImageView: FLAnimatedImageView!
    @IBOutlet weak var titleAndDetailsView: TitleAndDetailsView!
    var url: URL?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(forListing listing: Listing) {
        guard let listingUrlString = listing.url, let url = URL(string: listingUrlString) else {
            return
        }
        
        titleAndDetailsView.author = listing.author
        titleAndDetailsView.title = listing.title
        titleAndDetailsView.domain = listing.domain
        titleAndDetailsView.score = listing.score
        titleAndDetailsView.dateCreated = listing.created
        titleAndDetailsView.subredditNamePrefixed = listing.subredditNamePrefixed
        titleAndDetailsView.setLabels()
        sdImageView.sd_setImage(with: url, placeholderImage: nil)
    }
}
