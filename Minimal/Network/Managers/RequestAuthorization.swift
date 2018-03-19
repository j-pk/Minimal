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
        networkEngine.session(forRoute: request.router, withDecodable: AuthorizationObject.self) { (result) in
            switch result {
            case .failure(let error):
                posLog(error: error)
            case .success(let authorizationObject):
                if var defaults = Defaults.retrieve() {
                    defaults.accessToken = authorizationObject.accessToken
                    defaults.refreshToken = authorizationObject.refreshToken
                    defaults.expiry = Calendar.current.date(byAdding: .second, value: authorizationObject.expiresIn, to: Date())
                    defaults.lastAuthenticated = Date()
                    defaults.id = state
                    defaults.store()
                }
                posLog(values: authorizationObject)
            }
        }
    }
}

class RefreshToken {
    var networkEngine: NetworkEngine = NetworkManager()

    @discardableResult init(completionHandler: @escaping OptionalErrorHandler) {
        guard var defaults = Defaults.retrieve(), let token = defaults.refreshToken else { completionHandler(NetworkError.generatedURLRequestFailed); return  }
        let request = AuthorizationRequest(requestType: .refresh(token: token))
        networkEngine.session(forRoute: request.router, withDecodable: AuthorizationObject.self) { (result) in
            switch result {
            case .failure(let error):
                completionHandler(error)
            case .success(let authorizationObject):
                defaults.accessToken = authorizationObject.accessToken
                defaults.expiry = Calendar.current.date(byAdding: .second, value: authorizationObject.expiresIn, to: Date())
                defaults.lastAuthenticated = Date()
                defaults.store()
                posLog(values: authorizationObject)
            }
        }
    }
}
