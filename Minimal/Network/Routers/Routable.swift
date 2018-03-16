//
//  Routable.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 1/27/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

/// Routable
///
/// Conform an enum to a Routable will build out the necessary components
/// to generate a url request in compliance with the Network Engine
protocol Routable {
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var method: HTTPMethod { get }
    func setURLRequest() throws -> URLRequest
}

/// Requestable
///
/// Conform an enum to a Requestable is needed to offer different endpoint paths
/// and to generate a proper Routable
protocol Requestable {
    var router: Routable { get }
}

extension Routable {
    public var urlRequest: URLRequest? { return try? setURLRequest() }
    
    func generateBaseURL(forPath path: String, queryItems: [URLQueryItem], method: HTTPMethod) -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.reddit.com"
        components.path = path
        components.queryItems = queryItems.count > 0 ? queryItems : nil
        
        let urlRequest = NSMutableURLRequest(url: components.url!)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = method.rawValue
        return urlRequest as URLRequest
    }
    
    func generateOAuthURL(forPath path: String, queryItems: [URLQueryItem], method: HTTPMethod) -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "oauth.reddit.com"
        components.path = path
        components.queryItems = queryItems.count > 0 ? queryItems : nil
        
        let urlRequest = NSMutableURLRequest(url: components.url!)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("iOS:Minimal for Reddit/0.1 by pkoddity", forHTTPHeaderField: "User-Agent")
        if let defaults = Defaults.retrieve(), let accessToken = defaults.accessToken {
            urlRequest.setValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            urlRequest.httpMethod = method.rawValue
            return urlRequest as URLRequest
        }
        return urlRequest as URLRequest
    }
    
    func generateAuthorizationURL(forPath path: String, queryItems: [URLQueryItem], method: HTTPMethod) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "ssl.reddit.com"
        components.path = path
        components.queryItems = queryItems.count > 0 ? queryItems : nil
        
        guard let encodedParameters = components.string?.dropFirst().data(using: .utf8, allowLossyConversion: false) else { return nil }
        guard let data = String(format: "%@:%@", "mtOhKTWpoebjUg", "").data(using: .utf8) else { return nil }
        let credentials = data.base64EncodedString(options: [])
        
        let urlRequest = NSMutableURLRequest(url: components.url!)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = encodedParameters

        return urlRequest as URLRequest
    }
}
