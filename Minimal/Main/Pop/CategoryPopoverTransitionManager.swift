//
//  CategoryPopoverTransitionManager.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 4/14/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

class CategoryPopoverTransitionManager: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else { return }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else { return }
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)
        let presenting = toView != nil ? true : false
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        var headerViewHeight: CGFloat = 0
        
        if presenting {
            guard let mainViewController = (fromViewController as? UITabBarController)?.fetch(viewController: MainViewController.self) else { return }
            headerViewHeight = mainViewController.headerView.frame.height
            containerView.addSubview(toViewController.view)
        } else {
            guard let mainViewController = (toViewController as? UITabBarController)?.fetch(viewController: MainViewController.self) else { return }
            headerViewHeight = mainViewController.headerView.frame.height
        }
        
        toViewController.view.alpha = presenting ? 0.0 : 1.0
        toViewController.view.frame.origin = presenting ? CGPoint(x: 0, y: headerViewHeight - 10) : toViewController.view.frame.origin
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.75, options: .curveLinear, animations: {
            toViewController.view.alpha = 1.0
            toViewController.view.frame.origin = presenting ? CGPoint(x: 0, y: (headerViewHeight + statusBarHeight) - 10) : toViewController.view.frame.origin
            
            fromViewController.view.alpha = presenting ? 0.5 : 0.0
            fromViewController.view.frame.origin = presenting ? fromViewController.view.frame.origin : CGPoint(x: 0, y: headerViewHeight)
        }, completion: { isCompleted in
            transitionContext.completeTransition(true)
        })
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
