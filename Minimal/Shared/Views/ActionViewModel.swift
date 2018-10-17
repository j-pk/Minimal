//
//  ActionViewModel.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/16/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

class ActionViewModel {
    let database: Database
    let listing: Listing
    
    init(database: Database, listing: Listing) {
        self.database = database
        self.listing = listing
    }
    
    func vote(listing: Listing, dir: UserVoteDirection, completionHandler: @escaping OptionalErrorHandler) {
        guard let id = listing.id else { return }
        let request = UserRequest(requestType: .vote(id: id, direction: dir))
        UserManager().vote(request: request, direction: dir, database: database, listingManagedObjectId: listing.objectID, completionHandler: completionHandler)
    }
    
    func attemptVote(dir: UserVoteDirection, completionHandler: @escaping ((Bool)->())) {
        vote(listing: listing, dir: dir, completionHandler: { (error) in
            if let error = error as? NetworkError {
                if error.errorCode == 401 {
                    NotificationBanner(state: .error("Login to vote"))
                } else {
                    NotificationBanner(state: .error("Meh, something went wrong"))
                }
                posLog(error: error)
                completionHandler(false)
            } else {
                completionHandler(true)
            }
        })
    }

}
