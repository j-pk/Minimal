//
//  PresentationView.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/19/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import Nuke
import Gifu
import WebKit
import AVFoundation

class PresentationView: XibView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var animatedImageView: GIFImageView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var playerView: PlayerView!
    
    weak var delegate: UIViewTappableDelegate?
    private var data: [String: Any?] = [:]
    fileprivate let themeManager = ThemeManager()
    
    func prepareForeReuse() {
        imageView.image = nil
        playerView.pause()
        playerView.player = nil
        removeAttachedView()
        animatedImageView.prepareForReuse()
        animatedImageView.animationImages = nil

        imageView.isHidden = true
        animatedImageView.isHidden = true
        webView.isHidden = true
        playerView.isHidden = true
    }
    
    func setView(forListing listing: Listing) {
        guard let url = URL(string: listing.urlString) else { return }
        guard let components = URLComponents(string: listing.urlString) else { return }

        backgroundColor = themeManager.theme.primaryColor
        webView.navigationDelegate = self
        
        addGestureRecognizer(tapGestureRecognizer)
        
        switch listing.type {
        case .image:
            data = ["image": url]
            imageView.isHidden = false
            let image = ImageCache.shared[listing.request]
            imageView.image = image
        case .animatedImage:
            if components.path.hasSuffix(ListingMediaFormat.gif.rawValue), let data = ImageCache.shared[listing.request]?.animatedImageData {
                animatedImageView.isHidden = false
                animatedImageView.contentMode = .scaleAspectFit
                animatedImageView.animate(withGIFData: data)
            } else {
                playerView.isHidden = false
                playerView.player = AVPlayer(url: url)
                playerView.play()
            }
        case .video:
            if let host = components.host, host.contains("vimeo") || host.contains("streamable") {
                imageView.isHidden = false
                let image = ImageCache.shared[listing.request]
                self.imageView.image = image
                data = ["url": listing.thumbnailUrlString]
                attachPlayIndicator()
            } else {
                webView.isHidden = false
                data = ["url": url]
                attachActivityIndicator(message: "Loading", blurEffect: .light, indicatorStyle: .white)
                webView.load(URLRequest(url: url))
            }
        default:
            return
        }
    }
}

extension PresentationView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        removeAttachedView()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        removeAttachedView()
    }
}

extension PresentationView: Tappable, Recognizer {
    func didTapView(_ sender: UITapGestureRecognizer) {
        delegate?.didTapView(sender: sender, data: data)
    }
}
