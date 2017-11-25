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
        imageView.isHidden = listing.isPlayable
        webView.isHidden = !listing.isPlayable
        playerView.isHidden = !listing.isPlayable
        
        if listing.isPlayable {
            switch listing.hint {
            case .hostedVideo, .link:
                webView.isHidden = true
                playerView.player = AVPlayer(url: url)
                playerView.playAndLoop()
            case .richVideo:
                playerView.isHidden = true
                webView.load( URLRequest(url: url) )
            default:
                break
            }
        } else {
            imageView.sd_setShowActivityIndicatorView(true)
            imageView.sd_setIndicatorStyle(.gray)
            imageView.sd_setImage(with: url)
        }
    }
}

