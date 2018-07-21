//
//  ImageViewController.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/30/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import UIKit
import Nuke

class ImageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var request: ImageRequest?
    var themeManager = ThemeManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let request = request, let image = ImageCache.shared[request] else {
            dismiss(animated: true, completion: nil)
            return
        }
        view.backgroundColor = themeManager.theme.primaryColor
        imageView.backgroundColor = themeManager.theme.primaryColor
        imageView.image = image
    }
}

extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
