//
//  SubredditRouter.swift
//  Minimal
//
//  Created by Jameson Kirby on 1/22/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

struct SubredditRequest: Requestable {
    enum RequestType {
        case paginate
        case getSubscribed
    }
    
    let count: Int?
    let after: String?
    let requestType: RequestType
    
    init(count: Int? = nil, after: String? = nil, requestType: RequestType = .paginate) {
        self.count = count
        self.after = after
        self.requestType = requestType
    }
    
    var router: Routable {
        switch requestType {
        case .paginate:
            return SubredditRouter.paginate(count: count, after: after)
        case .getSubscribed:
            return SubredditRouter.getSubscribed()
        }
    }
}

enum SubredditRouter: Routable {
    case paginate(count: Int?, after: String?)
    case getSubscribed()
    
    var path: String {
        var buildPath = ""
        switch self {
        case .paginate(_, _):
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
        case .paginate, .getSubscribed:
            return .get
        }
    }
    
    func setURLRequest() throws -> URLRequest? {
        switch self {
        case .paginate:
            return generateBaseURL(forPath: path, queryItems: queryItems, method: method)
        case .getSubscribed:
            return generateOAuthURL(forPath: path, queryItems: queryItems, method: method)
        }
    }
}

