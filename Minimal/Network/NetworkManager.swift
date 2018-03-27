//
//  NetworkManager.swift
//  Minimal
//
//  Created by Jameson Kirby on 10/23/17.
//  Copyright © 2017 Parker Kirby. All rights reserved.
//

import Foundation
import SafariServices

typealias OptionalErrorHandler = (Error?) -> Void
typealias DecodableCompletionHandler = (Error?, [Decodable]?) -> Void
typealias ResultCompletionHandler<T> = (Result<T>) -> Void

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

public enum NetworkError: Error {
    case failedToParse(Error)
    case responseError(response: URLResponse?)
    case serverError(description: String)
    case generatedURLRequestFailed
}

public enum Result<T> {
    case success(T)
    case failure(Error)
}

protocol Networkable {
    var networkEngine: NetworkEngine { get }
}

protocol NetworkEngine {
    func session<T>(forRoute route: Routable, withDecodable decodable: T.Type, completionHandler: @escaping ResultCompletionHandler<T>) where T: Decodable
}

class NetworkManager: NetworkEngine {
    private let defaultSession = URLSession(configuration: .default)
    private var task: URLSessionDataTask?
    var results: (url: URL?, error: Error?) {
        didSet {
            self.authenticated(results: results)
        }
    }

    func session<T>(forRoute route: Routable, withDecodable decodable: T.Type, completionHandler: @escaping ResultCompletionHandler<T>) where T: Decodable  {
        guard let request = route.urlRequest else { return }
        task = defaultSession.dataTask(with: request) { (data, urlResponse, error) in
            posLog(message: "Network Request: \(request.description)", category: String(describing: self))
            
            if let error = error {
                completionHandler(.failure(NetworkError.serverError(description: error.localizedDescription)))
            }
            
            guard let response = urlResponse as? HTTPURLResponse else {
                completionHandler(.failure(NetworkError.responseError(response: urlResponse)))
                return
            }
            
            posLog(message: "Network Request: \(response.statusCode)", category: String(describing: self))
            
            if response.statusCode == 401 {
                RefreshToken { (error) in
                    if let error = error {
                        completionHandler(.failure(NetworkError.serverError(description: error.localizedDescription)))
                    } else {
                        self.session(forRoute: route, withDecodable: decodable, completionHandler: completionHandler)
                    }
                }
            } else if response.statusCode == 200, let data = data {
                let decoder = JSONDecoder()
                do {
                    let decoded = try decoder.decode(T.self, from: data)
                    completionHandler(.success(decoded))
                } catch let error {
                    completionHandler(.failure(NetworkError.failedToParse(error)))
                }
            } else  {
                completionHandler(.failure(NetworkError.serverError(description: "Server Error: \(response)")))
            }
        }
        task?.resume()
    }
    
    func retry(attempts: Int, request: URLRequest, completionHandler: @escaping OptionalErrorHandler) {
        
    }
    
    /// OAuth Phase 1 with Reddit using SFAuthenticationSession
    /// Connects Minimal with user's Reddit account
    ///
    /// - Parameter completionHandler: CompletionHandler to process authentication results
    /// - Returns: SFAuthentication is configured in Network Manager but needs to launch `start()` from SettingsViewController
    func requestAuthentication(completionHandler: @escaping (URL?, Error?) -> Swift.Void) -> SFAuthenticationSession? {
        var authSession: SFAuthenticationSession?
        let randomString = NSUUID().uuidString.replacingOccurrences(of: "-", with: "")
        let callbackUrl = "minimalApp://"
        let authorizationUrl = URL(string: "https://www.reddit.com/api/v1/authorize.compact?client_id=mtOhKTWpoebjUg&response_type=code&state=\(randomString)&redirect_uri=minimalApp://minimalApp.com&duration=permanent&scope=identity,vote,read,subscribe,mysubreddits")!
        authSession = SFAuthenticationSession(url: authorizationUrl, callbackURLScheme: callbackUrl, completionHandler: completionHandler)
        return authSession
    }
    
    /// OAuth Phase 2 with Reddit using RequestAuthorization
    /// Acquires tokens
    func authenticated(results: (url: URL?, error: Error?)) {
        if let error = results.error {
            posLog(error: error)
            return
        } else if let successURL = results.url {
            let queryItems = URLComponents(string: successURL.absoluteString)?.queryItems
            let state = queryItems?.filter({ $0.name == "state" }).first
            let code = queryItems?.filter({ $0.name == "code" }).first
            RequestAuthorization(withCode: code?.value, state: state?.value)
            posLog(optionals: queryItems)
        }
    }
}

