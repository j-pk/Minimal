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

}

extension User: Manageable {
    static func populateObject<T>(fromJSON json: T, save: Bool, context: NSManagedObjectContext, completionHandler: @escaping OptionalErrorHandler) where T : Decodable {
    }
    
    static func create(context: NSManagedObjectContext, completionHandler: OptionalErrorHandler) {
        do {
            let user = try User.insertObject(inContext: context)
            
            user.labelNsfw = true
            user.lastAuthenticated = nil
            user.lastViewedSubreddit = ""
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
}
