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
}

protocol Modelable {
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
    
    /// OAuth with Reddit using SFAuthenticationSession
    ///
    /// - Parameter completionHandler: CompletionHandler to process authentication results
    /// - Returns: SFAuthentication is configured in Network Manager but needs to launch `start()` from SettingsViewController
    func requestAuthentication(completionHandler: @escaping (URL?, Error?) -> Swift.Void) -> SFAuthenticationSession? {
        var authSession: SFAuthenticationSession?
        let randomString = NSUUID().uuidString.replacingOccurrences(of: "-", with: "")
        let callbackUrl = "minimalApp://"
        let authorizationUrl = URL(string: "https://www.reddit.com/api/v1/authorize.compact?client_id=t6Z4BZyV3a06eA&response_type=code&state=\(randomString)&redirect_uri=minimalApp://minimalApp.com&duration=permanent&scope=identity,vote,read,subscribe,mysubreddits")!
        authSession = SFAuthenticationSession(url: authorizationUrl, callbackURLScheme: callbackUrl, completionHandler: completionHandler)
        return authSession
    }
    
    func authenticated(results: (url: URL?, error: Error?)) {
        if let error = results.error {
            print(error)
            return
        } else if let successURL = results.url {
            let queryItems = URLComponents(string: successURL.absoluteString)?.queryItems
            let authorizationKey = queryItems?.filter({ $0.name == "code" }).first
            UserDefaults.standard.setValue(authorizationKey?.value, forKey: UserSettingsDefaultKey.authorizationKey)
            print(queryItems as Any)
        }
    }
}

