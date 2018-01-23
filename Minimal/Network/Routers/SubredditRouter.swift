//
//  SubredditRouter.swift
//  Minimal
//
//  Created by Jameson Kirby on 1/22/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

enum SubredditRouter: Routable {
    case paginate(limit: Int, after: String?)
    
    var path: String {
        switch self {
        case .paginate(_, _):
            var buildPath = "reddits.json"
            buildPath.insert("/", at: buildPath.startIndex)
            return buildPath
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .paginate(let limit, let after):
            var paginateQuery: [URLQueryItem] = []
            paginateQuery.append(URLQueryItem(name: "limit", value: "\(limit)"))
            if let after = after {
                paginateQuery.append(URLQueryItem(name: "after", value: after))
            }
            return paginateQuery
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .paginate:
            return .get
        }
    }
    
    func setURLRequest() throws -> URLRequest {
        let baseRequest = generateBaseURL(forPath: path, queryItems: queryItems, method: method)
        
        switch self {
        case .paginate:
            //urlRequest.setValue(token, forHTTPHeaderField: "Access-Token")
            return baseRequest
        }
    }
}

struct SubredditRequest: Requestable {
    let after: String?
    let limit: Int
    
    init(limit: Int, after: String?) {
        self.limit = limit
        self.after = after
    }

    var router: Routable {
        get {
            return SubredditRouter.paginate(limit: limit, after: after)
        }
    }
}
