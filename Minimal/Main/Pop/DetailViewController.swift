//
//  DetailViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/7/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var presentationView: PresentationView!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var downVoteWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var upVoteWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var annotationView: AnnotationView!
    
    var animator: UIDynamicAnimator!
    var listing: Listing?
    var themeManager = ThemeManager()
    var database: Database?
    weak var delegate: SubredditSelectionProtocol?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(isPopped), name: Notification.Name.isPopped, object: nil)
        configureDetailViewControllerViews()

        animator = UIDynamicAnimator(referenceView: presentationView)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanPresentationView))
        view.addGestureRecognizer(panGestureRecognizer)
        view.backgroundColor = themeManager.theme.primaryColor
    }
    
    @objc func isPopped() {
        downVoteWidthConstraint.priority = UILayoutPriority(rawValue: 999)
        upVoteWidthConstraint.priority = UILayoutPriority(rawValue: 999)
        view.layoutIfNeeded()
    }
    
    func configureDetailViewControllerViews() {
        guard let listing = listing else { return }
        annotationView.delegate = self
        annotationView.setAnnotations(forListing: listing)
        presentationView.setView(forListing: listing)
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
    
    @objc func didPanPresentationView(sender: UIPanGestureRecognizer) {
        animator.removeAllBehaviors()
        
        let velocity = sender.velocity(in: presentationView)
        let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        let threshold: CGFloat = 1000
        let velocityPadding: CGFloat = 35
        
        if magnitude > threshold {
            let imagePushBehavior = UIPushBehavior(items: [presentationView], mode: .instantaneous)
            imagePushBehavior.pushDirection = CGVector(dx: velocity.x / 10, dy: velocity.y / 10)
            imagePushBehavior.magnitude = magnitude / velocityPadding
            
            let itemBehavior = UIDynamicItemBehavior(items: [presentationView])
            let angle = CGFloat(arc4random_uniform(20)) - 10
            
            itemBehavior.friction = 0.2
            itemBehavior.allowsRotation = true
            itemBehavior.addAngularVelocity(angle, for: presentationView)
            
            animator.addBehavior(itemBehavior)
            animator.addBehavior(imagePushBehavior)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.alpha = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.dismiss(animated: false, completion: nil)
                }
            })
        }
    }
}

extension DetailViewController: UIViewTappableDelegate {
    func didTapView(sender: UITapGestureRecognizer, data: [String: Any?]) {
        if let prefixedSubreddit = data["subreddit"] as? String, let database = self.database {
            dismiss(animated: true) {
                self.delegate?.didSelect(prefixedSubreddit: prefixedSubreddit, context: database.viewContext)
            }
        }
    }
}
