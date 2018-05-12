//
//  MainModel.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 5/10/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

class MainModel {
    
    private var database: Database?
    
    init(database: Database) {
        self.database = database
    }
    
    func updateUserAndListings(forSubreddit subreddit: Subreddit? = nil, category: CategorySortType? = nil, timeFrame: CategoryTimeFrame? = nil, completionHandler: ((String, String) -> Void)? = nil) {
        guard let database = database, let user = User.current(context: database.viewContext) else { return }
        database.performForegroundTask { (context) in
            do {
                if let subreddit = subreddit {
                    subreddit.lastViewed = Date()
                    user.addToSubreddits(subreddit)
                }
                if let category = category {
                    user.categoryString = category.rawValue
                }
                if let timeFrame = timeFrame {
                    user.timeFrameString = timeFrame.rawValue
                } else {
                    user.timeFrameString = nil
                }
                try context.save()
            } catch let error {
                posLog(error: error)
            }
        }
        
        requestListings() { error in
            let subreddit = user.lastViewedSubreddit != "" ? user.lastViewedSubreddit : "Home"
            var category = user.category.rawValue.capitalized
            if let timeFrame = user.timeFrame?.rawValue.capitalized {
                category += " | " + timeFrame
            }
            completionHandler?(subreddit, category)
        }
    }
    
    func requestListings(completionHandler: OptionalErrorHandler? = nil) {
        guard let database = self.database, let user = User.current(context: database.viewContext) else { return }
        database.purgeRecords(entity: Listing.typeName, completionHandler: { (error) in
            if let error = error {
                posLog(error: error)
                completionHandler?(error)
            } else {
                let request = ListingRequest(requestType: .subreddit(prefix: user.lastViewedSubreddit, category: user.categoryString, timeFrame: user.timeFrameString))
                ListingManager(request: request, database: database, completionHandler: { (error) in
                    if let error = error {
                        posLog(error: error)
                        completionHandler?(error)
                    } else {
                        completionHandler?(nil)
                    }
                })
            }
        })
    }
}
