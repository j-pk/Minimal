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
    @IBOutlet var imageView: FLAnimatedImageView!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var downVoteWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var upVoteWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleAndDetailsView: TitleAndDetailsView!
    
    var animator: UIDynamicAnimator!
    var listing: Listing?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(isPopped), name: Notification.Name.isPopped, object: nil)
        configureDetailViewController()
        
        animator = UIDynamicAnimator(referenceView: imageView)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanImageView))
        imageView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func isPopped() {
        downVoteWidthConstraint.priority = UILayoutPriority(rawValue: 999)
        upVoteWidthConstraint.priority = UILayoutPriority(rawValue: 999)
    }
    
    func configureDetailViewController() {
        guard let listing = listing, let url = listing.url, let imageUrl = URL(string: url) else { return }
        imageView.sd_setImage(with: imageUrl)
        
        titleAndDetailsView.author = listing.author
        titleAndDetailsView.title = listing.title
        titleAndDetailsView.domain = listing.domain
        titleAndDetailsView.score = listing.score
        titleAndDetailsView.dateCreated = listing.created
        titleAndDetailsView.subredditNamePrefixed = listing.subredditNamePrefixed
        titleAndDetailsView.setLabels()
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

