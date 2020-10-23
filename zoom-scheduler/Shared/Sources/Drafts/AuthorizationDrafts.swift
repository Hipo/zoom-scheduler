//
//  AuthorizationDrafts.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 23.10.2020.
//

import Foundation

struct RequestAuthorizationDraft {
    typealias Method = Session.AuthorizationMethod

    var method: Method
    var jwt = RequestJWTAuthorizationDraft()

    var isValid: Bool {
        switch method {
            case .oauth:
                return true
            case .jwt:
                return jwt.isValid
        }
    }

    init(method: Method) {
        self.method = method
    }
}

struct CompleteAuthorizationDraft {
    var oauth = RequestAccessTokenDraft()
}

struct RefreshAuthorizationDraft {
    var oauth = RefreshAccessTokenDraft()
}

struct RevokeAuthorizationDraft {
    var oauth = RevokeAccessTokenDraft()
}

struct RequestJWTAuthorizationDraft {
    var apiKey = ""
    var apiSecret = ""

    var isValid: Bool {
        return !apiKey.isEmpty && !apiSecret.isEmpty
    }
}
