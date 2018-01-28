//
//  SubredditRouter.swift
//  Minimal
//
//  Created by Jameson Kirby on 1/22/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

struct SubredditRequest: Requestable {
    let after: String?
    let count: Int?
    
    init(count: Int?, after: String?) {
        self.count = count
        self.after = after
    }
    
    var router: Routable {
        get {
            return SubredditRouter.paginate(count: count, after: after)
        }
    }
}

enum SubredditRouter: Routable {
    case paginate(count: Int?, after: String?)
    
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
        case .paginate(let count, let after):
            var paginateQuery: [URLQueryItem] = []
            if let count = count {
                paginateQuery.append(URLQueryItem(name: "count", value: "\(count)"))
            }
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

