//
//  SyncManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/24/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation

class SyncManager {
    
    static let `default` = SyncManager()
    private var isSyncing = false
    
    func syncListings(prefix: String, category: String?, timeframe: String?, completionHandler: @escaping ((Error?)->())) {
        APIManager.default.requestListings(prefix: prefix, category: category, timeframe: timeframe) { (error, listingObjects) in
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
    
    func syncListingsPage(prefix: String, category: String?, timeframe: String?, limit: Int? = 25, after: String, completionHandler: @escaping ((Error?)->())) {
        APIManager.default.requestListingsPage(prefix: prefix, category: category, timeframe: timeframe, limit: (limit ?? 25), after: after) { (error, listingObjects) in
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
