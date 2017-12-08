//
//  ListingManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 12/8/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation

struct ListingManager {
    init(request: Requestable, completionHandler: @escaping OptionalErrorHandler) {
        let _ = ListingModel(request: request) { (error, listingObjects) in
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

struct ListingModel: Modelable {
    var networkEngine: NetworkEngine = NetworkManager()
    
    init(request: Requestable, completionHandler: @escaping MappedCompletionHandler) {
        self.networkEngine.session(forRoute: request.router, withDecodable: ListingStore.self) { (error, decoded) in
            if let error = error {
                completionHandler(error, nil)
            } else {
                if let decoded = decoded {
                    let listings = decoded.listings.map({ listingData in ListingMapped(store: decoded, data: listingData) })
                    completionHandler(nil, listings)
                } else {
                    completionHandler(NetworkError.serverError(description: "No data for \(String(describing: request.router.urlRequest))"), nil)
                }
            }
        }
    }
}
