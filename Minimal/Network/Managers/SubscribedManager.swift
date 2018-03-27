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
    private let network: SubredditNetwork
    @discardableResult init(request: Requestable, database: Database, completionHandler: @escaping OptionalErrorHandler) {
        network = SubredditNetwork(request: request) { (result) in
            switch result {
            case .failure(let error):
                completionHandler(error)
            case .success(let object):
                    do {
                        try Subreddit.populateObjects(fromJSON: object.subreddits, database: database, completionHandler: { (error) in
                            if let error = error {
                                posLog(error: error)
                            }
                        })
                    } catch let error {
                        posLog(error: error)
                }
            }
        }
    }
}

