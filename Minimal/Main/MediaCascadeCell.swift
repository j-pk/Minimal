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
import NukeGifuPlugin
import Gifu

class MediaCascadeCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var playerView: PlayerView!
    @IBOutlet weak var animatedImageView: AnimatedImageView!
    
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
    
    func configureCell(forListing listing: Listing) {
        switch listing.type {
        case .image:
            imageView.isHidden = false
            let request = Request(url: listing.url).processed(with: RoundedCorners(radius: 4.0))
            Manager.shared.loadImage(with: request, into: imageView) { [weak self] response, _ in
                guard let this = self else { return }
                if let image = response.value {
                    this.imageView?.image = image
                } else {
                    this.attachNoImageFound()
                }
            }
        case .animatedImage:
            guard let components = URLComponents(string: listing.url.absoluteString) else { return }
            if components.path.hasSuffix(ListingMediaFormat.gif.rawValue) {
                animatedImageView.isHidden = false
                animatedImageView.imageView.contentMode = .scaleAspectFit
                Nuke.Manager.animatedImageManager.loadImage(with: listing.url, into: animatedImageView) { [weak self] response, _ in
                    guard let this = self else { return }
                    if let image = response.value, let data = image.animatedImageData {
                        this.animatedImageView.imageView.animate(withGIFData: data)
                    } else {
                        this.attachNoImageFound()
                    }
                }
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
