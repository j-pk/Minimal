//
//  Subreddit+CoreDataProperties.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 2/4/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//
//

import Foundation
import CoreData


extension Subreddit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subreddit> {
        return NSFetchRequest<Subreddit>(entityName: "Subreddit")
    }

    @NSManaged public var allowImages: Bool
    @NSManaged public var allowVideoGifs: Bool
    @NSManaged public var displayName: String?
    @NSManaged public var displayNamePrefixed: String?
    @NSManaged public var iconImage: String?
    @NSManaged public var id: String
    @NSManaged public var isSubscribed: Bool
    @NSManaged public var lastViewed: Date
    @NSManaged public var over18: Bool
    @NSManaged public var publicDescription: String?
    @NSManaged public var subscribers: Int64
    @NSManaged public var user: User?

}
