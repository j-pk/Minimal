//
//  NotificationBanner.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 10/13/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation
import UIKit

enum NotificationState {
    case vote(direction: UserVoteDirection)
    case error(String)
    case message(String)
    
    var backgroundColor: UIColor {
        switch self {
        case .vote(let direction):
            switch direction {
            case .up: return .orange
            case .down: return .purple
            case .cancel: return .gray
            }
        case .error: return .red
        case .message: return .gray
        }
    }
    
    var message: String {
        switch self {
        case .vote(let direction):
            switch direction {
            case .up: return "Upvote successful"
            case .down: return "Downvote successful"
            case .cancel: return "Canceled vote"
            }
        case .error(let error): return error
        case .message(let message): return message
        }
    }
    
    var image: UIImage {
        switch self {
        case .vote(let direction):
            switch direction {
            case .up: return #imageLiteral(resourceName: "upArrow")
            case .down: return #imageLiteral(resourceName: "downArrow")
            case .cancel: return #imageLiteral(resourceName: "checkmark")
            }
        case .error: return #imageLiteral(resourceName: "minimalSmall")
        case .message: return #imageLiteral(resourceName: "minimalSmall")
        }
    }
}

class NotificationBanner {
    let state: NotificationState

    @discardableResult init(state: NotificationState) {
        self.state = state
        DispatchQueue.main.async {
            self.displayNotification(for: state)
        }
    }
    
    func displayNotification(for state: NotificationState) {
        NotificationView(state: state)
    }
}

private class NotificationView: UIView {
    let state: NotificationState
    let viewController: UIViewController?
    var initialPositionConstraint: NSLayoutConstraint?
    let height: CGFloat = 45

    override var tag: Int {
        get {
            return 777
        }
        set { }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult init(state: NotificationState) {
        self.state = state
        self.viewController = UIApplication.shared.topViewController
        super.init(frame: .zero)
        configureNotificationView()
    }
    
    override func draw(_ rect: CGRect) {
        addShadow()
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
    }
    
    private func configureNotificationView() {
        guard let viewController = viewController else { return }
        guard !viewController.view.subviews.contains(where: { $0.tag == tag }) else { return }
        addRemoveNotificationGesture()
        backgroundColor = state.backgroundColor
        
        let imageView = UIImageView(image: state.image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = state.message
        descriptionLabel.textColor = .white
        descriptionLabel.backgroundColor = .clear
        
        [imageView, descriptionLabel].forEach({ addSubview($0) })
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[imageView(20)]",
                                                               options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                               metrics: nil,
                                                                 views: ["imageView": imageView]))
         addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view]-(<=1)-[descriptionLabel]",
                                                                options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                                metrics: nil,
                                                                  views: ["view": self, "descriptionLabel": descriptionLabel]))
         addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[imageView(20)]-12-[descriptionLabel]-|",
                                                                options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                                metrics: nil,
                                                                  views: ["imageView": imageView, "descriptionLabel": descriptionLabel]))
        
        translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(self)

        initialPositionConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: viewController.view, attribute: .top, multiplier: 1, constant: -100)
        guard let initialPositionConstraint = initialPositionConstraint else { return }
        initialPositionConstraint.priority = UILayoutPriority(rawValue: 999)
        viewController.view.addConstraint(initialPositionConstraint)
        
        viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(viewController.view.safeAreaInsets.top)@998-[view(\(height))]",
                                                                                   options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                                                   metrics: nil,
                                                                                     views: ["view": self]))

        viewController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(viewController.view.layoutMargins.left)-[view]-\(viewController.view.layoutMargins.right)-|",
                                                                                   options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                                                   metrics: nil,
                                                                                     views: ["view": self]))
        animate(constraint: initialPositionConstraint, in: viewController)
    }
    
    private func animate(constraint: NSLayoutConstraint, in viewController: UIViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: [.curveEaseIn], animations: {
                constraint.priority = UILayoutPriority(rawValue: 997)
                viewController.view.layoutIfNeeded()
            }, completion: nil)
        }
        
        animateRemoval(constraint: constraint, in: viewController, forDuration: 3.0)
    }
    
    private func animateRemoval(constraint: NSLayoutConstraint, in viewController: UIViewController, forDuration duration: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: [.curveEaseOut], animations: {
                constraint.priority = UILayoutPriority(rawValue: 999)
                viewController.view.layoutIfNeeded()
            }, completion: { _ in
                self.removeFromSuperview()
            })
        }
    }
    
    private func addRemoveNotificationGesture() {
        let tapAwayGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(removeNotification(sender:)))
        isUserInteractionEnabled = true
        addGestureRecognizer(tapAwayGestureRecognizer)
    }
    
    @objc private func removeNotification(sender: UITapGestureRecognizer) {
        guard let constraint = initialPositionConstraint, let viewController = viewController else { return }
        animateRemoval(constraint: constraint, in: viewController, forDuration: 0.0)
    }
    
}
