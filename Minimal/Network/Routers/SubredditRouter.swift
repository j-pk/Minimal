//
//  SubredditRouter.swift
//  Minimal
//
//  Created by Jameson Kirby on 1/22/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

struct SubredditRequest: Requestable {
    let id: String?
    let count: Int?
    let after: String?
    let requestType: SubredditRouter
    
    init(requestType: SubredditRouter) {
        self.requestType = requestType
        switch requestType {
        case .subreddit(let prefixed):
            self.id = prefixed
            self.count = nil
            self.after = nil
        case .paginate(let count, let after):
            self.count = count
            self.after = after
            self.id = nil
        case .getSubscribed:
            self.count = nil
            self.after = nil
            self.id = nil
        }
    }
    
    var router: Routable {
        switch requestType {
        case .subreddit:
            return SubredditRouter.subreddit(id: id)
        case .paginate:
            return SubredditRouter.paginate(count: count, after: after)
        case .getSubscribed:
            return SubredditRouter.getSubscribed
        }
    }
}

// https://api.reddit.com/api/info.json?id=t5_2qi58
enum SubredditRouter: Routable {
    case subreddit(id: String?)
    case paginate(count: Int?, after: String?)
    case getSubscribed
    
    var path: String {
        var buildPath = ""
        switch self {
        case .subreddit:
            buildPath += "info.json"
            buildPath.insert("/", at: buildPath.startIndex)
            return buildPath
        case .paginate:
            buildPath += "reddits.json"
            buildPath.insert("/", at: buildPath.startIndex)
            return buildPath
        case .getSubscribed:
            buildPath +=  "subreddits/mine/subscriber"
            buildPath.insert("/", at: buildPath.startIndex)
            return buildPath
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .subreddit(let id):
            var paginateQuery: [URLQueryItem] = []
            if let id = id {
                paginateQuery.append(URLQueryItem(name: "id", value: id))
            }
            return paginateQuery
        case .paginate(let count, let after):
            var paginateQuery: [URLQueryItem] = []
            if let count = count {
                paginateQuery.append(URLQueryItem(name: "count", value: "\(count)"))
            }
            if let after = after {
                paginateQuery.append(URLQueryItem(name: "after", value: after))
            }
            return paginateQuery
        case .getSubscribed:
            return []
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .subreddit, .paginate, .getSubscribed:
            return .get
        }
    }
    
    func setURLRequest() throws -> URLRequest? {
        switch self {
        case .subreddit:
            return generateBasicAPIUrl(forPath: path, queryItems: queryItems, method: method)
        case .paginate:
            return generateBaseURL(forPath: path, queryItems: queryItems, method: method)
        case .getSubscribed:
            return generateOAuthURL(forPath: path, queryItems: queryItems, method: method)
        }
    }
}

