//
//  GifuExtensions.swift
//  Minimal
//
//  Created by Jameson Kirby on 5/20/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Nuke
import Gifu

extension Gifu.GIFImageView {
    public override func display(image: Image?) {
        prepareForReuse()
        if let data = image?.animatedImageData {
            animate(withGIFData: data)
        } else {
            self.image = image
        }
    }
}
