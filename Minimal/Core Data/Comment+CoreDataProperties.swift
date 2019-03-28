//
//  Comment+CoreDataProperties.swift
//  Minimal
//
//  Created by Jameson Kirby on 3/26/19.
//  Copyright © 2019 Parker Kirby. All rights reserved.
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
    @NSManaged public var listing: Listing?
    @NSManaged public var comments: NSOrderedSet?
    @NSManaged public var parent: Comment?

}

// MARK: Generated accessors for comments
extension Comment {

    @objc(insertObject:inCommentsAtIndex:)
    @NSManaged public func insertIntoComments(_ value: Comment, at idx: Int)

    @objc(removeObjectFromCommentsAtIndex:)
    @NSManaged public func removeFromComments(at idx: Int)

    @objc(insertComments:atIndexes:)
    @NSManaged public func insertIntoComments(_ values: [Comment], at indexes: NSIndexSet)

    @objc(removeCommentsAtIndexes:)
    @NSManaged public func removeFromComments(at indexes: NSIndexSet)

    @objc(replaceObjectInCommentsAtIndex:withObject:)
    @NSManaged public func replaceComments(at idx: Int, with value: Comment)

    @objc(replaceCommentsAtIndexes:withComments:)
    @NSManaged public func replaceComments(at indexes: NSIndexSet, with values: [Comment])

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: Comment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: Comment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSOrderedSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSOrderedSet)

}

// MARK: Generated accessors for listing
extension Comment {

    @objc(addListingObject:)
    @NSManaged public func addToListing(_ value: Listing)

    @objc(removeListingObject:)
    @NSManaged public func removeFromListing(_ value: Listing)

    @objc(addListing:)
    @NSManaged public func addToListing(_ values: NSSet)

    @objc(removeListing:)
    @NSManaged public func removeFromListing(_ values: NSSet)

}
