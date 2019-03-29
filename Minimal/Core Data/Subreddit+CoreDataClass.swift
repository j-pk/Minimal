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
    static func populateObject(fromDecodable json: Decodable, context: NSManagedObjectContext, completionHandler: @escaping OptionalErrorHandler) {
        guard let json = json as? SubredditObject else { fatalError("Failed to cast decodable as ListingObject.") }
        
        do {
            let subreddit: Subreddit = try Subreddit.fetchFirst(inContext: context, predicate: NSPredicate(format: "id == %@", json.id)) ?? Subreddit.insertObject(inContext: context)
            
            subreddit.id = json.id
            subreddit.allowImages = json.allowImages ?? true
            subreddit.allowVideoGifs = json.allowVideoGifs ?? true
            subreddit.displayName = json.displayName
            subreddit.displayNamePrefixed = json.displayNamePrefixed
            subreddit.iconImage = json.iconImage
            subreddit.isSubscribed = json.isSubscribed ?? false
            subreddit.over18 = json.over18
            subreddit.publicDescription = json.publicDescription
            subreddit.subscribers = Int64(json.subscribers)
            if let isSubscribed = json.isSubscribed, isSubscribed {
                subreddit.user = User.current(context: context)
            }
            
            completionHandler(nil)
            
        } catch let error {
            completionHandler(error)
        }
    }
    
    static func populateDefaultSubreddits(database: Database) {
        database.performBackgroundTask { (context) in
            do {
                try DefaultSubreddit.allCases.filter({ $0 != .random }).forEach({ (defaultSubreddit) in
                    let subreddit: Subreddit = try Subreddit.insertObject(inContext: context)
                    subreddit.id = "\(defaultSubreddit.rawValue)"
                    subreddit.isDefault = true
                    subreddit.displayName = defaultSubreddit.displayName
                    subreddit.displayNamePrefixed = defaultSubreddit.displayNamePrefixed
                    subreddit.allowImages = true
                    subreddit.allowVideoGifs = true
                    subreddit.over18 = defaultSubreddit != .all ? true : false
                    subreddit.publicDescription = defaultSubreddit.publicDescription
                    subreddit.iconImage = defaultSubreddit.iconImage
                })
                
                if context.hasChanges {
                    try context.save()
                }
                
            } catch let error {
                posLog(error: error)
            }
        }
    }
}

enum DefaultSubreddit: Int, CaseIterable {
    case home
    case popular
    case all
    case random
    
    var displayName: String {
        switch self {
        case .home: return "Home"
        case .popular: return "Popular"
        case .all: return "All"
        case .random: return "Random"
        }
    }
    
    var publicDescription: String {
        switch self {
        case .home: return "The front page of the internet"
        case .popular: return "Join the band wagon"
        case .all: return "Unfiltered"
        case .random: return "Mystery subreddit"
        }
    }
    
    var displayNamePrefixed: String {
        switch self {
        case .home: return ""
        case .popular: return "r/popular"
        case .all: return "r/all"
        case .random: return ""
        }
    }
    
    var iconImage: String {
        switch self {
        case .home: return "home"
        case .popular: return "popular"
        case .all: return "all"
        case .random: return "random"
        }
    }
}
