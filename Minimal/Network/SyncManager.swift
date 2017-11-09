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

typealias URLData = (subreddit: String?, after: String?, limit: Int?, category: ListingCategoryType?)

class SyncManager {
    
    static let `default` = SyncManager()
    private let defaultAPIUrl = "https://www.reddit.com/"
    private var isSyncing = false
    //What do I need to paginate?
    //reddit api url
    //subreddit /r/~
    //category type?
    //limit value?
    //after value?
    //count?
    
    func syncListing(forUrlData data: URLData, completionHandler: @escaping ((SyncError?)->())) {
        guard let url = generateUrl(fromUrlData: data) else { return completionHandler(SyncError.failedToSave) }
        APIManager.default.fetchListing(forUrl: url) { (networkError, listingObjects) in
            if let error = networkError {
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
    
    private func generateUrl(fromUrlData data: URLData) -> URL? {
        switch data {
        case let (subreddit?, nil, nil, nil):
            return URL(string: defaultAPIUrl + subreddit + ".json")
        case let (subreddit?, nil, nil, category?):
            return URL(string: defaultAPIUrl + subreddit + category.stringValue + "/.json")
        case let (subreddit?, after?, limit?, nil):
            return URL(string: defaultAPIUrl + subreddit + ".json" + "?limit=\(limit)&after=\(after)")
        case let (subreddit?, after?, limit?, category?):
            return URL(string: defaultAPIUrl + subreddit + category.stringValue + "/.json" + "?limit=\(limit)&after=\(after)")
        case let (nil, after?, limit?, nil):
            return URL(string: defaultAPIUrl + ".json" + "?limit=\(limit)&after=\(after)")
        default:
            return URL(string: defaultAPIUrl + ".json")
        }
    }
}
