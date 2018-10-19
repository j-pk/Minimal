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
            
            if let listing =  try Listing.fetchFirst(inContext: context, predicate: NSPredicate(format: "id == %@", comment.listingId)) {
                 comment.listing = listing
            }
            
            completionHandler(nil)
            
        } catch let error {
            completionHandler(error)
        }
    }
    
    
}
