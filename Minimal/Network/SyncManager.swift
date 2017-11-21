//
//  SyncManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/24/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation

enum SyncError: Error {
    case failedToSave
    case networkError(error: NetworkError)
    case failedToReturnListing
}

enum ListingRouter: Routable {
    case subreddit(prefix: String, category: String?, timeframe: String?)
    case paginate(prefix: String, category: String?, timeframe: String?, limit: Int, after: String)
    
    //https://www.reddit.com/r/funny/top/.json?sort=top&t=24hours
    //https://www.reddit.com/r/funny/top/?sort=top&t=24hours&count=25&after=t3_7eaiko
    var path: String {
        switch self {
        case .subreddit(let prefix, let category, let timeframe):
            var buildPath = prefix
            if let category = category {
                buildPath += "\(category)/.json"
                if let timeframe = timeframe {
                    buildPath += "?sort=\(category)&t=\(timeframe)"
                }
            } else {
                buildPath += ".json"
            }
            return buildPath
        case .paginate(let prefix, let category, let timeframe, let limit, let after):
            var buildPath = prefix
            if let category = category {
                buildPath += "\(category)/.json"
                if let timeframe = timeframe {
                    buildPath += "?sort=\(category)&t=\(timeframe)&limit=\(limit)&after=\(after)"
                } else {
                    buildPath += "?limit=\(limit)&after=\(after)"
                }
            } else {
                buildPath += ".json"
            }
            return buildPath
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .subreddit, .paginate:
            return .get
        }
    }
    
    func setURLRequest() throws -> URLRequest {
        let baseRequest = APIManager.default.generateBaseURL(forPath: path, method: method)
        
        switch self {
        case .subreddit, .paginate:
            //urlRequest.setValue(token, forHTTPHeaderField: "Access-Token")
            return baseRequest
        }
    }
}

class SyncManager {
    
    static let `default` = SyncManager()
    private var isSyncing = false
    //What do I need to paginate?
    //reddit api url
    //subreddit /r/~
    //category type?
    //limit value?
    //after value?
    //count?
    
    func syncListing(prefix: String, category: String?, timeframe: String?, completionHandler: @escaping ((SyncError?)->())) {
        APIManager.default.fetchListings(prefix: prefix, category: category, timeframe: timeframe) { (error, listingObjects) in
            if let error = error {
                completionHandler(SyncError.networkError(error: error))
            }
            if let objects = listingObjects {
                do {
                    try Listing.populateObjects(fromJSON: objects, completionHandler: { (error) in
                        if error != nil {
                            completionHandler(SyncError.failedToSave)
                        }
                    })
                } catch {
                    completionHandler(SyncError.failedToSave)
                }
                completionHandler(nil)
            } else {
                completionHandler(SyncError.failedToReturnListing)
            }
        }
    }
}
