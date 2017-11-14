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
    
    @IBAction func didPressCategoryButton(_ sender: UIButton) {
        self.preferredContentSize = CGSize(width: 160, height: 60)
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
