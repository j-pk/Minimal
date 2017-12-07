//
//  APIManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation
import SafariServices

enum NetworkError: Error {
    case failedToParse(Error)
    case responseError(response: URLResponse?)
    case serverError(description: String)
}

protocol Routable {
    func setURLRequest() throws -> URLRequest
}

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
    
    func session<T>(forRoute route: Routable, withDecodable decodable: T.Type, completionHandler: @escaping ((NetworkError?, T?)->())) where T: Decodable  {
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
    
    //redirect uri minimalApp://minimalApp.com
    //client id t6Z4BZyV3a06eA
    
    //authorization url
    //https://www.reddit.com/api/v1//api/v1/authorize.compact?client_id=t6Z4BZyV3a06eA&response_type=code&state=RANDOM_STRING&redirect_uri=minimalApp://minimalApp.com&duration=permanent&scope=identity,vote,read,subscribe,mysubreddits
    
    //state user defaults random string to compare on uri redirect
    func requestAuthentication(completionHandler: @escaping (URL?, Error?) -> Swift.Void) -> SFAuthenticationSession? {
        var authSession: SFAuthenticationSession?
        let randomString = NSUUID().uuidString.replacingOccurrences(of: "-", with: "")
        let callbackUrl = "minimalApp://"
        let authorizationUrl = URL(string: "https://www.reddit.com/api/v1/authorize.compact?client_id=t6Z4BZyV3a06eA&response_type=code&state=\(randomString)&redirect_uri=minimalApp://minimalApp.com&duration=permanent&scope=identity,vote,read,subscribe,mysubreddits")!
        //Initialize auth session
        authSession = SFAuthenticationSession(url: authorizationUrl, callbackURLScheme: callbackUrl, completionHandler: completionHandler)
        return authSession
    }
}

protocol AuthenticationDelegate: class {
    func authenticated(results: (url: URL?, error: Error?))
}

extension APIManager: AuthenticationDelegate {
    func authenticated(results: (url: URL?, error: Error?)) {
        if let error = results.error {
            print(error)
            return
        } else if let successURL = results.url {
            let queryItems = URLComponents(string: successURL.absoluteString)?.queryItems
            print(queryItems as Any)
        }
    }
}

