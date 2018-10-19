//
//  Comment+CoreDataProperties.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/16/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//
//

import Foundation
import CoreData


extension Comment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comment> {
        return NSFetchRequest<Comment>(entityName: "Comment")
    }

    @NSManaged public var ups: NSNumber?
    @NSManaged public var downs: NSNumber?
    @NSManaged public var score: NSNumber?
    @NSManaged public var listingId: String
    @NSManaged public var subredditId: String?
    @NSManaged public var id: String
    @NSManaged public var author: String?
    @NSManaged public var authorId: String?
    @NSManaged public var parentId: String?
    @NSManaged public var body: String?
    @NSManaged public var permalink: String?
    @NSManaged public var name: String?
    @NSManaged public var created: NSNumber?
    @NSManaged public var voted: NSNumber?
    @NSManaged public var depth: NSNumber?
    @NSManaged public var edited: Bool
    @NSManaged public var scoreHidden: Bool
    @NSManaged public var sendReplies: Bool
    @NSManaged public var collapsed: Bool
    @NSManaged public var isSubmitter: Bool 
    @NSManaged public var listing: Listing

}
