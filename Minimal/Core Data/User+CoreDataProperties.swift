//
//  User+CoreDataProperties.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 2/4/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var categoryString: String
    @NSManaged public var labelNsfw: Bool
    @NSManaged public var lastAuthenticated: Date?
    @NSManaged public var over18: Bool
    @NSManaged public var searchIncludeOver18: Bool
    @NSManaged public var timeFrameString: String?
    @NSManaged public var subreddits: Set<Subreddit>?

}

// MARK: Generated accessors for subreddits
extension User {

    @objc(addSubredditsObject:)
    @NSManaged public func addToSubreddits(_ value: Subreddit)

    @objc(removeSubredditsObject:)
    @NSManaged public func removeFromSubreddits(_ value: Subreddit)

    @objc(addSubreddits:)
    @NSManaged public func addToSubreddits(_ values: Set<Subreddit>)

    @objc(removeSubreddits:)
    @NSManaged public func removeFromSubreddits(_ values: Set<Subreddit>)

}
