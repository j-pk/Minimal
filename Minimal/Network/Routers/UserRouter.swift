//
//  UserRouter.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 10/11/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

enum UserVoteDirection: Int {
    case down = -1
    case cancel = 0
    case up = 1
}

struct UserRequest: Requestable {
    let requestType: UserRouter
    let id: String
    let direction: UserVoteDirection
    
    init(requestType: UserRouter) {
        self.requestType = requestType
        switch requestType {
        case .vote(let id, let direction):
            self.id = id
            self.direction = direction
        }
    }
    
    var router: Routable {
        switch requestType {
        case .vote(let id, let direction):
            return UserRouter.vote(id: id, direction: direction)
        }
    }

}

enum UserRouter: Routable {
    case vote(id: String, direction: UserVoteDirection)
    
    var host: String {
        switch self {
        case .vote:
            return "www.reddit.com"
        }
    }
    var path: String {
        switch self {
        case .vote:
            return "/api/v1/vote"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .vote(let id, let direction):
            let parameters = [
                "id": "t3_\(id)",
                "dir": "\(direction.rawValue)"
            ]
            return parameters.map{ URLQueryItem(name: $0, value: $1) }
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .vote:
            return .post
        }
    }
    
    func setURLRequest() throws -> URLRequest? {
        switch self {
        case .vote:
            return generateBasicOAuthAPIUrl(forHost: host, path: path, queryItems: queryItems, method: method)
        }
    }
    
}
