//
//  SubredditManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 1/22/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

struct SubredditManager {
    @discardableResult init() {
        var requestLimit = 25
        var subredditRequest = SubredditRequest(limit: requestLimit, after: nil)
        SubredditModel(request: subredditRequest) { (error, subredditStore) in
            if let error = error {
                print(error)
            }
            if requestLimit <= 500 {
                if let store = subredditStore {
                    requestLimit += store.subreddits.count
                    subredditRequest = SubredditRequest(limit: requestLimit, after: store.after)
                    SubredditManager()
                    print(store.subreddits)
                } else {
                    print("COMPLETED")
                }
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
