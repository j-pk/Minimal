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
                posLog(values: decoded)
            }
        }
    }
    
}
