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
        let defaultRequest = request ?? SubredditRequest(requestType: .paginate(count: nil, after: nil))
        SubredditNetwork(request: defaultRequest) { (result) in
            switch result {
            case .failure(let error):
                posLog(error: error, category: String(describing: self))
            case .success(let store):
                if self.requestCount <= 500 {
                    if let database = self.database {
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
                        self.request = SubredditRequest(requestType: .paginate(count: self.requestCount, after: store.after))
                        self.requestSubreddits()
                    }
                } else {
                    posLog(message: "Completed: \(self.requestCount) Subreddits Found", category: String(describing: self))
                }
            }
        }
    }
}

struct SubredditNetwork: Networkable {
    var networkEngine: NetworkEngine = NetworkManager()
    
    @discardableResult init(request: Requestable, completionHandler: @escaping ResultCompletionHandler<SubredditStore>) {
        self.networkEngine.session(forRoute: request.router, withDecodable: SubredditStore.self) { (result) in
            switch result {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(let decoded):
                completionHandler(.success(decoded))
            }
        }
    }
}
