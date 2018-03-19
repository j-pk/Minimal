//
//  SearchSubredditManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 1/22/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

class SearchSubredditManager {
    var requestCount = 0
    var request: Requestable?
    var database: Database?
    
    @discardableResult init(database: Database) {
        self.database = database
        requestSubreddits()
    }
    
    private func requestSubreddits() {
        let defaultRequest = request ?? SubredditRequest(count: nil, after: nil)
        SubredditNetwork(request: defaultRequest) { (error, subredditStore) in
            if let error = error {
                posLog(error: error, category: String(describing: self))
            } else if self.requestCount <= 75 {
                if let store = subredditStore, let database = self.database {
                    do {
                        try Subreddit.populateObjects(fromJSON: store.subreddits, database: database, completionHandler: { (error) in
                            if let error = error {
                                posLog(error: error, category: String(describing: self))
                            }
                        })
                    } catch let error {
                        posLog(error: error, category: String(describing: self))
                    }
                    self.requestCount += store.subreddits.count
                    self.request = SubredditRequest(count: self.requestCount, after: store.after)
                    self.requestSubreddits()
                }
            } else {
                posLog(message: "Completed: \(self.requestCount) Subreddits Found", category: String(describing: self))
            }
        }
    }
}

struct SubredditNetwork: Networkable {
    var networkEngine: NetworkEngine = NetworkManager()
    
    @discardableResult init(request: Requestable, completionHandler: @escaping (NetworkError?, SubredditStore?) -> Void) {
        self.networkEngine.session(forRoute: request.router, withDecodable: SubredditStore.self) { (result) in
            switch result {
            case .failure(let error):
                completionHandler(error, nil)
            case .success(let decoded):
                completionHandler(nil, decoded)
            }
        }
    }
}
