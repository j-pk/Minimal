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
    
    @IBOutlet weak var oneHour: UIButton!
    @IBOutlet weak var twentyFourHours: UIButton!
    @IBOutlet weak var week: UIButton!
    @IBOutlet weak var month: UIButton!
    @IBOutlet weak var year: UIButton!
    @IBOutlet weak var allTime: UIButton!
    
    var category: ListingCategoryType = .hot
    var timeFrame: CategoryTimeFrame?
    var themeManager = ThemeManager()
    
    @IBAction func didPressCategoryButton(_ sender: UIButton) {
        guard let selectedCategory = ListingCategoryType.allValues.filter({ $0.titleValue == sender.titleLabel?.text }).first else { return }
        category = selectedCategory

        if selectedCategory.isSetByTimeFrame {
            self.preferredContentSize = CGSize(width: self.view.frame.width, height: 100)
            timeFrameScrollView.isHidden = false
        } else {
            timeFrameScrollView.isHidden = true
            self.preferredContentSize = CGSize(width: self.view.frame.width, height: 60)
        }
        
        let buttonSet: [UIButton] = [hotButton, newButton, risingButton, controversialButton, topButton]
        buttonSet.forEach { (button) in
            if button.titleLabel?.text == sender.titleLabel?.text {
                self.select(button: button)
            } else {
                self.deselect(button: button)
            }
        }
    }
    
    @IBAction func didPressTimeFrameButton(_ sender: UIButton) {
        guard let selectedTimeFrame = CategoryTimeFrame.allValues.filter({ $0.titleValue == sender.titleLabel?.text }).first else { return }
        timeFrame = selectedTimeFrame
        
        let buttonSet: [UIButton] = [oneHour, twentyFourHours, week, month, year, allTime]
        buttonSet.forEach { (button) in
            if button.titleLabel?.text == sender.titleLabel?.text {
                self.select(button: button)
            } else {
                self.deselect(button: button)
            }
        }
    }
    
    func select(button: UIButton) {
        button.backgroundColor = themeManager.theme.selectionColor
        button.layer.cornerRadius = 4.0
        button.setTitleColor(themeManager.theme.subtitleTextColor, for: .normal)
    }
    
    func deselect(button: UIButton) {
        button.backgroundColor = UIColor.clear
        button.setTitleColor(themeManager.theme.titleTextColor, for: .normal)
    }
}
