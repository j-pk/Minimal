//
//  CategoryPopoverViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/13/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

class CategoryPopoverViewController: UIViewController {
    
    @IBOutlet weak var categoryStackView: UIStackView!
    @IBOutlet weak var hotButton: UIButton!
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var risingButton: UIButton!
    @IBOutlet weak var controversialButton: UIButton!
    @IBOutlet weak var topButton: UIButton!

    @IBOutlet weak var timeFrameStackView: UIStackView!
    @IBOutlet weak var oneHour: UIButton!
    @IBOutlet weak var twentyFourHours: UIButton!
    @IBOutlet weak var week: UIButton!
    @IBOutlet weak var month: UIButton!
    @IBOutlet weak var year: UIButton!
    @IBOutlet weak var allTime: UIButton!
    
    var categoryButtonSet: [UIButton] = []
    var timeFrameButtonSet: [UIButton] = []
    var category: CategorySortType = .hot
    var timeFrame: CategoryTimeFrame?
    var themeManager = ThemeManager()
    
    override func viewDidLoad() {
        categoryButtonSet = [hotButton, newButton, risingButton, controversialButton, topButton]
        timeFrameButtonSet = [oneHour, twentyFourHours, week, month, year, allTime]
        
        (categoryButtonSet + timeFrameButtonSet).forEach { (button) in
            button.contentEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        }
    
        guard let selectedCategoryButton = categoryButtonSet.filter({ $0.titleLabel?.text == category.rawValue }).first else { return }
        select(button: selectedCategoryButton)
        
        if let timeFrame = timeFrame?.titleValue {
            guard let selectedTimeframeButton = timeFrameButtonSet.filter({ $0.titleLabel?.text == timeFrame }).first else { return }
            select(button: selectedTimeframeButton)
        }
        
        self.timeFrameStackView.isHidden = !category.isSetByTimeframe
    }

    @IBAction func didPressCategoryButton(_ sender: UIButton) {
        guard let selectedCategory = CategorySortType.allValues.filter({ $0.rawValue == sender.titleLabel?.text }).first else { return }
        category = selectedCategory

        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.2, options: [.curveEaseOut], animations: {
            // BUG: http://www.openradar.me/22819594
            // This is a workaround, do not set setHidden:true if it is already hidden
            if self.timeFrameStackView.isHidden == false && selectedCategory.isSetByTimeframe == false {
                self.timeFrameStackView.isHidden = true
            } else if self.timeFrameStackView.isHidden == true && selectedCategory.isSetByTimeframe == true {
                self.timeFrameStackView.isHidden = false
            } else if self.timeFrameStackView.isHidden == true && selectedCategory.isSetByTimeframe == false {
                // Don't do anything
            }
        }, completion: nil)
        
        if !selectedCategory.isSetByTimeframe {
            timeFrame = nil
        }
        
        categoryButtonSet.forEach { (button) in
            if button.titleLabel?.text == sender.titleLabel?.text {
                select(button: button)
            } else {
                deselect(button: button)
            }
        }
    }
    
    @IBAction func didPressTimeFrameButton(_ sender: UIButton) {
        guard let selectedTimeframe = CategoryTimeFrame.allValues.filter({ $0.titleValue == sender.titleLabel?.text }).first else { return }
        timeFrame = selectedTimeframe
        
        timeFrameButtonSet.forEach { (button) in
            if button.titleLabel?.text == sender.titleLabel?.text {
                select(button: button)
            } else {
                deselect(button: button)
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
