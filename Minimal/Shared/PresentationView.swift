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
        guard let listingUrlString = listing.url, let url = URL(string: listingUrlString) else { return }
        guard let components = URLComponents(string: listingUrlString) else { return }

        backgroundColor = ThemeManager.default.primaryTheme
        webView.navigationDelegate = self
        
        switch listing.type {
        case .image:
            imageView.isHidden = false
            imageView.sd_setImage(with: url, placeholderImage: nil)
        case .animatedImage:
            if components.path.hasSuffix(ListingMediaFormat.gif.rawValue) {
                imageView.isHidden = false
                imageView.sd_setImage(with: url, placeholderImage: nil)
            } else {
                playerView.isHidden = false
                playerView.player = AVPlayer(url: url)
                playerView.playAndLoop()
            }
        case .video:
            if let host = components.host, host.contains("vimeo") {
                if let thumbnail = listing.thumbnailUrl, let thumbnailUrl = URL(string: thumbnail) {
                    imageView.isHidden = false
                    imageView.sd_setImage(with: thumbnailUrl, placeholderImage: nil)
                }
            } else {
                webView.isHidden = false
                attachActivityIndicator(title: "Loading", blurEffect: .light, indicatorStyle: .white)
                webView.load( URLRequest(url: url) )
            }
        default:
            return
        }
    }
}

extension PresentationView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        removeActivityIndicatorView()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        removeActivityIndicatorView()
    }
}
