//
//  DetailViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/7/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import SDWebImage

class DetailViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var imageView: FLAnimatedImageView!
    @IBOutlet var voteStackView: UIStackView!
    
    var animator: UIDynamicAnimator!
    var listing: Listing?
    var isPeeking: Bool = false

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(isPopped), name: Notification.Name.isPeeking, object: nil)
        configureDetailViewController()
        guard let listing = listing, let url = listing.url, let imageUrl = URL(string: url) else { return }
        imageView.sd_setImage(with: imageUrl)
        
        self.animator = UIDynamicAnimator(referenceView: imageView)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanImageView))
        imageView.addGestureRecognizer(panGestureRecognizer)
    }
    
    static func make() -> DetailViewController {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: self.typeName) as! DetailViewController
    }
    
    @objc func isPopped() {
        self.voteStackView.isHidden = false
    }
    
    func configureDetailViewController() {
        self.voteStackView.isHidden = isPeeking
        guard let listing = listing else { return }
        let mutableAttributedString = NSMutableAttributedString()
        
        if let title = listing.title {
            let boldAttribute = [
                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12),
                NSAttributedStringKey.foregroundColor: UIColor.black
            ]
            let boldAttributedString = NSAttributedString(string: title, attributes: boldAttribute)
            
            mutableAttributedString.append(boldAttributedString)
        }
        if let domain = listing.domain {
            let regularAttribute = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 8),
                NSAttributedStringKey.foregroundColor: UIColor.gray
            ]
            let regularAttributedString = NSAttributedString(string: " (\(domain))", attributes: regularAttribute)
            mutableAttributedString.append(regularAttributedString)
        }
        
        //Storyboard refuses to like it when I set the numberOfLines
        titleLabel.numberOfLines = 0
        titleLabel.attributedText = mutableAttributedString
        detailLabel.text = listing.subredditNamePrefixed
        
        var descriptionString = "\(listing.score) upvotes"
        if let author = listing.author {
            descriptionString += " submitted by \(author)"
        }
        if let dateCreated = listing.created {
            descriptionString += " \(dateCreated.timeAgoSinceNow())"
        }
        descriptionLabel.text = descriptionString
    }

    override var previewActionItems: [UIPreviewActionItem] {
        
        let upvoteAction = UIPreviewAction(title: NSLocalizedString("Upvote", comment: ""), style: .default, handler: { (previewAction, viewController) -> Void in
        })
        
        let downvoteAction = UIPreviewAction(title: NSLocalizedString("Downvote", comment: ""), style: .default, handler: { (previewAction, viewController) -> Void in
        })
        
        let shareAction = UIPreviewAction(title: NSLocalizedString("Share", comment: ""), style: .default, handler: { (previewAction, viewController) -> Void in
            
        })
        
        return [upvoteAction, downvoteAction, shareAction]
    }
    
    @objc func didPanImageView(sender: UIPanGestureRecognizer) {
        animator.removeAllBehaviors()
        
        let velocity = sender.velocity(in: self.imageView)
        let imagePushBehavior = UIPushBehavior(items: [self.imageView], mode: UIPushBehaviorMode.instantaneous)
        imagePushBehavior.pushDirection = CGVector(dx: velocity.x * 0.5, dy: velocity.y * 0.5)
        imagePushBehavior.magnitude = 35
        imagePushBehavior.setTargetOffsetFromCenter(UIOffsetMake(-400, 400), for: self.imageView)
        
        let itemBehavior = UIDynamicItemBehavior(items: [imageView])
        itemBehavior.friction = 0.2
        itemBehavior.allowsRotation = true
        
        animator.addBehavior(itemBehavior)
        animator.addBehavior(imagePushBehavior)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.dismiss(animated: false, completion: nil)
            }
        })
    }
}

