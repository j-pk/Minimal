//
//  MediaCascadeCell.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import AVFoundation
import Nuke
import Gifu

class MediaCascadeCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var playerView: PlayerView!
    @IBOutlet weak var animatedImageView: GIFImageView!
    
    class var identifier: String {
        return String(describing: self)
    }
    
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
    }
    
    func configureCell(forListing listing: Listing, with model: MainModel?) {
        model?.fetchAndCacheImage(for: listing, completionHandler: { [weak self] (imageData) in
            guard let this = self else { return }
            switch listing.type {
            case .image:
                this.imageView.isHidden = false
                if let image = imageData.image {
                    this.imageView.image = image
                } else {
                    this.attachNoImageFound()
                }
            case .animatedImage:
                guard let components = URLComponents(string: listing.url.absoluteString) else { return }
                if components.path.hasSuffix(ListingMediaFormat.gif.rawValue), let data = imageData.data {
                    this.animatedImageView.isHidden = false
                    this.animatedImageView.contentMode = .scaleAspectFit
                    this.animatedImageView.animate(withGIFData: data)
                } else {
                    this.playerView.isHidden = false
                    this.playerView.player = AVPlayer(url: listing.url)
                    this.playerView.play()
                }
            case .video:
                this.imageView.isHidden = false
                this.attachPlayIndicator()
                this.imageView.image = imageData.image
            default:
                return
            }
        })
    }
}
