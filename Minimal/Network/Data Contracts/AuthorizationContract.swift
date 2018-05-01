    //
//  AuthorizationContract.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 3/16/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

/*
 {
 "access_token" = "8EE...";
 "expires_in" = 3600;
 "refresh_token" = "dfsXQS...";
 scope = "identity mysubreddits read subscribe vote";
 "token_type" = bearer;
 }
 */

struct AuthorizationObject: Decodable {
    let accessToken: String
    let expiresIn: Int
    let refreshToken: String?
    let scope: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
        case tokenType = "token_type"
    }
    
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try root.decode(String.self, forKey: .accessToken)
        expiresIn = try root.decode(Int.self, forKey: .expiresIn)
        refreshToken = try root.decodeIfPresent(String.self, forKey: .refreshToken)
        scope = try root.decode(String.self, forKey: .scope)
        tokenType = try root.decode(String.self, forKey: .tokenType)
    }
}
