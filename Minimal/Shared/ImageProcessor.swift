//
//  ImageProcessor.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 4/12/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit
import Nuke

struct RoundedCorners: Processing {
    private let radius: CGFloat
    
    /// Initializes the receiver with a corner radius.
    init(radius: CGFloat = 4) {
        self.radius = radius
    }
    
    /// Clip image corners.
    func process(_ image: UIImage) -> UIImage? {
        return image.rounderCorners(radius: radius)
    }
    
    /// Compares two filters based on their radius.
    static func ==(lhs: RoundedCorners, rhs: RoundedCorners) -> Bool {
        return lhs.radius == rhs.radius
    }
}

extension UIImage {
    public func rounderCorners(radius: CGFloat) -> UIImage? {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        UIBezierPath(roundedRect: rect, cornerRadius: 4).addClip()
//        UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: radius)).addClip()
        draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
