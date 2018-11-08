//
//  HeaderCell.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/18/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit

class HeaderCell: UITableViewCell {
    @IBOutlet weak var annotationView: AnnotationView!
    @IBOutlet weak var presentationView: PresentationView!
    
    var url: URL?
    var themeManager = ThemeManager()
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(forListing listing: Listing) {
        contentView.backgroundColor = themeManager.theme.primaryColor
        annotationView.setAnnotations(forListing: listing)
        presentationView.setView(forListing: listing)
        layoutIfNeeded()
    }
}
