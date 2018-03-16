//
//  AuthorizationRouter.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 3/16/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

struct AuthorizationRequest: Requestable {
    let code: String
    let state: String
    
    init(code: String, state: String) {
        self.code = code
        self.state = code
    }
    
    var router: Routable {
        return AuthorizationRouter.authorize(code: code, state: state)
    }
}

enum AuthorizationRouter: Routable {
    case authorize(code: String, state: String)
    
    var path: String {
        return "/api/v1/access_token"
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
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .authorize:
            return .post
        }
    }
    
    func setURLRequest() throws -> URLRequest {
        return generateAuthorizationURL(forPath: path, queryItems: queryItems, method: method)
    }
}


