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
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = url else {
            dismiss(animated: true, completion: nil)
            return
        }
        view.backgroundColor = ThemeManager.default.primaryTheme
        imageView.backgroundColor = ThemeManager.default.primaryTheme
        Manager.shared.loadImage(with: url, into: imageView)
    }
    
}

extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
