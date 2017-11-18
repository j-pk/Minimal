//
//  CommentsViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/17/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import SDWebImage

class CommentsViewController: UIViewController {
    @IBOutlet weak var imageView: FLAnimatedImageView!
    
    var listing: Listing?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let listing = listing, let url = listing.url, let imageUrl = URL(string: url) else { return }
        imageView.sd_setImage(with: imageUrl)
    }
}
