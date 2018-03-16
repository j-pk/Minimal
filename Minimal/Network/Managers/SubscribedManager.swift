//
//  SubscribedManager.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 3/13/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//


//https://www.reddit.com/dev/api#GET_subreddits_mine_{where}
//GET /subreddits/mine/where
//subscriber - subreddits the user is subscribed to
//
//https://www.reddit.com/dev/api#POST_api_subscribe
//POST /api/subscribe
//Subscribe to or unsubscribe from a subreddit.

import Foundation

class SubscribedManager {
    private let listingNetwork: ListingNetwork
    @discardableResult init(request: Requestable, database: Database, completionHandler: @escaping OptionalErrorHandler) {
        listingNetwork = ListingNetwork(request: request) { (error, listingObjects) in
            if let error = error {
                completionHandler(error)
            }
            if let objects = listingObjects {
                posLog(values: objects)
//                do {
//                    try Listing.populateObjects(fromJSON: objects, database: database, completionHandler: { (error) in
//                        if error != nil {
//                            completionHandler(error)
//                        } else {
//                            completionHandler(nil)
//                        }
//                    })
//                } catch let error {
//                    completionHandler(error)
//                }
            } else {
                completionHandler(error)
            }
        }
    }}

