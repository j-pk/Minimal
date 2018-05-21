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
            var request = ImageRequest(url: listing.url).processed(with: RoundedCorners(radius: 4))
            if listing.over18 {
                request = ImageRequest(url: listing.url).processed(with: Pixelate(scale: 50))
            }
            let image = ImageCache.shared[request]
            self.imageView.image = image
        case .animatedImage:
            attachNoImageFound(message: "No Data")
            if components.path.hasSuffix(ListingMediaFormat.gif.rawValue) {
                animatedImageView.isHidden = false
                animatedImageView.contentMode = .scaleAspectFit
                Nuke.loadImage(with: listing.url, into: animatedImageView)
            } else {
                playerView.isHidden = false
                playerView.player = AVPlayer(url: url)
                playerView.play()
            }
        case .video:
            if let host = components.host, host.contains("vimeo") || host.contains("streamable") {
                if let thumbnail = listing.thumbnailUrlString, let thumbnailUrl = URL(string: thumbnail) {
                    imageView.isHidden = false
                    Nuke.loadImage(with: url, into: imageView)
                    data = ["url": thumbnailUrl]
                    attachPlayIndicator()
                }
            } else {
                webView.isHidden = false
                data = ["url": url]
                attachActivityIndicator(message: "Loading", blurEffect: .light, indicatorStyle: .white)
                webView.load( URLRequest(url: url) )
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
