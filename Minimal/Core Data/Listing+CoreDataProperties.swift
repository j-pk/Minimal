//
//  Listing+CoreDataProperties.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/24/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//
//

import Foundation
import CoreData


extension Listing {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Listing> {
        return NSFetchRequest<Listing>(entityName: "Listing")
    }

    @NSManaged public var id: String?
    @NSManaged public var subredditId: String?
    @NSManaged public var name: String?
    @NSManaged public var title: String?
    @NSManaged public var saved: Bool
    @NSManaged public var score: Int32
    @NSManaged public var downs: Int32
    @NSManaged public var over18: Bool
    @NSManaged public var hidden: Bool
    @NSManaged public var created: Date?
    @NSManaged public var populatedDate: Date
    @NSManaged public var urlString: String
    @NSManaged public var thumbnailUrlString: String?
    @NSManaged public var width: NSNumber?
    @NSManaged public var height: NSNumber?
    @NSManaged public var author: String?
    @NSManaged public var subredditNamePrefixed: String?
    @NSManaged public var numberOfComments: Int32
    @NSManaged public var postHint: String?
    @NSManaged public var permalink: String?
    @NSManaged public var before: String?
    @NSManaged public var after: String?
    @NSManaged public var domain: String?
    @NSManaged public var mediaType: String
    @NSManaged public var voted: Int16
    @NSManaged public var subreddit: Subreddit?
    @NSManaged public var comments: Set<Comment>?
    
}
