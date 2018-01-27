//
//  Subreddit+CoreDataClass.swift
//  Minimal
//
//  Created by Jameson Kirby on 1/23/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//
//

import Foundation
import CoreData

public class Subreddit: NSManagedObject {

}

extension Subreddit: Manageable {
    static func populateObject(fromJSON json: Decodable, save: Bool, context: NSManagedObjectContext, completionHandler: @escaping OptionalErrorHandler) {
        guard let json = json as? SubredditObject else { fatalError("Failed to cast decodable as ListingObject.") }
        
        do {
            let subreddit: Subreddit = try Subreddit.fetchFirst(inContext: context, predicate: NSPredicate(format: "id == %@", json.id)) ?? Subreddit.insertObject(inContext: context)
            
            subreddit.id = json.id
            subreddit.allowImages = json.allowImages
            subreddit.allowVideoGifs = json.allowVideoGifs
            subreddit.displayName = json.displayName
            subreddit.displayNamePrefixed = json.displayNamePrefixed
            subreddit.iconImage = json.iconImage
            subreddit.isSubscribed = json.isSubscribed ?? false
            subreddit.over18 = json.over18
            subreddit.publicDescription = json.publicDescription
            subreddit.subscribers = Int64(json.subscribers)
            
            if save {
                try context.save()
            }
            
            completionHandler(nil)
            
        } catch let error {
            completionHandler(error)
        }
    }
}
