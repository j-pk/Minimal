//
//  ListingRouter.swift
//  Minimal
//
//  Created by Jameson Kirby on 11/22/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation

struct ListingRequest: Requestable {
    let subreddit: String
    let category: String?
    let timeFrame: String?
    let after: String?
    let permalink: String?
    let limit: Int = 25
    let requestType: ListingRouter
    
    init(requestType: ListingRouter) {
        self.requestType = requestType
        switch requestType {
        case .subreddit(let prefix, let category, let timeFrame):
            self.subreddit = prefix
            self.category = category
            self.timeFrame = timeFrame
            self.after = nil
            self.permalink = nil
        case .paginate(let prefix, let category, let timeFrame, _, let after):
            self.subreddit = prefix
            self.category = category
            self.timeFrame = timeFrame
            self.after = after
            self.permalink = nil
        case .comments(let prefix, let permalink):
            self.subreddit = prefix
            self.category = nil
            self.timeFrame = nil
            self.after = nil
            self.permalink = permalink
        }
    }   
    
    var router: Routable {
        get {
            switch requestType {
            case .subreddit:
                return ListingRouter.subreddit(prefix: subreddit, category: category, timeFrame: timeFrame)
            case .paginate:
                return ListingRouter.paginate(prefix: subreddit, category: category, timeFrame: timeFrame, limit: limit, after: after)
            case .comments:
                return ListingRouter.comments(prefix: subreddit, permalink: permalink)
            }
        }
    }
}

enum ListingRouter: Routable {
    case subreddit(prefix: String, category: String?, timeFrame: String?)
    case paginate(prefix: String, category: String?, timeFrame: String?, limit: Int, after: String?)
    case comments(prefix: String, permalink: String?)
    
    //https://www.reddit.com/r/funny/top/.json?sort=top&t=24hours
    //https://www.reddit.com/r/funny/top/?sort=top&t=24hours&count=25&after=t3_7eaiko
    //https://www.reddit.com/controversial.json?t=week
    //http://reddit.com/r/[subreddit].[rss/json]?limit=[limit]&after=[after]
    var path: String {
        switch self {
        case .subreddit(let prefix, let category, _), .paginate(let prefix, let category, _, _, _):
            var buildPath = prefix
            if let category = category {
                buildPath += prefix == "" ? "/\(category).json" : "/\(category)/.json"
            } else {
                buildPath += "/.json"
            }
            if buildPath.first != "/" {
               buildPath.insert("/", at: buildPath.startIndex)
            }
            return buildPath
        case .comments(_, let permalink):
            if let permalink = permalink {
                return permalink + ".json"
            }
            return ""
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .subreddit(_, _, let timeFrame):
            var subredditQuery: [URLQueryItem] = []
            if let timeFrame = timeFrame {
                subredditQuery.append(URLQueryItem(name: "t", value: timeFrame))
            }
            return subredditQuery
        case .paginate(_, _, let timeFrame, let limit, let after):
            var paginateQuery: [URLQueryItem] = []
            if let timeFrame = timeFrame {
                paginateQuery.append(URLQueryItem(name: "t", value: timeFrame))
            }
            paginateQuery.append(URLQueryItem(name: "limit", value: "\(limit)"))
            if let after = after {
                paginateQuery.append(URLQueryItem(name: "after", value: after))
            }
            return paginateQuery
        default:
            return []
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .subreddit, .paginate, .comments:
            return .get
        }
    }
    
    func setURLRequest() throws -> URLRequest? {
        let baseRequest = generateBaseURL(forPath: path, queryItems: queryItems, method: method)
        
        switch self {
        case .subreddit, .paginate, .comments:
            return baseRequest
        }
    }
}

