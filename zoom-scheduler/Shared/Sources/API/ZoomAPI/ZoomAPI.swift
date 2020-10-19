//
//  ZoomAPIV2.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 3.10.2020.
//

import Combine
import Foundation
import Magpie

final class ZoomAPI: API {
    typealias QueryParam = ObjectQueryKeyedParam<ZoomAPIRequestParameter>
    typealias BodyParam = JSONBodyKeyedParam<ZoomAPIRequestParameter>

    typealias AccessTokenCompletionHandler =
        (Response.Result<Session.Credentials, ZoomAPIError.Detail>) -> Void

    let config: ZoomConfig
    let session: Session

    init(
        config: ZoomConfig,
        session: Session
    ) {
        self.config = config
        self.session = session

        super.init(
            base: "https://api.zoom.us/v2",
            networking: AlamofireNetworking(),
            interceptor: ZoomAPIInterceptor(
                config: config,
                session: session
            )
        )

        addListener(self)

        #if DEBUG
        enableLogsInConsole()
        #else
        disableLogsInConsole()
        #endif
    }

    required init(
        base: String,
        networking: Networking,
        interceptor: APIInterceptor? = nil,
        networkMonitor: NetworkMonitor? = nil
    ) {
        fatalError("init(base:networking:interceptor:networkMonitor:) has not been implemented")
    }

    deinit {
        removeListener(self)
    }
}

extension ZoomAPI {
    func requestAuthorization() {
        var components = URLComponents(string: config.oauthAuthorizeUrl)
        components?.queryItems = [
            URLQueryItem(
                name: ZoomAPIRequestParameter.responseType.rawValue,
                value: ZoomAPIRequestParameterValue.responseType.rawValue
            ),
            URLQueryItem(name: ZoomAPIRequestParameter.clientId.rawValue, value: config.clientId),
            URLQueryItem(
                name: ZoomAPIRequestParameter.redirectUri.rawValue,
                value: config.redirectUri
            )
        ]

        if let url = components?.url {
            NSWorkspace.shared.open(url)
        }
    }
}

extension ZoomAPI {
    @discardableResult
    func requestAccessToken(
        _ draft: RequestAccessTokenDraft,
        onCompleted completionHandler: AccessTokenCompletionHandler? = nil
    ) -> EndpointOperatable {
        session.status = .connecting

        var aDraft = draft
        aDraft.config = config

        let aCompletionHandler: AccessTokenCompletionHandler = { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let credentials):
                    self.session.status = .authorized(credentials)
                case .failure(let apiError, let apiErrorDetail):
                    let error = ZoomAPIError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                    self.session.status = .none(error)
            }

            completionHandler?(result)
        }

        return EndpointBuilder(api: self)
            .base(config.oauthBase)
            .path("/token")
            .method(.post)
            .query(aDraft)
            .completionHandler(aCompletionHandler)
            .build()
            .send()
    }

    @discardableResult
    func refreshAccessToken(
        _ draft: RefreshAccessTokenDraft = RefreshAccessTokenDraft(),
        onCompleted completionHandler: AccessTokenCompletionHandler? = nil
    ) -> EndpointOperatable {
        session.status = .refreshing

        var aDraft = draft
        aDraft.token = session.credentials?.refreshToken

        let aCompletionHandler: AccessTokenCompletionHandler = { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let credentials):
                    self.session.status = .authorized(credentials)
                    completionHandler?(result)
                case .failure:
                    if aDraft.retryCount < 6 {
                        aDraft.retryCount += 1
                        self.refreshAccessToken(aDraft, onCompleted: completionHandler)
                        return
                    }
                    self.session.status = .none(.sessionCancelled)
                    completionHandler?(result)
            }
        }

        return EndpointBuilder(api: self)
            .base(config.oauthBase)
            .path("/token")
            .method(.post)
            .query(aDraft)
            .completionHandler(aCompletionHandler)
            .build()
            .send()
    }

    @discardableResult
    func revokeAccessToken(
        _ draft: RevokeAccessTokenDraft = RevokeAccessTokenDraft(),
        onCompleted completionHandler: ((Response.ErrorModelResult<ZoomAPIError.Detail>) -> Void)? = nil
    ) -> EndpointOperatable {
        cancelEndpoints()

        var aDraft = draft
        aDraft.token = session.credentials?.accessToken

        let aCompletionHandler: (Response.ErrorModelResult<ZoomAPIError.Detail>) -> Void
            = { [weak self] result in
                guard let self = self else { return }

                switch result {
                    case .success:
                        self.session.status = .none()
                    case .failure(let apiError, let apiErrorDetail):
                        let error = ZoomAPIError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                        self.session.status = .unauthorized(error)
                }

                completionHandler?(result)
            }

        return EndpointBuilder(api: self)
            .base(config.oauthBase)
            .path("/revoke")
            .method(.post)
            .query(aDraft)
            .completionHandler(aCompletionHandler)
            .build()
            .send()
    }
}

extension ZoomAPI {
    @discardableResult
    func createMeeting(
        _ draft: CreateMeetingDraft,
        onCompleted completionHandler: @escaping (Response.Result<ZoomMeeting, ZoomAPIError.Detail>) -> Void
    ) -> EndpointOperatable {
        return EndpointBuilder(api: self)
            .path("/users/me/meetings")
            .method(.post)
            .body(draft)
            .completionHandler(completionHandler)
            .build()
            .send()
    }
}

extension ZoomAPI: APIListener {
    func api(_ api: API, endpointDidFailFromUnauthorizedRequest endpoint: EndpointOperatable) {
        session.status = .unauthorized(.sessionExpired)
        refreshAccessToken()
    }
}

enum ZoomAPIRequestParameter: String, CodingKey {
    case clientId = "client_id"
    case code
    case duration
    case grantType = "grant_type"
    case password
    case redirectUri = "redirect_uri"
    case refreshToken = "refresh_token"
    case responseType = "response_type"
    case startTime = "start_time"
    case timezone
    case token
    case topic
    case type
}

enum ZoomAPIRequestParameterValue: String {
    case responseType = "code"
}
