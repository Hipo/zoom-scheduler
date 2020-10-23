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

    deinit {
        removeListener(self)
    }
}

extension ZoomAPI {
    func requestAuthorization(_ draft: RequestAuthorizationDraft) {
        switch draft.method {
            case .oauth:
                session.authorizationMethod = .oauth
                requestOauthAuthorization()
            case .jwt:
                session.authorizationMethod = .jwt
                requestJwtAuthorization(draft.jwt)
        }
    }

    func completeAuthorization(_ draft: CompleteAuthorizationDraft) {
        switch session.authorizationMethod {
            case .oauth:
                requestAccessToken(draft.oauth)
            case .jwt:
                break
        }
    }

    func refreshAuthorizationIfNeeded(
        _ draft: RefreshAuthorizationDraft = RefreshAuthorizationDraft()
    ) {
        switch session.status {
            case .authorized(let credentials):
                if credentials.isExpired {
                    refreshAuthorization(draft)
                }
            case .unauthorized:
                if session.credentials != nil {
                    refreshAuthorization(draft)
                }
            default:
                break
        }
    }

    func refreshAuthorization(_ draft: RefreshAuthorizationDraft = RefreshAuthorizationDraft()) {
        switch session.authorizationMethod {
            case .oauth:
                refreshOauthAuthorization(draft.oauth)
            case .jwt:
                break
        }
    }

    func revokeAuthorization(_ draft: RevokeAuthorizationDraft = RevokeAuthorizationDraft()) {
        switch session.authorizationMethod {
            case .oauth:
                revokeAccessToken(draft.oauth)
            case .jwt:
                revokeJwtAuthorization(afterSessionDidUnauthorize: false)
        }
    }
}

extension ZoomAPI {
    private func requestOauthAuthorization() {
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

        NSApplication.shared.openSafari(components?.url)
    }

    private func refreshOauthAuthorization(
        _ draft: RefreshAccessTokenDraft = RefreshAccessTokenDraft()
    ) {
        session.status = .unauthorized(.sessionExpired)
        refreshAccessToken(draft)
    }

    @discardableResult
    private func requestAccessToken(_ draft: RequestAccessTokenDraft) -> EndpointOperatable {
        session.status = .connecting

        var aDraft = draft
        aDraft.config = config

        let completionHandler: AccessTokenCompletionHandler = { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let credentials):
                    self.session.status = .authorized(credentials)
                case .failure(let apiError, let apiErrorDetail):
                    let error = ZoomAPIError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                    self.session.status = .none(error)
            }
        }

        return EndpointBuilder(api: self)
            .base(config.oauthBase)
            .path("/token")
            .method(.post)
            .query(aDraft)
            .completionHandler(completionHandler)
            .build()
            .send()
    }

    @discardableResult
    private func refreshAccessToken(_ draft: RefreshAccessTokenDraft) -> EndpointOperatable {
        session.status = .refreshing

        var aDraft = draft
        aDraft.token = (session.credentials as? Session.Credentials)?.refreshToken

        let completionHandler: AccessTokenCompletionHandler = { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let credentials):
                    self.session.status = .authorized(credentials)
                case .failure:
                    if aDraft.retryCount < 6 {
                        aDraft.retryCount += 1
                        self.refreshAccessToken(aDraft)
                        return
                    }
                    self.session.status = .none(.sessionCancelled)
            }
        }

        return EndpointBuilder(api: self)
            .base(config.oauthBase)
            .path("/token")
            .method(.post)
            .query(aDraft)
            .completionHandler(completionHandler)
            .build()
            .send()
    }

    @discardableResult
    private func revokeAccessToken(_ draft: RevokeAccessTokenDraft) -> EndpointOperatable {
        session.status = .disconnecting

        cancelEndpoints()

        var aDraft = draft
        aDraft.token = (session.credentials as? Session.Credentials)?.accessToken

        let completionHandler: (Response.ErrorModelResult<ZoomAPIError.Detail>) -> Void
            = { [weak self] result in
                guard let self = self else { return }

                switch result {
                    case .success:
                        self.session.status = .none()
                    case .failure(let apiError, let apiErrorDetail):
                        let error = ZoomAPIError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                        self.session.status = .unauthorized(error)
                }
            }

        return EndpointBuilder(api: self)
            .base(config.oauthBase)
            .path("/revoke")
            .method(.post)
            .query(aDraft)
            .completionHandler(completionHandler)
            .build()
            .send()
    }
}

extension ZoomAPI {
    private func requestJwtAuthorization(_ draft: RequestJWTAuthorizationDraft) {
        let credentials = Session.JWTCredentials(apiKey: draft.apiKey, apiSecret: draft.apiSecret)
        session.status = .authorized(credentials)
    }

    private func revokeJwtAuthorization(afterSessionDidUnauthorize: Bool) {
        session.status = .none(afterSessionDidUnauthorize ? .sessionCancelled : nil)
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
        switch session.authorizationMethod {
            case .oauth:
                refreshOauthAuthorization()
            case .jwt:
                revokeJwtAuthorization(afterSessionDidUnauthorize: true)
        }
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
