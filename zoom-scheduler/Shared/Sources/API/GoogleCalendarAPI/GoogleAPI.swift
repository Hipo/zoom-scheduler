//
//  GoogleAPI.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 14.10.2020.
//

import AppAuth
import Foundation
import GTMAppAuth
import Magpie

final class GoogleAPI: NSObject {
    typealias QueryParam = ObjectQueryKeyedParam<GoogleAPIRequestParameter>
    typealias BodyParam = JSONBodyKeyedParam<GoogleAPIRequestParameter>

    let config: GoogleConfig
    let session: Session

    private var authenticator: OIDExternalUserAgentSession?

    private lazy var service = GTMSessionFetcherService()

    private let base = "https://www.googleapis.com"

    init(
        config: GoogleConfig,
        session: Session
    ) {
        self.config = config
        self.session = session

        super.init()

        if session.isGoogleAccountAuthorized {
            loadCalendars()
        }
    }
}

extension GoogleAPI {
    func requestAuthorization() {
        guard let redirectUrl = config.redirectUrl else {
            session.googleAuthorizationStatus = .unauthorized()
            return
        }

        let configuration = GTMAppAuthFetcherAuthorization.configurationForGoogle()
        let request = OIDAuthorizationRequest(
            configuration: configuration,
            clientId: config.clientId,
            clientSecret: config.clientSecret,
            scopes: config.scopes,
            redirectURL: redirectUrl,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil
        )

        authenticator = OIDAuthState.authState(
            byPresenting: request,
            externalUserAgent: self
        ) { [weak self] state, error in
            guard let self = self else { return }

            guard let state = state else {
                self.session.googleAuthorizationStatus = .unauthorized(error as NSError?)
                return
            }

            let credentials = GTMAppAuthFetcherAuthorization(authState: state)

            self.session.googleAuthorizationStatus = .authorized(credentials)
            self.loadCalendars()
        }
    }

    func completeAuthorization(redirectUrl: URL) {
        authenticator?.resumeExternalUserAgentFlow(with: redirectUrl)
    }

    func revokeAuthorization() {
        service.stopAllFetchers()
        session.googleAuthorizationStatus = .unauthorized()
    }
}

extension GoogleAPI {
    /// <note> Calendars are accessible from session.
    func loadCalendars(onCompleted completionHandler: ((Error?) -> Void)? = nil) {
        guard let url = URL(string: "\(base)/calendar/v3/users/me/calendarList") else {
            return
        }

        /// <todo> I don't know credentials are modifiable by the framework time to time, so it is being set to be sure.
        service.authorizer = session.googleAuthorizationCredentials

        let fetcher = service.fetcher(with: url)
        fetcher.beginFetch { [weak self] data, error in
            guard let self = self else { return }

            if let error = error {
                completionHandler?(error)
                return
            }

            guard let data = data else {
                self.session.googleCalendars = []

                completionHandler?(nil)
                return
            }

            do {
                let calendarList = try GoogleCalendarList.decoded(data)
                self.session.googleCalendars = calendarList.calendars

                completionHandler?(nil)
            } catch let serializationError {
                completionHandler?(serializationError)
            }
        }
    }
}

extension GoogleAPI {
    func createEvent(_ draft: CreateEventDraft, onCompleted completionHandler: @escaping (Error?) -> Void) {
        let request = Request(base: base, cachePolicy: .reloadIgnoringCacheData, timeout: 60)
        request.path = "/calendar/v3/calendars/\(draft.calendar?.id ?? "")/events"
        request.method = .post
        request.body = draft
        request.headers = [ AcceptHeader.json() ]

        /// <todo> I don't know credentials are modifiable by the framework time to time, so it is being set to be sure.
        service.authorizer = session.googleAuthorizationCredentials

        guard let urlRequest = try? request.asUrlRequest() else {
            return
        }

        let fetcher = service.fetcher(with: urlRequest)
        fetcher.beginFetch { _, error in
            completionHandler(error)
        }
    }
}

extension GoogleAPI: OIDExternalUserAgent {
    func present(
        _ request: OIDExternalUserAgentRequest,
        session: OIDExternalUserAgentSession
    ) -> Bool {
        guard let url = request.externalUserAgentRequestURL() else {
            return false
        }
        NSWorkspace.shared.open(url)
        return true
    }

    func dismiss(animated: Bool, completion: @escaping () -> Void) {
        completion()
    }
}

enum GoogleAPIRequestParameter: String, CodingKey {
    case attendees
    case dateTime
    case description
    case email
    case end
    case location
    case start
    case summary
    case timeZone
}
