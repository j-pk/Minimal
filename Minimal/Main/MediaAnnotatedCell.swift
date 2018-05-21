//
//  MediaAnnotatedCell.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import AVFoundation
import Nuke
import Gifu

class MediaAnnotatedCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var playerView: PlayerView!
    @IBOutlet weak var animatedImageView: GIFImageView!
    @IBOutlet weak var annotationView: AnnotationView!
    @IBOutlet weak var actionView: ActionView!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        animatedImageView.prepareForReuse()
        containerView.removeAttachedView()
        
        imageView.image = nil
        playerView.player = nil
        imageView.isHidden = true
        playerView.isHidden = true
        animatedImageView.isHidden = true
        actionView.pageDownButton.isHidden = true
    }
    
    func configureCell(forListing listing: Listing) {
        annotationView.setLabels(forListing: listing)
        switch listing.type {
        case .image:
            imageView.isHidden = false
            var request = ImageRequest(url: listing.url).processed(with: RoundedCorners(radius: 4))
            if listing.over18 {
                request = ImageRequest(url: listing.url).processed(with: Pixelate(scale: 50))
                self.containerView.attachNSFWLabel()
            }
            if let image = ImageCache.shared[request] {
                self.imageView.image = image
            } else {
                Nuke.loadImage(with: request, into: imageView) { [weak self] response, _ in
                    guard let this = self else { return }
                    if let image = response?.image {
                        this.imageView?.image = image
                        ImageCache.shared[request] = image
                    } else {
                        this.containerView.attachNoImageFound()
                    }
                }
            }
        case .animatedImage:
            guard let components = URLComponents(string: listing.url.absoluteString) else { return }
            if components.path.hasSuffix(ListingMediaFormat.gif.rawValue) {
                animatedImageView.isHidden = false
                animatedImageView.contentMode = .scaleAspectFit
                if let image = ImageCache.shared[ImageRequest(url: listing.url)], let data = image.animatedImageData {
                    self.animatedImageView.animate(withGIFData: data)
                } else {
                    Nuke.loadImage(with: listing.url, into: animatedImageView) { [weak self] response, _ in
                        guard let this = self else { return }
                        if let image = response?.image, let data = image.animatedImageData {
                            ImageCache.shared[ImageRequest(url: listing.url)] = image
                            this.animatedImageView.animate(withGIFData: data)
                        } else {
                            this.containerView.attachNoImageFound()
                        }
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
            Nuke.loadImage(with: url, into: imageView) { [weak self] response, _ in
                guard let this = self else { return }
                this.containerView.attachPlayIndicator()
                if let image = response?.image {
                    this.imageView?.image = image
                }
            }
        default:
            return
        }
        actionView.pageDownButton.isHidden = true
        layoutIfNeeded()
    }
}

