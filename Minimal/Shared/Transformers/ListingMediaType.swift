//
//  ListingMediaType.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/26/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation

@objc
class MediaType: NSObject, NSCoding {
    
    struct Keys {
        static let listingMediaType = "listingMediaType"
    }
    
    var listingMediaType: ListingMediaType
    
    init(mediaType: ListingMediaType = .none) {
        listingMediaType = mediaType
        super.init()
    }
    
    convenience init(fromMapped listingData: ListingMediaType) {
        self.init(mediaType: listingData)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let typeRawValue = aDecoder.decodeObject(forKey: Keys.listingMediaType) as? String, let mediaType = ListingMediaType(rawValue: typeRawValue) else { return nil }
    
        self.init(mediaType: mediaType)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.listingMediaType.rawValue, forKey: Keys.listingMediaType)
    }
    
}
