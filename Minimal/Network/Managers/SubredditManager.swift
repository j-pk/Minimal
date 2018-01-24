//
//  SubredditManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 1/22/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

class SearchSubredditManager {
    var requestCount = 0
    var request: Requestable?
    
    @discardableResult init() {
        requestSubreddits()
    }
    
    private func requestSubreddits() {
        let defaultRequest = request ?? SubredditRequest(count: nil, after: nil)
        SubredditModel(request: defaultRequest) { (error, subredditStore) in
            if let error = error {
                print(error)
            }
            if self.requestCount <= 75 {
                if let store = subredditStore {
                    self.requestCount += store.subreddits.count
                    self.request = SubredditRequest(count: self.requestCount, after: store.after)
                    self.requestSubreddits()
                }
            } else {
                print("COMPLETED")
                return
            }
        }
    }
}

struct SubredditModel: Modelable {
    var networkEngine: NetworkEngine = NetworkManager()
    
    @discardableResult init(request: Requestable, completionHandler: @escaping (NetworkError?, SubredditStore?) -> Void) {
        self.networkEngine.session(forRoute: request.router, withDecodable: SubredditStore.self) { (error, decoded) in
            if let error = error {
                completionHandler(error, nil)
            } else {
                if let decoded = decoded {
                    completionHandler(nil, decoded)
                } else {
                    completionHandler(NetworkError.serverError(description: "No data for \(String(describing: request.router.urlRequest))"), nil)
                }
            }
        }
    }
}
