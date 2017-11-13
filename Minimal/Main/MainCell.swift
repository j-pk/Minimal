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
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(forListing listing: Listing) {
        guard let listingUrlString = listing.url, let url = URL(string: listingUrlString) else {
            return
        }
        
        imageView.isHidden = listing.isPlayable
        imageView.sd_setShowActivityIndicatorView(true)
        imageView.sd_setIndicatorStyle(.gray)
        if listing.isPlayable {
            if listing.hint == .hostedVideo {
                //if reddit hosted video cell tapped present AVPlayerViewController and Play
                return
            }
            playerView.player = AVPlayer(url: url)
            playerView.playAndLoop()
        } else {
            imageView.sd_setImage(with: url, placeholderImage: nil)
        }
    }
}