//
//  PresentationView.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/19/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import SDWebImage
import WebKit
import AVFoundation

class PresentationView: XibView {
    @IBOutlet weak var imageView: FLAnimatedImageView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var playerView: PlayerView!
    
    func setView(forListing listing: Listing) {
        guard let listingUrlString = listing.url, let url = URL(string: listingUrlString) else {
            return
        }
        
        switch listing.mediaType.listingMediaType {
        case .image:
            imageView.isHidden = false
            imageView.sd_setImage(with: url, placeholderImage: nil)
        case .animatedImage:
            guard let components = URLComponents(string: listingUrlString) else { return }
            if components.path.hasSuffix(ListingMediaFormat.gif.rawValue) {
                imageView.isHidden = false
                imageView.sd_setImage(with: url, placeholderImage: nil)
            } else {
                playerView.isHidden = false
                playerView.player = AVPlayer(url: url)
                playerView.playAndLoop()
            }
        case .video:
            webView.isHidden = false
            webView.load( URLRequest(url: url) )
        default:
            return
        }
        
    }
}

