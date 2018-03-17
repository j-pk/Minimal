//
//  RequestAuthorizer.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 3/16/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

class RequestAuthorizer {
    var networkEngine: NetworkEngine = NetworkManager()
    
    @discardableResult init(withCode code: String?, state: String?, completionHandler: @escaping OptionalErrorHandler) {
        guard let code = code, let state = state else { completionHandler(NetworkError.generatedURLRequestFailed); return  }
        let request = AuthorizationRequest(code: code, state: state)
        networkEngine.session(forRoute: request.router, withDecodable: AuthorizationObject.self) { (error, authorizationObject) in
            if let error = error {
                completionHandler(error)
            }
            if let object = authorizationObject {
                posLog(values: object)
            } else {
                completionHandler(error)
            }
        }
    }
}
