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
    
    init(database: Database, listing: Listing) {
        self.database = database
        self.listing = listing
    }
    // fetch data for comments
    // parse comments
    // build datasource
    // return datasource to tableView
    
    func requestComments() {
        guard let prefix = listing.subredditNamePrefixed, let permalink = listing.permalink else { return }
        let request = ListingRequest(requestType: .comments(prefix: prefix, permalink: permalink))
        NetworkManager().session(forRoute: request.router, withDecodable: CommentStore.self) { (results) in
            switch results {
            case .failure(let error):
                posLog(error: error)
            case .success(let decoded):
                self.modifyCommenStoreElementAndPopulateData(decoded: decoded)
            }
        }
    }
    
    func modifyCommenStoreElementAndPopulateData(decoded: CommentStore) {
        let childData = decoded.flatMap({ $0.data.children }).compactMap({ $0.data })
        let modifiedChildData = childData.filter({ !$0.linkID.isEmpty })
        buildTree(from: modifiedChildData)
        
        do {
            try Comment.populateObjects(fromJSON: modifiedChildData, database: database, completionHandler: { (error) in
                if let error = error {
                    posLog(error: error)
                } else {
                    posLog(message: "Stored")
                }
            })
        } catch {
            posLog(error: error)
        }
    }
    
    func buildTree(from data: [ChildData]) {
        var nodes: [TreeNode<ChildData>] = []
        data.forEach({ child in
            if child.linkID == child.parentID {
                let node = TreeNode<ChildData>(value: child)
                child.replies?.data.children.forEach({ replies in
                    if child.name == replies.data.parentID {
                        node.addChild(TreeNode<ChildData>(value: child))
                    }
                })
                nodes.append(node)
            }
        })
        posLog(values: nodes)
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

extension TreeNode: CustomStringConvertible {
    public var description: String {
        var s = "\(value)"
        if !children.isEmpty {
            s += " {" + children.map { $0.description }.joined(separator: ", ") + "}"
        }
        return s
    }
}
