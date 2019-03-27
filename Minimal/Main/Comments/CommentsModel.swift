//
//  CommentsModel.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/17/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import UIKit

class CommentsModel {
    let database: Database
    let listing: Listing
    var comments: [Comment] = []
    
    init(database: Database, listing: Listing) {
        self.database = database
        self.listing = listing
    }

    func requestComments(completionHandler: @escaping OptionalErrorHandler) {
        guard let prefix = listing.subredditNamePrefixed, let permalink = listing.permalink else { completionHandler(CoreDataError.failedToFetchObject("Failed: Listing.subredditNamePrefixed/permalink")); return }
        let request = ListingRequest(requestType: .comments(prefix: prefix, permalink: permalink))
        NetworkManager().session(forRoute: request.router, withDecodable: CommentStore.self) { (results) in
            switch results {
            case .failure(let error):
                completionHandler(error)
                posLog(error: error)
            case .success(let decoded):
                self.modifyCommenStoreElementAndPopulateData(decoded: decoded, completionHandler: completionHandler)
            }
        }
    }
    
    func modifyCommenStoreElementAndPopulateData(decoded: CommentStore, completionHandler: @escaping OptionalErrorHandler) {
        let childData = decoded.flatMap({ $0.data.children }).compactMap({ $0.data })
        let modifiedChildData = childData.filter({ !$0.linkID.isEmpty })
        
        do {
            try Comment.populateObjects(fromJSON: modifiedChildData, database: database, completionHandler: { [unowned self] (error) in
                if let error = error {
                    completionHandler(error)
                    posLog(error: error)
                } else {
                    self.fetchComments(completionHandler: completionHandler)
                    posLog(message: "Stored")
                }
            })
        } catch {
            completionHandler(error)
            posLog(error: error)
        }
    }
    
    func fetchComments(completionHandler: @escaping OptionalErrorHandler) {
        do {
            guard let id = listing.name else { completionHandler(CoreDataError.failedToFetchObject("Failed: Listing.name")); return }
            let listingPredicate = NSPredicate(format: "parent == nil && listingId == parentId && listingId == %@", id)
            let sortDescriptors = [NSSortDescriptor(key: "score", ascending: false), NSSortDescriptor(key: "depth", ascending: false), NSSortDescriptor(key: "created", ascending: false)]
            comments = try Comment.fetchObjects(inContext: database.viewContext, predicate: listingPredicate, sortDescriptors: sortDescriptors)
            completionHandler(nil)
        } catch let error {
            completionHandler(error)
            posLog(error: error)
        }
    }
    
    // # of parent nodes
    func numberOfSections() -> Int {
        return comments.count != 0 ? comments.count : 1
        //return nodes.count != 0 ? nodes.count : 1
    }
    
    // Count for children including parent node
    func numberOfRows(in section: Int) -> Int {
        return comments.count != 0 ? comments[section].comments!.count + 1 : 0
        //return nodes.count != 0 ? nodes[section].children.count + 1 : 0
    }
    
    func comment(atIndexPath indexPath: IndexPath) -> Comment {
        let node = comments[indexPath.section]
        
        switch indexPath.row {
        case 0:
            return node
        default:
            guard let comments = node.comments?.array as? [Comment] else { return node }
            // index out of range preventive 
            return comments[safe: indexPath.row - 1] ?? node
        }
    }
    
    func presentAction(forComment comment: Comment) -> UIAlertController {
        // upvote, reply, share, report, collapse?
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let shareAction = UIAlertAction(title: "Upvote", style: .default) { (action) in
            // shareAction
        }
        let saveAction = UIAlertAction(title: "Reply", style: .default) { (action) in
            // saveAction
        }
        let hideAction = UIAlertAction(title: "Share", style: .default) { (action) in
            // hideAction
        }
        let reportAction = UIAlertAction(title: "Report", style: .default) { (action) in
            // reportAction
            posLog(message: "Report")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        let actions = [shareAction, saveAction, hideAction, reportAction, cancelAction]
        actions.forEach({ controller.addAction($0) })
        return controller
    }
    
    /* No long in use as comments/tree are now persisted in Core Data
       Reference Material
    func buildTreeNode(from data: [ChildData]) {
        data.forEach({ child in
            if child.linkID == child.parentID {
                let node = TreeNode<ChildData>(value: child)
                nodes.append(node)
                addChild(toNode: node, forChildData: child)
            }
        })
    }
    
    // Recursive
    // Note: Not all comments are parsed due to limitations around the reddit API
    // [children: [String]] contains a list of collasped comments - currently filtered as it requires additional network calls
    func addChild(toNode node: TreeNode<ChildData>, forChildData data: ChildData) {
        if let children = data.replies?.data.children {
            for child in children {
                if child.data.parentID == data.name && child.data.author != nil {
                    node.addChild(TreeNode<ChildData>(value: child.data))
                    if child.data.replies != nil {
                        addChild(toNode: node, forChildData: child.data)
                    }
                }
            }
        }
    }
    */
}

public class TreeNode<T> {
    public var value: T
    
    public weak var parent: TreeNode?
    public var children = [TreeNode<T>]()
    
    public init(value: T) {
        self.value = value
    }
    
    public func addChild(_ node: TreeNode<T>) {
        children.append(node)
        node.parent = self 
    }
}

// Recursive
extension TreeNode where T: Equatable {
    func search(value: T) -> TreeNode? {
        if value == self.value {
            return self
        }
        for child in children {
            if let found = child.search(value: value) {
                return found
            }
        }
        return nil
    }
    
    func count() -> Int {
        if parent == nil {
            return 1
        }
        for child in children {
            return child.count() + 1
        }
        return 1
    }
}

extension TreeNode: Equatable {
    static public func == (lhs: TreeNode<T>, rhs: TreeNode<T>) -> Bool {
        return lhs.parent == rhs.parent
    }
}

extension TreeNode where T: Equatable {
    static func ==(lhs: TreeNode<T>, rhs: TreeNode<T>) -> Bool {
        return lhs.parent == rhs.parent && lhs.value == rhs.value
    }
}

extension ChildData: Equatable {
    static public func == (lhs: ChildData, rhs: ChildData) -> Bool {
        return lhs.id == rhs.id
    }
}
