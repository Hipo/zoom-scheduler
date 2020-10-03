//
//  ZoomAPI.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 1.10.2020.
//

import AppKit
import Foundation

public enum ZoomAuthState {
    case notConnected
    case connecting
    case failed
    case success
}

struct ZoomMeeting: Codable {
    let title: String?
    let startTime: Date?
    let duration: Int?
    let timezone: String?
    let joinUrl: URL?

    var endTime: Date? {
        get {
            if let duration = duration {
                return startTime?.addingTimeInterval(TimeInterval(duration * 60))
            }
            return nil
        }
    }
}
class ZoomAPI: ObservableObject {
    @Published var authState: ZoomAuthState = .notConnected

    var accessToken: String?
    var refreshToken: String? {
        didSet {
            if self.refreshToken == nil {
                UserDefaults.standard.removeObject(forKey: "zoomRefreshToken")
            } else {
                UserDefaults.standard.setValue(refreshToken, forKey: "zoomRefreshToken")
            }

            UserDefaults.standard.synchronize()
        }
    }

    var authCode: String? {
        didSet {
            self.authState = .connecting
            self.fetchAccessToken()
        }
    }

    var lastCreatedMeeting: ZoomMeeting?

    // DEVELOPMENT
    //    static let zoomClientID = "o7skHzvfQTu4CaeRLJIfTQ"
    //    static let zoomRedirectURI = "https://zoomscheduler.ngrok.io/oauth"
    //    static let zoomAuthHeader = "bzdza0h6dmZRVHU0Q2FlUkxKSWZUUTpLMWtOQkRtU1dDN05JdEhySXllNHc2Q2hJNE9hbGlpdA=="

    // PRODUCTION
    static let zoomClientID = "gpoWkKXrQkuPoK6xGCCjmw"
    static let zoomRedirectURI = "https://zoomscheduler.app/oauth"
    static let zoomAuthHeader = "Z3BvV2tLWHJRa3VQb0s2eEdDQ2ptdzozYzRGb1M4ME5Ca3JGdDE5YWc1RVU0R0FYMTZWbXYycA=="

    init() {
        if let savedRefreshToken = UserDefaults.standard.string(forKey: "zoomRefreshToken") {
            refreshToken = savedRefreshToken
            authState = .connecting

            self.refreshAccessToken()
        }
    }

    public func launchAuthFlow() {
        var components = URLComponents(string: "https://zoom.us/oauth/authorize")

        components?.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: ZoomAPI.zoomClientID),
            URLQueryItem(name: "redirect_uri", value: ZoomAPI.zoomRedirectURI),
        ]

        if let url = components?.url {
            NSWorkspace.shared.open(url)
        }
    }

    public func revokeSession() {
        self.accessToken = nil
        self.refreshToken = nil
        self.authCode = nil
        self.authState = .notConnected
    }

    private func generateRandomPassword() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<10).map{ _ in letters.randomElement()! })
    }

    public func createQuickMeeting(completion: @escaping (ZoomMeeting?) -> Void) {
        let meeting = Meeting(type: .quick)
        meeting.duration = .none
        createMeeting(meeting: meeting, completion: completion)
    }

    public func createMeeting(meeting: Meeting, completion: @escaping (ZoomMeeting?) -> Void) {
        guard let url = URL(string: "https://api.zoom.us/v2/users/me/meetings"),
              let token = self.accessToken else {
            completion(nil)
            return
        }

        let dateFormatter = DateFormatter()

        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // 2019-09-05T16:54:14Z

        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        var payload: [String: Any] = [:]
        payload["type"] = meeting.type.rawValue
        payload["start_time"] = dateFormatter.string(from: meeting.date)
        payload["timezone"] = meeting.timeZone
        payload["password"] = generateRandomPassword()

        if !meeting.name.isEmpty {
            payload["topic"] = meeting.name
        }
        if meeting.duration != .none {
            payload["duration"] = meeting.duration.rawValue
        }

        guard let payloadData = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(nil)
            return
        }

        request.httpBody = payloadData
        request.setValue("application/json", forHTTPHeaderField: "Content-type")

        let task = URLSession.shared.dataTask(
            with: request as URLRequest,
            completionHandler: { data, response, error in

                guard error == nil else {
                    completion(nil)
                    return
                }

                guard let data = data else {
                    completion(nil)
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let zoomMeeting = try decoder.decode(ZoomMeeting.self, from: data)

                    DispatchQueue.main.async {
                        completion(zoomMeeting)
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    print(error.localizedDescription)
                }
            }
        )

        task.resume()
    }

    private func refreshAccessToken() {
        guard let token = refreshToken else {
            authState = .notConnected
            return
        }

        self.sendAuthRequest(requestType: .refreshToken, token: token)
    }

    private func fetchAccessToken() {
        guard let code = authCode else {
            self.authState = .notConnected
            return
        }

        self.sendAuthRequest(requestType: .generateToken, token: code)
    }

    enum AuthRequestType {
        case generateToken
        case refreshToken
    }

    private func sendAuthRequest(requestType: AuthRequestType, token: String) {
        var components = URLComponents(string: "https://zoom.us/oauth/token")

        switch requestType {
            case .generateToken:
                components?.queryItems = [
                    URLQueryItem(name: "grant_type", value: "authorization_code"),
                    URLQueryItem(name: "code", value: token),
                    URLQueryItem(name: "redirect_uri", value: ZoomAPI.zoomRedirectURI),
                ]
            case .refreshToken:
                components?.queryItems = [
                    URLQueryItem(name: "grant_type", value: "refresh_token"),
                    URLQueryItem(name: "refresh_token", value: token),
                ]
        }

        guard let url = components?.url else {
            self.authState = .failed
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("Basic \(ZoomAPI.zoomAuthHeader)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(
            with: request as URLRequest,
            completionHandler: { data, response, error in

                guard error == nil else {
                    DispatchQueue.main.async {
                        self.authState = .failed
                    }

                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        self.authState = .failed
                    }

                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(
                        with: data,
                        options: .mutableContainers) as? [String: Any] {

                        guard let token = json["access_token"] as? String,
                              let refreshToken = json["refresh_token"] as? String else {

                            DispatchQueue.main.async {
                                self.authState = .failed
                            }

                            return
                        }

                        print(json)

                        DispatchQueue.main.async {
                            self.authState = .success
                            self.accessToken = token
                            self.refreshToken = refreshToken
                        }
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        self.authState = .failed
                    }

                    print(error.localizedDescription)
                }
            }
        )

        task.resume()
    }
}
