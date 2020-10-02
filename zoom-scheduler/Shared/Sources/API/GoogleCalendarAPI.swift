//
//  GoogleCalendarAPI.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 1.10.2020.
//

import AppAuth
import Foundation
import GTMAppAuth

public enum GoogleAuthState {
    case notConnected
    case connecting
    case failed
    case connected
}

struct GCalendar {
    let name: String
    let identifier: String
}

class GoogleCalendarAPI: NSObject, ObservableObject, OIDExternalUserAgent {
    @Published var authState: GoogleAuthState = .notConnected
    @Published var calendars: [GCalendar] = []

    var authFlow: OIDExternalUserAgentSession?
    var auth: GTMAppAuthFetcherAuthorization? {
        didSet {
            guard let auth = self.auth else {
                GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: GoogleCalendarAPI.keychainTokenKey)
                self.authState = .notConnected
                return
            }

            if auth.canAuthorize() {
                GTMAppAuthFetcherAuthorization.save(auth, toKeychainForName: GoogleCalendarAPI.keychainTokenKey)
                self.authState = .connected
            } else {
                GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: GoogleCalendarAPI.keychainTokenKey)
                self.authState = .notConnected
            }
        }
    }

    let fetcherService = GTMSessionFetcherService()

    static let clientID = "926865165137-kmdns9cjc1u67tq1l0eb3olbbemk18he.apps.googleusercontent.com"
    static let clientSecret = "nWwiFQZVZKkC3viItNnAD1me"
    static let redirectURL = "com.googleusercontent.apps.926865165137-kmdns9cjc1u67tq1l0eb3olbbemk18he:/oauthredirect"
    static let keychainTokenKey = "GoogleAuthAccessToken"
    static let scopes = ["https://www.googleapis.com/auth/calendar.readonly", "https://www.googleapis.com/auth/calendar.events"]

    override init() {
        super.init()

        if let auth = GTMAppAuthFetcherAuthorization(fromKeychainForName: GoogleCalendarAPI.keychainTokenKey) {
            self.auth = auth

            if auth.canAuthorize() {
                self.authState = .connected
            } else {
                self.authState = .notConnected
            }

            if self.authState == .connected {
                self.loadCalendars()
            }
        }
    }

    public func revokeSession() {
        self.auth = nil
    }

    public func authenticateGoogleSession() {
        guard let redirectURL = URL(string: GoogleCalendarAPI.redirectURL) else {
            return
        }

        self.authState = .connecting

        let configuration = GTMAppAuthFetcherAuthorization.configurationForGoogle()
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: GoogleCalendarAPI.clientID,
                                              clientSecret: GoogleCalendarAPI.clientSecret,
                                              scopes: GoogleCalendarAPI.scopes,
                                              redirectURL: redirectURL,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: nil)

        let authFlow = OIDAuthState.authState(byPresenting: request, externalUserAgent: self, callback: { (state, error) in
            guard error == nil else {
                self.authState = .failed
                return
            }

            if let state = state {
                self.auth = GTMAppAuthFetcherAuthorization(authState: state)

                self.loadCalendars()
            } else {
                self.authState = .failed
                return
            }
        })

        self.authFlow = authFlow
    }

    private func loadCalendars() {
        guard let auth = self.auth else {
            return
        }

        fetcherService.authorizer = auth

        guard let url = URL(string: "https://www.googleapis.com/calendar/v3/users/me/calendarList") else {
            return
        }

        let fetcher = fetcherService.fetcher(with: url)

        fetcher.beginFetch { (response: Data?, error: Error?) in
            guard error == nil, let response = response else {
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(
                    with: response,
                    options: .mutableContainers) as? [String: Any] {

                    guard let items = json["items"] as? [[String: Any]] else {
                        return
                    }

                    print(json)

                    DispatchQueue.main.async {
                        self.calendars.removeAll()

                        for item in items {
                            guard let identifier = item["id"] as? String,
                                  let name = item["summary"] as? String else {
                                continue
                            }

                            self.calendars.append(GCalendar(name: name, identifier: identifier))
                        }

                        print("Load complete \(self.calendars)")
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    public func createEvent(meeting: ZoomMeeting, attendeeEmails: [String], inCalendar calendar: GCalendar) {
        guard let auth = self.auth else {
            return
        }

        fetcherService.authorizer = auth

        guard let url = URL(string: "https://www.googleapis.com/calendar/v3/calendars/\(calendar.identifier)/events") else {
            return
        }

        let dateFormatter = DateFormatter()

        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // 2019-09-05T16:54:14Z

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        var attendees: [[String:Any]] = []

        for email in attendeeEmails {
            attendees.append(["email": email])
        }

        var payload: [String: Any] = [:]

        if let title = meeting.title {
            payload["summary"] = title
        }
        if let joinUrl = meeting.joinUrl {
            payload["description"] = joinUrl.absoluteString
            payload["location"] = joinUrl.absoluteString
        }
        if let startDate = meeting.startDate {
            payload["start"] = [
                "dateTime": dateFormatter.string(from: startDate)
            ]
        }
        if let endDate = meeting.endDate {
            payload["end"] = [
                "dateTime": dateFormatter.string(from: endDate)
            ]
        }
        if !attendees.isEmpty {
            payload["attendees"] = attendees
        }

        guard let payloadData = try? JSONSerialization.data(withJSONObject: payload) else {
            return
        }

        request.httpBody = payloadData
        request.setValue("application/json", forHTTPHeaderField: "Content-type")

        let fetcher = fetcherService.fetcher(with: request)

        fetcher.beginFetch { (response: Data?, error: Error?) in
            guard error == nil, let response = response else {
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(
                    with: response,
                    options: .mutableContainers) as? [String: Any] {

                    print(json)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    func present(_ request: OIDExternalUserAgentRequest, session: OIDExternalUserAgentSession) -> Bool {
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
