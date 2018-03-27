//
//  ListingManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 12/8/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation

struct ListingManager {
    private let listingNetwork: ListingNetwork
    @discardableResult init(request: Requestable, database: Database, completionHandler: @escaping OptionalErrorHandler) {
        listingNetwork = ListingNetwork(request: request) { (result) in
            switch result {
            case .failure(let error):
                completionHandler(error)
            case .success(let listingObjects):
                do {
                    try Listing.populateObjects(fromJSON: listingObjects, database: database, completionHandler: { (error) in
                        if error != nil {
                            completionHandler(error)
                        } else {
                            completionHandler(nil)
                        }
                    })
                } catch let error {
                    completionHandler(error)
                }
            }
        }
    }
}

struct ListingNetwork: Networkable {
    var networkEngine: NetworkEngine = NetworkManager()
    
    init(request: Requestable, completionHandler: @escaping ResultCompletionHandler<[Decodable]>) {
        networkEngine.session(forRoute: request.router, withDecodable: ListingStore.self) { (result) in
            switch result {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(let decoded):
                var objects = decoded.listings
                objects.indices.forEach({ objects[$0].after = decoded.after })
                completionHandler(.success(objects))
            }
        }
    }
}
