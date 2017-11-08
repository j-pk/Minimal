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
    var imageView: FLAnimatedImageView!
    var animator: UIDynamicAnimator!
    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDetailViewController()
        guard let url = url, let imageUrl = URL(string: url) else { return }
        imageView.sd_setImage(with: imageUrl)
        
        self.animator = UIDynamicAnimator(referenceView: imageView)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanImageView))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func configureDetailViewController() {
        imageView = FLAnimatedImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[imageView]-0-|",
                                                            options: NSLayoutFormatOptions.alignAllCenterX,
                                                            metrics: nil,
                                                            views: ["imageView":imageView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[imageView]-0-|",
                                                            options: NSLayoutFormatOptions.alignAllCenterY,
                                                            metrics: nil,
                                                            views: ["imageView":imageView]))
    }
    
    func addMenuItems(menu:String ...) -> [UIPreviewActionItem] {
        var arrPreview = [UIPreviewActionItem]()
        for m in menu {
            let likeAction = UIPreviewAction(title:m, style: .default) { (action, viewController) -> Void in
                print(action.title)
            }
            arrPreview.append(likeAction)
        }
        return arrPreview
    }
    override var previewActionItems: [UIPreviewActionItem] {
        return self.addMenuItems(menu: "Upvote", "Downvote", "Share", "Save")
    }
    
    @objc func didPanImageView(sender: UIPanGestureRecognizer) {
        animator.removeAllBehaviors()
        
        let velocity = sender.velocity(in: self.imageView)
        let imagePushBehavior = UIPushBehavior(items: [self.imageView], mode: UIPushBehaviorMode.instantaneous)
        imagePushBehavior.pushDirection = CGVector(dx: velocity.x, dy: velocity.y)
        imagePushBehavior.magnitude = 1
        
        let itemBehavior = UIDynamicItemBehavior(items: [imageView])
        itemBehavior.friction = 0.5
        itemBehavior.allowsRotation = true
        
        animator.addBehavior(itemBehavior)
        animator.addBehavior(imagePushBehavior)
        
        UIView.animate(withDuration: 0.6, animations: { () -> Void in
            self.imageView.alpha = 0
        }, completion: { _ in
            self.dismiss(animated: true, completion: nil)
        })
    }
}

