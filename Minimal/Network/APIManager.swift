//
//  APIManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case failedToParse(description: String)
    case responseError(response: URLResponse?)
    case serverError(description: String)
}

protocol Routable {
    func setURLRequest() throws -> URLRequest
}

extension Routable {
    public var urlRequest: URLRequest? { return try? setURLRequest() }
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
    private let baseURLString = "https://www.reddit.com/"
    
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
                } catch let error as NSError {
                    completionHandler(NetworkError.failedToParse(description: error.debugDescription), nil)
                }
            }
        }
        task?.resume()
    }
    
    func generateBaseURL(forPath path: String, method: HTTPMethod) -> URLRequest {
        let url = URL(string: baseURLString)!
        let urlRequest = NSMutableURLRequest(url: url.appendingPathComponent(path))
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = method.rawValue
        return urlRequest as URLRequest
    }
    
}

extension APIManager {
    func fetchListings(prefix: String, category: String?, timeframe: String?, completion: @escaping ((NetworkError?, [ListingMapped]?)->())) {
        let router = ListingRouter.subreddit(prefix: prefix, category: category, timeframe: timeframe)
        fetch(forRoute: router, withDecodable: ListingRoot.self) { (error, decoded) in
            if let error = error {
                print(error)
                completion(error, nil)
            } else {
                if let root = decoded {
                    let listings = root.listings.map({ listingData in ListingMapped(root: root, data: listingData) })
                    completion(nil, listings)
                } else {
                    //errpr
                }
            }
        }
    }
}
