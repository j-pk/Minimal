//
//  RequestAuthorization.swift
//  Minimal
//
//  Created by Jameson Parker Kirby on 3/16/18.
//  Copyright © 2018 Parker Kirby. All rights reserved.
//

import Foundation

class RequestAuthorization {
    var networkEngine: NetworkEngine = NetworkManager()
    
    @discardableResult init(withCode code: String?, state: String?) {
        guard let code = code, let state = state else { return }
        let request = AuthorizationRequest(requestType: .authorize(code: code, state: state))
        networkEngine.session(forRoute: request.router, withDecodable: AuthorizationObject.self) { (error, authorizationObject) in
            if let error = error {
                posLog(error: error)
            } else if let object = authorizationObject {
                if var defaults = Defaults.retrieve() {
                    defaults.accessToken = object.accessToken
                    defaults.refreshToken = object.refreshToken
                    defaults.expiry = Calendar.current.date(byAdding: .second, value: object.expiresIn, to: Date())
                    defaults.lastAuthenticated = Date()
                    defaults.id = state
                    defaults.store()
                }
                posLog(values: object)
            } else {
                posLog(error: error)
            }
        }
    }
}

class RefreshToken {
    var networkEngine: NetworkEngine = NetworkManager()

    @discardableResult init(completionHandler: @escaping OptionalErrorHandler) {
        guard var defaults = Defaults.retrieve(), let token = defaults.refreshToken else { completionHandler(NetworkError.generatedURLRequestFailed); return  }
        let request = AuthorizationRequest(requestType: .refresh(token: token))
        networkEngine.session(forRoute: request.router, withDecodable: AuthorizationObject.self) { (error, authorizationObject) in
            if let error = error {
                completionHandler(error)
            } else if let object = authorizationObject {
                defaults.accessToken = object.accessToken
                defaults.expiry = Calendar.current.date(byAdding: .second, value: object.expiresIn, to: Date())
                defaults.lastAuthenticated = Date()
                defaults.store()
                posLog(values: object)
            } else {
                completionHandler(NetworkError.serverError(description: "No data for \(String(describing: request.router.urlRequest))"))
            }
        }
    }
}
