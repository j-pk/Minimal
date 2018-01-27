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
    var category: ListingCategoryType {
        get {
            return ListingCategoryType(rawValue: self.categoryString)!
        }
    }
    
    var timeframe: CategoryTimeFrame? {
        get {
            if let timeframe = timeframeString {
                return CategoryTimeFrame(rawValue: timeframe)!
            }
            return nil
        }
    }
}

extension User: Manageable {
    static func populateObject(fromJSON json: Decodable, save: Bool, context: NSManagedObjectContext, completionHandler: @escaping OptionalErrorHandler) { }
    
    static func create(context: NSManagedObjectContext, completionHandler: OptionalErrorHandler) {
        do {
            let user = try User.insertObject(inContext: context)
            
            user.labelNsfw = true
            user.lastAuthenticated = nil
            user.lastViewedSubreddit = ""
            user.categoryString = ListingCategoryType.hot.rawValue
            user.timeframeString = nil
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
    
    static func current(context: NSManagedObjectContext? = nil) -> User? {
        if let user = try? User.fetchFirst(inContext: context ?? CoreDataManager.default.viewContext) {
            return user
        } else {
            return nil
        }
    }
}
