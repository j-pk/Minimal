//
//  UIViewExtension.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/19/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

@IBDesignable
class XibView: UIView {
    var contentView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        contentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        contentView.frame = bounds
        
        // Make the view stretch with containing view
        contentView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView)
    }
    
    
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
}

protocol UIViewTappableDelegate: class {
    func didTapView(sender: UITapGestureRecognizer, data: [String:Any?])
}

@objc protocol Tappable: class {
    @objc func didTapView(_ sender: UITapGestureRecognizer)
}
protocol Recognizer: Tappable {
    var tapGestureRecognizer: UITapGestureRecognizer { get }
}
extension Recognizer where Self: UIView {
     var tapGestureRecognizer: UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        return tap
    }
}

extension UIView {
    func attachActivityIndicator(title: String, blurEffect: UIBlurEffectStyle, indicatorStyle: UIActivityIndicatorViewStyle) {
        let overlayView = UIView()
        overlayView.backgroundColor = .black
        overlayView.alpha = 0.7
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.tag = 1
        self.addSubview(overlayView)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[overlayView]-0-|",
                                                           options: NSLayoutFormatOptions.alignAllCenterX,
                                                           metrics: nil,
                                                           views: ["overlayView":overlayView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[overlayView]-0-|",
                                                           options: NSLayoutFormatOptions.alignAllCenterY,
                                                           metrics: nil,
                                                           views: ["overlayView":overlayView]))
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: blurEffect))
        effectView.layer.cornerRadius = 6
        effectView.layer.masksToBounds = true
        effectView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(effectView)
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: indicatorStyle)
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        effectView.contentView.addSubview(activityIndicator)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = ThemeManager.font(fontType: .primary)
        titleLabel.textColor = ThemeManager.default.primaryTextColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        effectView.contentView.addSubview(titleLabel)
        
        effectView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[activityIndicator]-|",
                                                                 options: NSLayoutFormatOptions.alignAllCenterX,
                                                                 metrics: nil,
                                                                 views: ["activityIndicator":activityIndicator]))
        effectView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-|",
                                                                 options: NSLayoutFormatOptions.alignAllCenterX,
                                                                 metrics: nil,
                                                                 views: ["titleLabel":titleLabel]))
        effectView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[activityIndicator]-[titleLabel]-|",
                                                                 options: NSLayoutFormatOptions.alignAllCenterY,
                                                                 metrics: nil,
                                                                 views: ["activityIndicator":activityIndicator, "titleLabel":titleLabel]))
        
        
        overlayView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[overlayView]-(<=1)-[effectView]",
                                                                  options: NSLayoutFormatOptions.alignAllCenterX,
                                                                  metrics: nil,
                                                                  views: ["overlayView":overlayView, "effectView":effectView]))
        overlayView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[overlayView]-(<=1)-[effectView]",
                                                                  options: NSLayoutFormatOptions.alignAllCenterY,
                                                                  metrics: nil,
                                                                  views: ["overlayView":overlayView, "effectView":effectView]))
    }
    
    func removeActivityIndicatorView() {
        for view in self.subviews {
            if view.tag == 1 {
                view.removeFromSuperview()
            }
        }
    }
    
    func attachPlayIndicator(image: UIImage? = UIImage(imageLiteralResourceName: "playIcon"), blurEffect: UIBlurEffectStyle) {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: blurEffect))
        effectView.layer.masksToBounds = true
        effectView.layer.opacity = 0.6
        effectView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(effectView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[effectView]-0-|",
                                                           options: NSLayoutFormatOptions.alignAllCenterX,
                                                           metrics: nil,
                                                           views: ["effectView":effectView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[effectView]-0-|",
                                                           options: NSLayoutFormatOptions.alignAllCenterY,
                                                           metrics: nil,
                                                           views: ["effectView":effectView]))
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        effectView.contentView.addSubview(imageView)
        
        effectView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[effectView]-(<=1)-[imageView(45)]",
                                                                  options: NSLayoutFormatOptions.alignAllCenterX,
                                                                  metrics: nil,
                                                                  views: ["effectView":effectView, "imageView":imageView]))
        effectView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[effectView]-(<=1)-[imageView(45)]",
                                                                  options: NSLayoutFormatOptions.alignAllCenterY,
                                                                  metrics: nil,
                                                                  views: ["effectView":effectView, "imageView":imageView]))
    }
}
