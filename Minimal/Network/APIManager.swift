//
//  APIManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case failedToParse(Error)
    case responseError(response: URLResponse?)
    case serverError(description: String)
}

protocol Routable {
    func setURLRequest() throws -> URLRequest
}

extension Routable {
    public var urlRequest: URLRequest? { return try? setURLRequest() }
    
    func generateBaseURL(forPath path: String, queryItems: [URLQueryItem], method: HTTPMethod) -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.reddit.com"
        components.path = path
        components.queryItems = queryItems
        
        let urlRequest = NSMutableURLRequest(url: components.url!)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = method.rawValue
        return urlRequest as URLRequest
    }
}

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

class APIManager {
    
    static let `default` = APIManager()
    
    private let defaultSession = URLSession(configuration: .default)
    private var task: URLSessionDataTask?
    
    func fetch<T>(forRoute route: Routable, withDecodable decodable: T.Type, completionHandler: @escaping ((NetworkError?, T?)->())) where T: Decodable  {
        guard let request = route.urlRequest else { return }
        task = defaultSession.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                completionHandler(NetworkError.serverError(description: error.localizedDescription), nil)
            }
            
            guard let response = urlResponse as? HTTPURLResponse, response.statusCode == 200 else {
                completionHandler(NetworkError.responseError(response: urlResponse), nil)
                return
            }
            
            if response.mimeType == "application/json", let data = data {
                let decoder = JSONDecoder()
                
                do {
                    let decoded = try decoder.decode(T.self, from: data)
                    completionHandler(nil, decoded)
                } catch let error {
                    completionHandler(NetworkError.failedToParse(error), nil)
                }
            }
        }
        task?.resume()
    }

}

