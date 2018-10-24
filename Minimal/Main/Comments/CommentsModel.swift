//
//  CommentsModel.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/17/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

class CommentsModel {
    let database: Database
    let listing: Listing
    var nodes: [TreeNode<ChildData>] = []
    
    init(database: Database, listing: Listing) {
        self.database = database
        self.listing = listing
    }

    func requestComments(completionHandler: @escaping VoidCompletionHandler) {
        guard let prefix = listing.subredditNamePrefixed, let permalink = listing.permalink else { return }
        let request = ListingRequest(requestType: .comments(prefix: prefix, permalink: permalink))
        NetworkManager().session(forRoute: request.router, withDecodable: CommentStore.self) { (results) in
            switch results {
            case .failure(let error):
                posLog(error: error)
            case .success(let decoded):
                self.modifyCommenStoreElementAndPopulateData(decoded: decoded) {
                    completionHandler()
                }
            }
        }
    }
    
    func modifyCommenStoreElementAndPopulateData(decoded: CommentStore, completionHandler: @escaping VoidCompletionHandler) {
        let childData = decoded.flatMap({ $0.data.children }).compactMap({ $0.data })
        let modifiedChildData = childData.filter({ !$0.linkID.isEmpty })
        buildTreeNode(from: modifiedChildData)
        
        do {
            try Comment.populateObjects(fromJSON: modifiedChildData, database: database, completionHandler: { (error) in
                if let error = error {
                    posLog(error: error)
                } else {
                    completionHandler()
                    posLog(message: "Stored")
                }
            })
        } catch {
            posLog(error: error)
        }
    }

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
    func addChild(toNode node: TreeNode<ChildData>, forChildData data: ChildData) {
        if let children = data.replies?.data.children {
            for child in children {
                if child.data.parentID == data.name {
                    node.addChild(TreeNode<ChildData>(value: child.data))
                    if child.data.replies != nil && child.data.author != nil {
                        addChild(toNode: node, forChildData: child.data)
                    }
                }
            }
        }
    }
    
    // # of parent nodes
    func numberOfSections() -> Int {
        return nodes.count
    }
    
    // Count for children including parent node
    func numberOfRows(in section: Int) -> Int {
        return nodes[section].children.count + 1
    }
    
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
