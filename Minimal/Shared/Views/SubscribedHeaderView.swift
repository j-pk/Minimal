//
//  SubscribedHeaderCell.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 3/26/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

class SubscribedHeaderView: XibView {
    @IBOutlet weak var headerLabel: HeaderLabel!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}

