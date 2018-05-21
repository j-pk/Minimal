//
//  ImageProcessor.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 4/12/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit
import Nuke

struct RoundedCorners: ImageProcessing {

    private let radius: CGFloat
    
    /// Initializes the receiver with a corner radius.
    init(radius: CGFloat = 4) {
        self.radius = radius
    }
    
    /// Clip image corners.
    func process(image: Image, context: ImageProcessingContext) -> Image? {
        return image.rounderCorners(radius: radius)
    }
    
    /// Compares two filters based on their radius.
    static func ==(lhs: RoundedCorners, rhs: RoundedCorners) -> Bool {
        return lhs.radius == rhs.radius
    }
}

struct Pixelate: ImageProcessing {
    
    private let scale: Int
    
    init(scale: Int = 8) {
        self.scale = scale
    }
    
    func process(image: Image, context: ImageProcessingContext) -> Image? {
        return image.pixelate(scale: scale)
    }
    
    static func ==(lhs: Pixelate, rhs: Pixelate) -> Bool {
        return lhs.scale == rhs.scale
    }
}

extension UIImage {
    public func rounderCorners(radius: CGFloat) -> UIImage? {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        UIBezierPath(roundedRect: rect, cornerRadius: 4).addClip()
        draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func pixelate(scale: Int = 8) -> UIImage? {
        guard let ciImage = UIKit.CIImage(image: self), let filter = CIFilter(name: "CIPixellate") else { return nil }
        filter.setValue(ciImage, forKey: "inputImage")
        filter.setValue(scale, forKey: "inputScale")
        guard let output = filter.outputImage else { return nil }
        return UIImage(ciImage: output)
    }
}
