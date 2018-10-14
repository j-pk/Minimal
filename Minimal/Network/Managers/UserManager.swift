//
//  UserManager.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 10/13/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation
import CoreData

struct UserManager {
    var networkEngine = NetworkManager()
    
    func vote(request: Requestable, direction: UserVoteDirection, database: Database, listingManagedObjectId: NSManagedObjectID, completionHandler: @escaping OptionalErrorHandler) {
        networkEngine.requestResponse(forRoute: request.router) { (results) in
            switch results {
            case .failure(let error):
                completionHandler(error)
            case .success:
                database.performBackgroundTask { (moc) in
                    if let listing = moc.object(with: listingManagedObjectId) as? Listing {
                        listing.voted = Int16(direction.rawValue)
                        do {
                            if moc.hasChanges {
                                try moc.save()
                            }
                            completionHandler(nil)
                        } catch {
                            completionHandler(CoreDataError.failedToInsertObject(listing.description))
                        }
                    } else {
                        completionHandler(CoreDataError.failedToFetchObject("Listing with ID \(listingManagedObjectId)"))
                    }
                }
            }
        }
    }
}
