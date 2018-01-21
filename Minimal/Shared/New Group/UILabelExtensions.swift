//
//  UILabelExtensions.swift
//  Minimal
//
//  Created by Jameson Kirby on 1/6/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

class TitleLabel: UILabel {
    
}

class SubtitleLabel: UILabel {
    
}

extension UILabel {
    @objc dynamic var defaultFont: UIFont? {
        get { return self.font }
        set {
            self.font = UIFont(name: newValue?.fontName ?? FontType.helveticaNeue.regular, size: newValue?.pointSize ?? 14.0)
        }
    }
    
    func setFontSize(_ sizeFont: CGFloat) {
        self.font =  UIFont(name: self.font.fontName, size: sizeFont)!
        self.sizeToFit()
    }
    
    @objc dynamic var defaultFontBold: UIFont? {
        get { return self.font }
        set {
            self.font = UIFont(name: newValue?.fontName ?? FontType.helveticaNeue.bold, size: newValue?.pointSize ?? 14.0)
        }
    }
}
