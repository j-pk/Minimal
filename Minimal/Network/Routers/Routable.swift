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
}
