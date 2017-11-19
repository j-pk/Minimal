//
//  TitleAndDetailsView.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/18/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

@IBDesignable
class TitleAndDetailsView: UIView {
    
    var contentView : UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var title: String?
    var domain: String?
    var author: String?
    var subredditNamePrefixed: String?
    var score: Int32 = 0
    var dateCreated: Date?
    
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
    
    func configureView() {
        let mutableAttributedString = NSMutableAttributedString()
        
        if let title = title {
            let boldAttribute = [
                NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12),
                NSAttributedStringKey.foregroundColor: UIColor.black
            ]
            let boldAttributedString = NSAttributedString(string: title, attributes: boldAttribute)
            
            mutableAttributedString.append(boldAttributedString)
        }
        if let domain = domain {
            let regularAttribute = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 8),
                NSAttributedStringKey.foregroundColor: UIColor.gray
            ]
            let regularAttributedString = NSAttributedString(string: " (\(domain))", attributes: regularAttribute)
            mutableAttributedString.append(regularAttributedString)
        }
        
        titleLabel.attributedText = mutableAttributedString
        detailLabel.text = subredditNamePrefixed
        
        var descriptionString = "\(score) upvotes"
        if let author = author {
            descriptionString += " submitted by \(author)"
        }
        if let dateCreated = dateCreated {
            descriptionString += " \(dateCreated.timeAgoSinceNow())"
        }
        descriptionLabel.text = descriptionString
    }
    
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
}
