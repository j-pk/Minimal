//
//  MediaCompactCell.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/5/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit
import AVFoundation
import Nuke
import Gifu

class MediaCompactCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var playerView: PlayerView!
    @IBOutlet weak var animatedImageView: GIFImageView!
    @IBOutlet weak var subredditLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var actionView: ActionView!
    weak var delegate: UIViewTappableDelegate?
    private var data: [String:Any?] = [:]
    private let themeManager = ThemeManager()
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        animatedImageView.prepareForReuse()
        actionView.prepareForReuse()
        containerView.removeAttachedView()
        removeGestureRecognizer(tapGestureRecognizer)
        
        imageView.image = nil
        playerView.player = nil
        data = [:]
        imageView.isHidden = true
        playerView.isHidden = true
        animatedImageView.isHidden = true
    }
    
    func configureCell(forListing listing: Listing, with model: MainModel?) {
        configureAnnotations(forListing: listing)
        backgroundColor = themeManager.theme.secondaryColor

        actionView.listing = listing
        actionView.database = model?.database
        actionView.scoreLabel.isHidden = false
        model?.fetchAndCacheImage(for: listing, completionHandler: { [weak self] (imageData) in
            guard let this = self else { return }
            switch listing.type {
            case .image:
                this.imageView.isHidden = false
                //                if listing.over18 {
                //                    request = ImageRequest(url: listing.url).processed(with: Pixelate(scale: 50))
                //                    self.containerView.attachNSFWLabel()
                //                }
                if let image = imageData.image {
                    this.imageView.image = image
                } else {
                    this.containerView.attachNoImageFound()
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
                this.containerView.attachPlayIndicator()
                this.imageView.image = imageData.image
            default:
                return
            }
        })
        layoutIfNeeded()
    }
    
    func configureAnnotations(forListing listing: Listing) {
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
        iconImageView.clipsToBounds = true
        iconImageView.tintColor = themeManager.theme.tintColor

        if let subreddit = listing.subreddit, let urlString = subreddit.iconImage, let url = URL(string: urlString) {
            Nuke.loadImage(with: url, into: iconImageView)
        } else {
            iconImageView.image = #imageLiteral(resourceName: "placeholder")
        }
        let regularAttributes = [
            NSAttributedString.Key.font: themeManager.font(fontStyle: .secondary),
            NSAttributedString.Key.foregroundColor: themeManager.theme.primaryColor
        ]
        let titleAttributes = [
            NSAttributedString.Key.font: themeManager.font(fontStyle: .secondary),
            NSAttributedString.Key.foregroundColor: themeManager.theme.titleTextColor
        ]
        let linkAttributes = [
            NSAttributedString.Key.font: themeManager.font(fontStyle: .secondaryBold),
            NSAttributedString.Key.foregroundColor: themeManager.linkTextColor
        ]
        let titleAttributedString = NSMutableAttributedString()
        if let title = listing.title {
            titleAttributedString.append(NSAttributedString(string: title, attributes: titleAttributes))
        }
        let subredditAttributedString = NSMutableAttributedString()
        if let subreddit = listing.subredditNamePrefixed {
            subredditAttributedString.append(NSAttributedString(string: subreddit, attributes: linkAttributes))
        }
        let dateAttributedString = NSMutableAttributedString()
        if let date = listing.created {
            dateAttributedString.append(NSAttributedString(string: "∙ ", attributes: [NSAttributedString.Key.font: themeManager.font(fontStyle: .secondary),
                NSAttributedString.Key.foregroundColor: themeManager.theme.tintColor]))
            dateAttributedString.append(NSAttributedString(string: date.timeAgoSinceNow(abbreviated: true), attributes: regularAttributes))
        }
        
        titleTextView.contentInset = UIEdgeInsets(top: -8, left: 0, bottom: -8, right: 0)
        DispatchQueue.main.async {
            self.titleTextView.attributedText = titleAttributedString
            self.subredditLabel.attributedText = subredditAttributedString
            self.timeLabel.attributedText = dateAttributedString
            let rect = CGRect(x: self.contentView.frame.width - 100, y: 8, width: 90, height: 35)
            let exclusionPath = UIBezierPath(rect: rect)
            self.titleTextView.textContainer.exclusionPaths = [exclusionPath]
            self.titleTextView.isScrollEnabled = false
            self.titleTextView.isScrollEnabled = true
            self.titleTextView.isUserInteractionEnabled = false
        }
        
        data = ["subredditId": listing.subredditId]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subredditLabel.isUserInteractionEnabled = true
        subredditLabel.addGestureRecognizer(tapGestureRecognizer)
    }
}

extension MediaCompactCell: Tappable, Recognizer {
    func didTapView(_ sender: UITapGestureRecognizer) {
        delegate?.didTapView(sender: sender, data: data)
    }
}
