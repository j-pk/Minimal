//
//  ListingMediaTypeTransformer.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/26/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation

@objc(ListingMediaTypeTransformer)
class ListingMediaTypeTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return MediaType.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? MediaType else { return nil }
        return NSKeyedArchiver.archivedData(withRootObject: data)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data  else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(with: data)
    }
    
}

extension NSValueTransformerName {
    static let listingMediaTypeName = NSValueTransformerName(rawValue: "ListingMediaTypeTransformer")    
}
