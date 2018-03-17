//
//  AuthorizationRouter.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 3/16/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

struct AuthorizationRequest: Requestable {
    let code: String?
    let state: String?
    let token: String?
    let requestType: AuthorizationRouter

    init(requestType: AuthorizationRouter) {
        self.requestType = requestType
        switch requestType {
        case .authorize(let code, let state):
            self.code = code
            self.state = state
            self.token = nil
        case .refresh(let token):
            self.code = nil
            self.state = nil
            self.token = token
        }
    }
    
    var router: Routable {
        switch requestType {
        case .authorize(let code, let state):
            return AuthorizationRouter.authorize(code: code, state: state)
        case .refresh(let token):
            return AuthorizationRouter.refresh(token: token)
        }
    }
}

enum AuthorizationRouter: Routable {
    case authorize(code: String, state: String)
    case refresh(token: String)
    
    var host: String {
        switch self {
        case .authorize, .refresh:
            return "ssl.reddit.com"
        }
    }
    var path: String {
        switch self {
        case .authorize, .refresh:
            return "/api/v1/access_token"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .authorize(let code, let state):
            let parameters = [
                "grant_type": "authorization_code",
                "state": state,
                "code": code,
                "redirect_uri": "minimalApp://minimalApp.com"
            ]
            return parameters.map{ URLQueryItem(name: $0, value: $1) }
        case .refresh(let token):
            let parameters = [
                "grant_type": "refresh_token",
                "refresh_token": token
            ]
            return parameters.map{ URLQueryItem(name: $0, value: $1) }
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .authorize, .refresh:
            return .post
        }
    }
    
    func setURLRequest() throws -> URLRequest? {
        switch self {
        case .authorize, .refresh:
            return generateBasicAuthorizationURL(forPath: path, queryItems: queryItems, method: method)
        }
    }
}


