//
//  CategoryPopoverViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/13/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

class CategoryPopoverViewController: UIViewController {
    
    @IBOutlet weak var hotButton: UIButton!
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var risingButton: UIButton!
    @IBOutlet weak var controversialButton: UIButton!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var timeFrameScrollView: UIScrollView!
    
    @IBAction func didPressCategoryButton(_ sender: UIButton) {
        guard let type = ListingCategoryType.allValues.filter({ $0.titleValue == sender.titleLabel?.text }).first else { return }
        if type.isSetByTimeFrame {
            self.preferredContentSize = CGSize(width: 160, height: 100)
            timeFrameScrollView.isHidden = false
        } else {
            timeFrameScrollView.isHidden = true
            self.preferredContentSize = CGSize(width: 160, height: 60)
        }
        DispatchQueue.main.async {
            let x = (self.timeFrameScrollView.contentSize.width / 2) - (self.view.bounds.size.width / 2)
            self.timeFrameScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        }
        selectButton(button: sender)
    }
    
    func selectButton(button: UIButton) {
        button.backgroundColor = .red
        button.layer.cornerRadius = 4.0
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    func deselectButton(button: UIButton) {
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }
}
