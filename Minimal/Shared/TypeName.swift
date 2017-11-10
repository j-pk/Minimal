//
//  TypeName.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/9/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation

protocol TypeName: AnyObject {
    static var typeName: String { get }
}

// Swift Objects
extension TypeName {
    static var typeName: String {
        let type = String(describing: self)
        return type
    }
}

// Bridge to Obj-C
extension NSObject: TypeName {
    class var typeName: String {
        let type = String(describing: self)
        return type
    }
}
