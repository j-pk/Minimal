//
//  ActionView.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 5/16/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

protocol ActionViewDelegate: class {
    func didSelectPageDownButton(sender: UIButton, listing: Listing?)
    func didSelectCommentButton(sender: UIButton, listing: Listing?)
    func didSelectMoreButton(sender: UIButton, controller: UIAlertController)
}

class ActionView: XibView {
    
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    @IBOutlet weak var pageDownButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    var listing: Listing?
    var model: MainModel?
    weak var delegate: ActionViewDelegate?
    let themeManager = ThemeManager()
    
    func prepareForReuse() {
        listing = nil
        model = nil
    }
    
    // NOTE: For votes, need to persist button state - update listing
    @IBAction func didSelectUpvoteButton(_ sender: UIButton) {
        applyShakeAnimationAndHapticFeedback(toButton: sender)
        guard let listing = listing else { return }
        let direction: UserVoteDirection = listing.voted == 0 ? .up : .cancel
        model?.vote(listing: listing, dir: direction, completionHandler: { [weak self] (error) in
            if let error = error {
                posLog(error: error)
            } else {
                self?.upvoteButton.tintColor = self?.upvoteButton.tintColor == self?.themeManager.redditOrange ? self?.themeManager.theme.tintColor : self?.themeManager.redditOrange
                self?.downvoteButton.tintColor = self?.themeManager.theme.tintColor
            }
        })
    }
    
    @IBAction func didSelectDownvoteButton(_ sender: UIButton) {
        applyShakeAnimationAndHapticFeedback(toButton: sender)
        guard let listing = listing else { return }
        let direction: UserVoteDirection = listing.voted == 0 ? .down : .cancel
        model?.vote(listing: listing, dir: direction, completionHandler: { [weak self] (error) in
            if let error = error as? NetworkError {
                if error.errorCode == 401 {
                    DispatchQueue.main.async {
                        NotificationView(state: .error("Login to vote"))
                    }
                } else {
                    
                }
                posLog(error: error)
                
            } else {
                self?.downvoteButton.tintColor = self?.downvoteButton.tintColor == self?.themeManager.redditOrange ? self?.themeManager.theme.tintColor : self?.themeManager.redditOrange
                self?.upvoteButton.tintColor = self?.themeManager.theme.tintColor
            }
        })
    }
    
    @IBAction func didSelectPageDownButton(_ sender: UIButton) {
        delegate?.didSelectPageDownButton(sender: sender, listing: listing)
    }
    
    @IBAction func didSelectCommentButton(_ sender: UIButton) {
        delegate?.didSelectCommentButton(sender: sender, listing: listing)
    }
    
    @IBAction func didSelectMoreButton(_ sender: UIButton) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let shareAction = UIAlertAction(title: "Share", style: .default) { (action) in
            // shareAction
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            // saveAction
        }
        let hideAction = UIAlertAction(title: "Hide", style: .default) { (action) in
            // hideAction
        }
        let reportAction = UIAlertAction(title: "Report", style: .default) { (action) in
            // reportAction
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        let actions = [shareAction, saveAction, hideAction, reportAction, cancelAction]
        actions.forEach({ controller.addAction($0) })
        delegate?.didSelectMoreButton(sender: sender, controller: controller)
    }
    
    func applyShakeAnimationAndHapticFeedback(toButton button: UIButton) {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.10
        shake.repeatCount = 1
        shake.autoreverses = true
        
        let distance: CGFloat = 8
        let direction = button == upvoteButton ? (button.center.y - distance) : (button.center.y + distance)
        
        let fromPoint = CGPoint(x: button.center.x, y: button.center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: button.center.x, y: direction)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        button.layer.add(shake, forKey: "position")
    }
}

extension ActionViewDelegate {
    func didSelectPageDownButton(sender: UIButton, listing: Listing?) {
        // Empty implementation to allow this method to be optional
    }
}
