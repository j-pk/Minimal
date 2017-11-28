//
//  MainCell.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import AVFoundation
import SDWebImage

class MainCell: UICollectionViewCell {
    @IBOutlet var imageView: FLAnimatedImageView!
    @IBOutlet var playerView: PlayerView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        playerView.player = nil
        imageView.isHidden = true
        playerView.isHidden = true 
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 4.0
        layoutIfNeeded()
    }
    
    func configureCell(forListing listing: Listing) {
        guard let listingUrlString = listing.url, let url = URL(string: listingUrlString) else {
            return
        }
        
        switch listing.type {
        case .image:
            imageView.isHidden = false
            imageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        case .animatedImage:
            guard let components = URLComponents(string: listingUrlString) else { return }
            if components.path.hasSuffix(ListingMediaFormat.gif.rawValue) {
                imageView.isHidden = false
                imageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder"))
            } else {
                playerView.isHidden = false
                playerView.player = AVPlayer(url: url)
                playerView.playAndLoop()
            }
        case .video:
            guard let thumbnailString = listing.thumbnailUrl, let thumbnailUrl = URL(string: thumbnailString) else { return }
            imageView.isHidden = false
            imageView.sd_setImage(with: thumbnailUrl, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        default:
            return
        }
    }
}
