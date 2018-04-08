//
//  MainCell.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import AVFoundation
import Nuke
import NukeGifuPlugin
import Gifu

class MainCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var playerView: PlayerView!
    @IBOutlet weak var animatedImageView: AnimatedImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        animatedImageView.prepareForReuse()
        removeAttachedView()

        imageView.image = nil
        playerView.player = nil
        imageView.isHidden = true
        playerView.isHidden = true
        animatedImageView.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 4.0
        layoutIfNeeded()
    }
    
    func configureCell(forListing listing: Listing) {
        switch listing.type {
        case .image:
            imageView.isHidden = false
            Manager.shared.loadImage(with: listing.url, into: imageView) { [weak self] response, _ in
                guard let this = self else { return }
                if let image = response.value {
                    this.imageView?.image = image
                } else {
                    this.attachNoImageFound()
                }
            }
        case .animatedImage:
            attachNoImageFound()
            guard let components = URLComponents(string: listing.url.absoluteString) else { return }
            if components.path.hasSuffix(ListingMediaFormat.gif.rawValue) {
                animatedImageView.isHidden = false
                animatedImageView.imageView.contentMode = .scaleAspectFit
                Nuke.Manager.animatedImageManager.loadImage(with: listing.url, into: animatedImageView)
            } else { 
                playerView.isHidden = false
                playerView.player = AVPlayer(url: listing.url)
                playerView.play()
            }
        case .video:
            imageView.isHidden = false
            guard let url = URL(string: listing.thumbnailUrlString ?? listing.urlString) else { return }
            Manager.shared.loadImage(with: url, into: imageView) { [weak self] response, _ in
                guard let this = self else { return }
                this.attachPlayIndicator()
                if let image = response.value {
                    this.imageView?.image = image
                }
            }
        default:
            return
        }
    }
}
