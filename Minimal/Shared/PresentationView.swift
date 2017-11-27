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

protocol AttachedActivityIndicatorViewDelegate {
    func startAnimating()
    func stopAnimating()
}

func attachActivityIndicator(toView view: UIView, title: String, blurEffect: UIBlurEffectStyle, indicatorStyle: UIActivityIndicatorViewStyle) {
    let overlayView = UIView()
    overlayView.backgroundColor = .black
    overlayView.alpha = 0.7
    overlayView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(overlayView)
    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[overlayView]-0-|",
                                                       options: NSLayoutFormatOptions.alignAllCenterX,
                                                       metrics: nil,
                                                       views: ["overlayView":overlayView]))
    view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[overlayView]-0-|",
                                                       options: NSLayoutFormatOptions.alignAllCenterY,
                                                       metrics: nil,
                                                       views: ["overlayView":overlayView]))
    
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: blurEffect))
    effectView.layer.cornerRadius = 6
    effectView.layer.masksToBounds = true
    effectView.translatesAutoresizingMaskIntoConstraints = false
    overlayView.addSubview(effectView)
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: indicatorStyle)
    activityIndicator.startAnimating()
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    effectView.contentView.addSubview(activityIndicator)
    
    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = ThemeManager.font(fontType: .primary)
    titleLabel.textColor = ThemeManager.default.primaryTextColor
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    
    effectView.contentView.addSubview(titleLabel)
    
    effectView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[activityIndicator]-|",
                                                             options: NSLayoutFormatOptions.alignAllCenterX,
                                                             metrics: nil,
                                                             views: ["activityIndicator":activityIndicator]))
    effectView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-|",
                                                             options: NSLayoutFormatOptions.alignAllCenterX,
                                                             metrics: nil,
                                                             views: ["titleLabel":titleLabel]))
    effectView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[activityIndicator]-[titleLabel]-|",
                                                             options: NSLayoutFormatOptions.alignAllCenterY,
                                                             metrics: nil,
                                                             views: ["activityIndicator":activityIndicator, "titleLabel":titleLabel]))
    
    
    overlayView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[overlayView]-(<=1)-[effectView]",
                                                              options: NSLayoutFormatOptions.alignAllCenterX,
                                                              metrics: nil,
                                                              views: ["overlayView":overlayView, "effectView":effectView]))
    overlayView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[overlayView]-(<=1)-[effectView]",
                                                              options: NSLayoutFormatOptions.alignAllCenterY,
                                                              metrics: nil,
                                                              views: ["overlayView":overlayView, "effectView":effectView]))
}
}

class PresentationView: XibView {
    @IBOutlet weak var imageView: FLAnimatedImageView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var playerView: PlayerView!
    
    func setView(forListing listing: Listing) {
        guard let listingUrlString = listing.url, let url = URL(string: listingUrlString) else {
            return
        }
        self.backgroundColor = ThemeManager.default.primaryTheme
        webView.navigationDelegate = self
        
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

extension PresentationView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
}
