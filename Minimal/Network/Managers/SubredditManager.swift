//
//  SubredditManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 8/13/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

class SubredditManager {
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
                            completionHandler(error)
                        }
                        completionHandler(nil)
                    })
                } catch let error {
                    completionHandler(error)
                }
            }
        }
    }
}
