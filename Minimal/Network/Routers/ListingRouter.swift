//
//  ListingRouter.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/22/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation

struct ListingRequest: Requestable {
    
    enum RequestType {
        case subreddit
        case paginate
    }
    
    let subreddit: String
    let category: String?
    let timeFrame: String?
    let after: String?
    let limit: Int
    let requestType: RequestType
    
    init(subreddit: String, category: String?, timeFrame: String? = nil, after: String? = nil, limit: Int = 25, requestType: RequestType = .subreddit) {
        self.subreddit = subreddit
        self.category = category
        self.timeFrame = timeFrame
        self.after = after
        self.limit = limit
        self.requestType = requestType
    }
    
    var router: Routable {
        get {
            switch requestType {
            case .subreddit:
                return ListingRouter.subreddit(prefix: subreddit, category: category, timeFrame: timeFrame)
            case .paginate:
                return ListingRouter.paginate(prefix: subreddit, category: category, timeFrame: timeFrame, limit: limit, after: after)
            }
        }
    }
}

enum ListingRouter: Routable {
    case subreddit(prefix: String, category: String?, timeFrame: String?)
    case paginate(prefix: String, category: String?, timeFrame: String?, limit: Int, after: String?)
    
    //https://www.reddit.com/r/funny/top/.json?sort=top&t=24hours
    //https://www.reddit.com/r/funny/top/?sort=top&t=24hours&count=25&after=t3_7eaiko
    var path: String {
        switch self {
        case .subreddit(let prefix, let category, _), .paginate(let prefix, let category, _, _, _):
            var buildPath = prefix
            if let category = category {
                buildPath += "/\(category)/.json"
            } else {
                buildPath += buildPath == "" ? ".json" : "/.json"
            }
            buildPath.insert("/", at: buildPath.startIndex)
            return buildPath
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .subreddit(_, let category, let timeFrame):
            var subredditQuery: [URLQueryItem] = []
            if let category = category {
               subredditQuery.append(URLQueryItem(name: "sort", value: category))
            }
            if let timeFrame = timeFrame {
                subredditQuery.append(URLQueryItem(name: "t", value: timeFrame))
            }
            return subredditQuery
        case .paginate(_, let category, let timeFrame, let limit, let after):
            var paginateQuery: [URLQueryItem] = []
            if let category = category {
                paginateQuery.append(URLQueryItem(name: "sort", value: category))
            }
            if let timeFrame = timeFrame {
                paginateQuery.append(URLQueryItem(name: "t", value: timeFrame))
            }
            paginateQuery.append(URLQueryItem(name: "limit", value: "\(limit)"))
            if let after = after {
                paginateQuery.append(URLQueryItem(name: "after", value: after))
            }
            return paginateQuery
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .subreddit, .paginate:
            return .get
        }
    }
    
    func setURLRequest() throws -> URLRequest {
        let baseRequest = generateBaseURL(forPath: path, queryItems: queryItems, method: method)
        
        switch self {
        case .subreddit, .paginate:
            //urlRequest.setValue(token, forHTTPHeaderField: "Access-Token")
            return baseRequest
        }
    }
}

