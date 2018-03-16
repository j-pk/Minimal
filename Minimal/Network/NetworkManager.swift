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
typealias DecodableCompletionHandler = (NetworkError?, [Decodable]?) -> Void
typealias NetworkCompletionHandler<T> = (NetworkError?, T?) -> Void

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

protocol Networkable {
    var networkEngine: NetworkEngine { get }
}

protocol NetworkEngine {
    func session<T>(forRoute route: Routable, withDecodable decodable: T.Type, completionHandler: @escaping NetworkCompletionHandler<T>) where T: Decodable
}

class NetworkManager: NetworkEngine {
    private let defaultSession = URLSession(configuration: .default)
    private var task: URLSessionDataTask?
    var results: (url: URL?, error: Error?) {
        didSet {
            self.authenticated(results: results)
        }
    }

    func session<T>(forRoute route: Routable, withDecodable decodable: T.Type, completionHandler: @escaping NetworkCompletionHandler<T>) where T: Decodable  {
        guard let request = route.urlRequest else { return }
        task = defaultSession.dataTask(with: request) { (data, urlResponse, error) in
            posLog(message: "Network Request: \(request.description)", category: String(describing: self))
            
            if let error = error {
                completionHandler(NetworkError.serverError(description: error.localizedDescription), nil)
            }
            
            guard let response = urlResponse as? HTTPURLResponse, response.statusCode == 200 else {
                completionHandler(NetworkError.responseError(response: urlResponse), nil)
                return
            }
            
            posLog(message: "Network Request: \(response.statusCode)", category: String(describing: self))

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
    
    /// OAuth with Reddit using SFAuthenticationSession
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
    
    func authenticated(results: (url: URL?, error: Error?)) {
        if let error = results.error {
            posLog(error: error)
            return
        } else if let successURL = results.url {
            let queryItems = URLComponents(string: successURL.absoluteString)?.queryItems
            let state = queryItems?.filter({ $0.name == "state" }).first
            let code = queryItems?.filter({ $0.name == "code" }).first
            authorizeAccess(withCode: code?.value, state: state?.value)
            posLog(optionals: queryItems)
        }
    }
    
    func authorizeAccess(withCode code: String?, state: String?) {
        guard let code = code, let state = state, let url = URL(string: "https://ssl.reddit.com/api/v1/access_token") else { return }
        guard let data = String(format: "%@:%@", "mtOhKTWpoebjUg", "").data(using: .utf8) else { return }
        let credentials = data.base64EncodedString(options: [])
        let parameters = [
            "grant_type": "authorization_code",
            "state": state,
            "code": code,
            "redirect_uri": "minimalApp://minimalApp.com"
        ]
        var components = URLComponents()
        components.queryItems = parameters.map{ URLQueryItem(name: $0, value: $1) }
        guard let encodedParameters = components.string?.dropFirst().data(using: .utf8, allowLossyConversion: false) else { return }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        request.httpBody = encodedParameters
        
        
        
        task = defaultSession.dataTask(with: request as URLRequest) { (data, urlResponse, error) in
            posLog(message: "Network Request: \(request.description)", category: String(describing: self))
            
            if let error = error {
                posLog(error: error)
            }
            
            guard let response = urlResponse as? HTTPURLResponse, response.statusCode == 200 else {
                posLog(error: NetworkError.responseError(response: urlResponse))
                return
            }
            
            posLog(message: "Network Request: \(response.statusCode)", category: String(describing: self))
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    posLog(values: json)
                } catch let error {
                    posLog(error: error)
                }
            }
        }
        task?.resume()
    }
}

