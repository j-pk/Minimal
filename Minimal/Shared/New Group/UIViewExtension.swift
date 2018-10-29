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
        contentView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        
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
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 2
    }
    
    func attachActivityIndicator(message: String, blurEffect: UIBlurEffect.Style, indicatorStyle: UIActivityIndicatorView.Style) {
        let themeManager = ThemeManager()
        let overlayView = UIView()
        overlayView.backgroundColor = .black
        overlayView.alpha = 0.7
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.tag = 1
        self.addSubview(overlayView)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[overlayView]-0-|",
                                                           options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                           metrics: nil,
                                                           views: ["overlayView":overlayView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[overlayView]-0-|",
                                                           options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                           metrics: nil,
                                                           views: ["overlayView":overlayView]))
        
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: blurEffect))
        effectView.layer.cornerRadius = 6
        effectView.layer.masksToBounds = true
        effectView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(effectView)
        
        let activityIndicator = UIActivityIndicatorView(style: indicatorStyle)
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        effectView.contentView.addSubview(activityIndicator)
        
        let titleLabel = UILabel()
        titleLabel.text = message
        titleLabel.font = themeManager.font(fontStyle: .primary)
        titleLabel.textColor = themeManager.theme.titleTextColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        effectView.contentView.addSubview(titleLabel)
        
        effectView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[activityIndicator]-|",
                                                                 options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                                 metrics: nil,
                                                                 views: ["activityIndicator":activityIndicator]))
        effectView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-|",
                                                                 options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                                 metrics: nil,
                                                                 views: ["titleLabel":titleLabel]))
        effectView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[activityIndicator]-[titleLabel]-|",
                                                                 options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                                 metrics: nil,
                                                                 views: ["activityIndicator":activityIndicator, "titleLabel":titleLabel]))
        
        
        overlayView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[overlayView]-(<=1)-[effectView]",
                                                                  options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                                  metrics: nil,
                                                                  views: ["overlayView":overlayView, "effectView":effectView]))
        overlayView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[overlayView]-(<=1)-[effectView]",
                                                                  options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                                  metrics: nil,
                                                                  views: ["overlayView":overlayView, "effectView":effectView]))
    }
    
    func removeAttachedView() {
        for view in self.subviews {
            if view.tag == 1 {
                view.removeFromSuperview()
            }
        }
    }
    
    func attachPlayIndicator(image: UIImage? = UIImage(imageLiteralResourceName: "playIcon")) {
        let containerView = UIView()
        containerView.layer.masksToBounds = true
        containerView.layer.opacity = 0.9
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.tag = 1
        addSubview(containerView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[containerView]-0-|",
                                                           options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                           metrics: nil,
                                                           views: ["containerView": containerView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[containerView]-0-|",
                                                           options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                           metrics: nil,
                                                           views: ["containerView": containerView]))
        
        let imageView = UIImageView()
        imageView.image = image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = ThemeManager().theme.tintColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[imageView(30)]-|",
                                                                  options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                                  metrics: nil,
                                                                  views: ["containerView": containerView, "imageView": imageView]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView(30)]",
                                                                  options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                                  metrics: nil,
                                                                  views: ["containerView": containerView, "imageView": imageView]))
    }
    
    func attachNSFWLabel() {
        let containerView = UIView()
        containerView.layer.masksToBounds = true
        containerView.layer.opacity = 0.9
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.tag = 1
        addSubview(containerView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[containerView]-0-|",
                                                      options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                      metrics: nil,
                                                      views: ["containerView": containerView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[containerView]-0-|",
                                                      options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                      metrics: nil,
                                                      views: ["containerView": containerView]))
        let labelContainerView = UIView()
        labelContainerView.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        labelContainerView.translatesAutoresizingMaskIntoConstraints = false
        labelContainerView.layer.masksToBounds = true
        labelContainerView.layer.cornerRadius = 4.0
        containerView.addSubview(labelContainerView)
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[labelContainerView(35)]-|",
                                                                    options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                                    metrics: nil,
                                                                    views: ["containerView": containerView, "labelContainerView": labelContainerView]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[labelContainerView]",
                                                                    options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                                    metrics: nil,
                                                                    views: ["containerView": containerView, "labelContainerView": labelContainerView]))

        let nsfwLabel = WarningLabel()
        nsfwLabel.text = "NSFW"
        nsfwLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        nsfwLabel.backgroundColor = .clear
        nsfwLabel.translatesAutoresizingMaskIntoConstraints = false
        labelContainerView.addSubview(nsfwLabel)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[nsfwLabel]-8-|",
                                                      options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                      metrics: nil,
                                                      views: ["nsfwLabel": nsfwLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[nsfwLabel]-8-|",
                                                      options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                      metrics: nil,
                                                      views: ["nsfwLabel": nsfwLabel]))
    }
    
    func attachNoImageFound(message: String? = nil) {
        let themeManager = ThemeManager()
        let containerView = UIView()
        containerView.layer.masksToBounds = true
        containerView.layer.opacity = 0.9
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.tag = 1
        insertSubview(containerView, at: 0)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[containerView]-0-|",
                                                      options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                      metrics: nil,
                                                      views: ["containerView": containerView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[containerView]-0-|",
                                                      options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                      metrics: nil,
                                                      views: ["containerView": containerView]))
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "placeholder")
        imageView.tintColor = themeManager.theme.tintColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        
        let label = UILabel()
        label.text = message
        label.textColor = themeManager.theme.tintColor
        label.font = themeManager.font(fontStyle: .primaryBold)
        label.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(label)
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[containerView]-(<=1)-[imageView(40)]",
                                                                    options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                                    metrics: nil,
                                                                    views: ["containerView": containerView, "imageView": imageView]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[containerView]-(<=1)-[imageView(40)]",
                                                                    options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                                    metrics: nil,
                                                                    views: ["containerView": containerView, "imageView": imageView]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[imageView(40)]-[label]",
                                                                    options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                                    metrics: nil,
                                                                    views: ["imageView": imageView, "label": label]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[label]",
                                                                    options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                                    metrics: nil,
                                                                    views: ["label": label]))
    }
    
    func attachDividerLine(forDepth depth: Int) {
        var modifiedDepthPosition = depth

        func addDividerLineBasedOnDepth() {
            let themeManager = ThemeManager()
            let line = UIView()
            line.tag = 1
            line.backgroundColor = themeManager.theme.secondaryColor.withAlphaComponent(CGFloat(modifiedDepthPosition) * 0.2)
            line.translatesAutoresizingMaskIntoConstraints = false
            addSubview(line)
            let leftInset = CGFloat(modifiedDepthPosition) * 12
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[line]-0-|",
                                                          options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                          metrics: nil,
                                                          views: ["line": line]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(leftInset))-[line(1)]",
                options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                metrics: nil,
                views: ["line": line]))
        }
        
        for _ in 1...modifiedDepthPosition {
            addDividerLineBasedOnDepth()
            modifiedDepthPosition -= 1
        }
    }
}
