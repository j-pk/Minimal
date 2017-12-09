//
//  PresentationView.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/19/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import Nuke
import NukeGifuPlugin
import WebKit
import AVFoundation

class PresentationView: XibView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var animatedImageView: AnimatedImageView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var playerView: PlayerView!
    
    weak var delegate: UIViewTappableDelegate?
    private var data: [String:Any?] = [:]
    fileprivate let themeManager = ThemeManager()
    
    func prepareForeReuse() {
        imageView.image = nil
        playerView.pause()
        playerView.player = nil
        removeIndicatorView()
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
            data = ["image":url]
            imageView.isHidden = false
            Manager.shared.loadImage(with: url, into: imageView)
        case .animatedImage:
            if components.path.hasSuffix(ListingMediaFormat.gif.rawValue) {
                animatedImageView.isHidden = false
                animatedImageView.imageView.contentMode = .scaleAspectFit
                AnimatedImage.manager.loadImage(with: listing.url, into: animatedImageView)
            } else {
                playerView.isHidden = false
                playerView.player = AVPlayer(url: url)
                playerView.play()
            }
        case .video:
            if let host = components.host, host.contains("vimeo") || host.contains("streamable") {
                if let thumbnail = listing.thumbnailUrlString, let thumbnailUrl = URL(string: thumbnail) {
                    imageView.isHidden = false
                    Manager.shared.loadImage(with: url, into: imageView)
                    data = ["url":thumbnailUrl]
                    attachPlayIndicator(blurEffect: .regular)
                }
            } else {
                webView.isHidden = false
                data = ["url":url]
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
        removeIndicatorView()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        removeIndicatorView()
    }
}

extension PresentationView: Tappable, Recognizer {
    func didTapView(_ sender: UITapGestureRecognizer) {
        delegate?.didTapView(sender: sender, data: data)
    }
}
