//
//  Comment+CoreDataClass.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/16/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//
//

import Foundation
import CoreData


public class Comment: NSManagedObject {
    
}

extension Comment: Manageable {
    static func populateObject(fromDecodable json: Decodable, context: NSManagedObjectContext, completionHandler: @escaping OptionalErrorHandler) {
        
        guard let json = json as? ChildData else { fatalError("Failed to cast decodable as CommentObject.") }
        
        do {
            
            let comment: Comment = try Comment.fetchFirst(inContext: context, predicate: NSPredicate(format: "id == %@", json.id)) ?? Comment.insertObject(inContext: context)
            
            comment.author = json.author
            comment.authorId = json.authorID
            comment.body = json.body
            comment.collapsed = json.collapsed.unsafelyUnwrapped
            comment.created = json.createdUTC as NSNumber?
            comment.depth = json.depth as NSNumber?
            comment.downs = json.downs  as NSNumber?
            comment.edited = json.edited ?? false
            comment.id = json.id
            comment.isSubmitter = json.isSubmitter ?? false
            comment.listingId = json.linkID
            comment.name = json.name
            comment.parentId = json.parentID
            comment.permalink = json.permalink
            comment.score = json.score  as NSNumber?
            comment.scoreHidden = json.scoreHidden ?? false
            comment.sendReplies = json.sendReplies ?? false 
            comment.ups = json.ups as NSNumber?
            
            if let listing = try Listing.fetchFirst(inContext: context, predicate: NSPredicate(format: "name == %@", json.linkID)) {
                comment.listing = listing
                if json.linkID == json.parentID {
                    addChild(toParent: comment, forListing: listing, withChildData: json, context: context)
                }
            }
            
            completionHandler(nil)
        } catch let error {
            completionHandler(error)
        }
    }
    
    // Recursive - Tree Structure
    // Note: Not all comments are parsed due to limitations around the reddit API
    // JSON [children: [String]] contains a list of collasped comments - currently filtered as it requires additional network calls
    private static func addChild(toParent parent: Comment, forListing listing: Listing, withChildData data: ChildData, context: NSManagedObjectContext) {
        if let children = data.replies?.data.children {
            for child in children {
                if child.data.parentID == data.name && child.data.author != nil {
                    if let childComment = addChild(child: child.data, context: context) {
                        parent.addToComments(childComment)
                        childComment.parent = parent
                        childComment.listing = listing
                        if child.data.replies != nil {
                            addChild(toParent: parent, forListing: listing, withChildData: child.data, context: context)
                        }
                    }
                }
            }
        }
    }
    
    private static func addChild(child: ChildData, context: NSManagedObjectContext) -> Comment? {
        guard let comment: Comment = try? Comment.fetchFirst(inContext: context, predicate: NSPredicate(format: "id == %@", child.id)) ?? Comment.insertObject(inContext: context) else { return nil }
        comment.author = child.author
        comment.authorId = child.authorID
        comment.body = child.body
        comment.collapsed = child.collapsed.unsafelyUnwrapped
        comment.created = child.createdUTC as NSNumber?
        comment.depth = child.depth as NSNumber?
        comment.downs = child.downs  as NSNumber?
        comment.edited = child.edited ?? false
        comment.id = child.id
        comment.isSubmitter = child.isSubmitter ?? false
        comment.listingId = child.linkID
        comment.name = child.name
        comment.parentId = child.parentID
        comment.permalink = child.permalink
        comment.score = child.score  as NSNumber?
        comment.scoreHidden = child.scoreHidden ?? false
        comment.sendReplies = child.sendReplies ?? false
        comment.ups = child.ups as NSNumber?
        
        return comment
    }

}
