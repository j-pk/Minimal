//
//  StringExtensions.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 3/29/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}
