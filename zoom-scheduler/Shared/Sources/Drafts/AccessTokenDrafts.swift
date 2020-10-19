//
//  AccessTokenDrafts.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 14.10.2020.
//

import Foundation
import Magpie

struct RequestAccessTokenDraft: ObjectQuery {
    var authorizationCode: String?
    var config: ZoomConfig?

    var queryParams: [ZoomAPI.QueryParam] {
        var params: [ZoomAPI.QueryParam] = []
        params.append(.init(.grantType, "authorization_code"))
        params.append(.init(.code, authorizationCode))
        params.append(.init(.redirectUri, config?.redirectUri))
        return params
    }
}

struct RefreshAccessTokenDraft: ObjectQuery {
    var token: String?
    var retryCount = 0

    var queryParams: [ZoomAPI.QueryParam] {
        var params: [ZoomAPI.QueryParam] = []
        params.append(.init(.grantType, "refresh_token"))
        params.append(.init(.refreshToken, token))
        return params
    }
}

struct RevokeAccessTokenDraft: ObjectQuery {
    var token: String?

    var queryParams: [ZoomAPI.QueryParam] {
        var params: [ZoomAPI.QueryParam] = []
        params.append(.init(.token, token))
        return params
    }
}
