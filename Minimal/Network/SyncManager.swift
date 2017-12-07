//
//  SyncManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/24/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation

class SyncManager {
    typealias OptionalErrorHandler = (Error?) -> Void
    
    static let `default` = SyncManager()
    private var isSyncing = false
    
    func syncListings(withRequest request: Requestable, completionHandler: @escaping OptionalErrorHandler) {
        APIManager.default.requestMappedListings(forRequest: request) { (error, listingObjects) in
            if let error = error {
                completionHandler(error)
            }
            if let objects = listingObjects {
                do {
                    try Listing.populateObjects(fromJSON: objects, completionHandler: { (error) in
                        if error != nil {
                            completionHandler(error)
                        } else {
                            completionHandler(nil)
                        }
                    })
                } catch let error {
                    completionHandler(error)
                }
            } else {
                completionHandler(error)
            }
        }
    }
}
