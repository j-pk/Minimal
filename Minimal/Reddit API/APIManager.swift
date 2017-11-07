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

class APIManager {
    
    static let `default` = APIManager()
    
    func fetchListing(forUrl url: URL, completionHandler: @escaping ((NetworkError?, [ListingMapped]?)->())) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
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
                    let root = try decoder.decode(ListingRoot.self, from: data)
                    let listings = root.listings.map({ listingData in ListingMapped(root: root, data: listingData) })
                    completionHandler(nil, listings)
                } catch let error as NSError {
                    completionHandler(NetworkError.failedToParse(description: error.debugDescription), nil)
                }
            }
        }
        task.resume()
    }
    
}
