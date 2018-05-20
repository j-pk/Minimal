//
//  ActionView.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 5/16/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

class ActionView: XibView {
    
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downvoteButton: UIButton!
    @IBOutlet weak var pageDownButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBAction func didSelectUpvoteButton(_ sender: UIButton) {
        applyShakeAnimationAndHapticFeedback(toButton: sender)
    }
    @IBAction func didSelectDownvoteButton(_ sender: UIButton) {
        applyShakeAnimationAndHapticFeedback(toButton: sender)
    }
    @IBAction func didSelectPageDownButton(_ sender: UIButton) {
    }
    @IBAction func didSelectCommentButton(_ sender: UIButton) {
    }
    @IBAction func didSelectMoreButton(_ sender: UIButton) {
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
