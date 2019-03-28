//
//  Extensions.swift
//  Minimal
//
//  Created by Jameson Kirby on 3/27/19.
//  Copyright © 2019 Parker Kirby. All rights reserved.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
