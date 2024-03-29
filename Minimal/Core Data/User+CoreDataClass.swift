//
//  User+CoreDataClass.swift
//  Minimal
//
//  Created by Jameson Kirby on 12/5/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//
//

import Foundation
import CoreData

public class User: NSManagedObject {
    var category: CategorySortType {
        get {
            return CategorySortType(rawValue: self.categoryString)!
        }
    }
    
    var timeFrame: CategoryTimeFrame? {
        get {
            if let timeFrame = timeFrameString {
                return CategoryTimeFrame(rawValue: timeFrame)!
            }
            return nil
        }
    }
    
    var lastViewedSubreddit: String {
        let subreddit = self.subreddits?.compactMap({ $0 }).sorted(by: { $0.lastViewed > $1.lastViewed }).first
        return subreddit?.displayNamePrefixed ?? ""
    }
}

extension User: Manageable {
    static func populateObject(fromDecodable json: Decodable, context: NSManagedObjectContext, completionHandler: @escaping OptionalErrorHandler) { }
    
    static func create(context: NSManagedObjectContext, completionHandler: OptionalErrorHandler) {
        do {
            let user = try User.insertObject(inContext: context)
            
            user.labelNsfw = true
            user.categoryString = CategorySortType.hot.rawValue
            user.over18 = false
            user.searchIncludeOver18 = false
            
            if context.hasChanges {
                try context.save()
            }
            
            completionHandler(nil)
            
        } catch let error {
            completionHandler(CoreDataError.failedToInsertObject(error.localizedDescription))
        }
    }
    
    static func current(context: NSManagedObjectContext) -> User? {
        if let user = try? User.fetchFirst(inContext: context) {
            return user
        } else {
            return nil
        }
    }
}
