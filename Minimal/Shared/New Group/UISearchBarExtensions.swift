//
//  UISearchBarExtensions.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 1/21/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

extension UISearchBar {
    
    private func viewWithType<T>(type: T.Type) -> T? {
        let suvbiews = subviews.flatMap({ $0.subviews })
        guard let element = (suvbiews.filter{ $0 is T }).first as? T else { return nil }
        return element
    }

    func setTextColor(color: UIColor) {
        if let textField = viewWithType(type: UITextField.self) {
            textField.textColor = color
        }
    }
    
    func setTextFieldColor(color: UIColor) {
        if let textField = viewWithType(type: UITextField.self) {
            switch searchBarStyle {
            case .minimal:
                textField.layer.backgroundColor = color.cgColor
                textField.layer.cornerRadius = 6
                
            case .prominent, .default:
                textField.backgroundColor = color
            default:
                break
            }
        }
    }
    
    func setPlaceholderTextColor(color: UIColor) {
        if let textField = viewWithType(type: UITextField.self) {
            textField.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSAttributedString.Key.foregroundColor: color])
        }
    }
    
    func setTextFieldClearButtonColor(color: UIColor) {
        if let textField = viewWithType(type: UITextField.self) {
            if let clearButton = textField.value(forKey: "clearButton") as? UIButton {
                clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
                clearButton.tintColor = color
            }
        }
    }
    
    func setSearchImageColor(color: UIColor) {
        if let imageView = viewWithType(type: UITextField.self)?.leftView as? UIImageView {
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = color
        }
    }
}
