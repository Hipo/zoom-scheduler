//
//  Session.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 12.10.2020.
//

import Foundation
import GTMAppAuth
import Magpie
import SwiftDate

final class Session: ObservableObject {
    @Published
    var status: Status = .none() {
        didSet { statusDidChange() }
    }
    @Published
    var statusError: ZoomAPIError?

    @Published
    var googleAuthorizationStatus: GoogleAuthorizationStatus = .unauthorized() {
        didSet { googleAuthorizationStatusDidChange() }
    }
    @Published
    var googleAuthorizationStatusError: NSError?
    @Published
    var requiresGoogleAuthorization = true {
        didSet { saveRequiresGoogleAuthorizationFlagToVault() }
    }

    @Published
    var googleCalendars: [GoogleCalendar] = []

    var lastSelectedGoogleCalendar: GoogleCalendar? {
        didSet {
            saveLastSelectedGoogleCalendarToVault()
        }
    }

    private(set) var credentials: Credentials?
    private(set) var googleAuthorizationCredentials: GTMAppAuthFetcherAuthorization?

    var isConnected: Bool {
        switch status {
            case .none,
                 .connecting:
                return false
            default:
                return true
        }
    }
    var isConnecting: Bool {
        switch status {
            case .connecting:
                return true
            default:
                return false
        }
    }
    var isRefreshing: Bool {
        switch status {
            case .refreshing:
                return true
            default:
                return false
        }
    }
    var isAuthorized: Bool {
        switch status {
            case .authorized:
                return true
            default:
                return false
        }
    }

    var isGoogleAccountConnected: Bool {
        switch googleAuthorizationStatus {
            case .authorized:
                return true
            case .unauthorized:
                return false
        }
    }

    let keychain: HIPKeychainConvertible
    let userCache: HIPCacheConvertible

    init(
        keychain: HIPKeychainConvertible,
        userCache: HIPCacheConvertible
    ) {
        self.keychain = keychain
        self.userCache = userCache

        readStatusFromVault()

        readRequiresGoogleAuthorizationFlagFromVault()
        readGoogleAuthorizationStatusFromVault()

        readLastSelectedGoogleCalendarFromVault()
    }
}

extension Session {
    func hideStatusError() {
        statusError = nil
    }

    func hideGoogleAuthorizationStatusError() {
        googleAuthorizationStatusError = nil
    }

    func skipGoogleAuthorization() {
        requiresGoogleAuthorization = false
    }
}

extension Session {
    private func statusDidChange() {
        switch status {
            case .none(let error):
                statusError = error
            case .refreshing:
                statusError = .sessionExpired
            case .unauthorized(let error):
                statusError = error
            default:
                statusError = nil
        }
        saveStatusToVault()
    }

    private func readStatusFromVault() {
        if let credentials: Credentials = try? keychain.getModel(for: Key.credentials) {
            self.credentials = credentials
            status = .unauthorized(.sessionExpired)
        } else {
            status = .none()
        }
    }

    private func saveStatusToVault() {
        switch status {
            case .none:
                self.credentials = nil
                self.requiresGoogleAuthorization = true

                try? keychain.remove(for: Key.credentials)
            case .authorized(let credentials):
                self.credentials = credentials
                try? keychain.set(credentials, for: Key.credentials)
            default:
                break
        }
    }
}

extension Session {
    private func googleAuthorizationStatusDidChange() {
        switch googleAuthorizationStatus {
            case .authorized:
                googleAuthorizationStatusError = nil
            case .unauthorized(let error):
                googleAuthorizationStatusError = error
        }
        saveGoogleAuthorizationStatusToVault()
    }

    private func readGoogleAuthorizationStatusFromVault() {
        if let googleAuthorizationCredentials = GTMAppAuthFetcherAuthorization(
            fromKeychainForName: Key.googleAuthorizationCredentials.rawValue
        ), googleAuthorizationCredentials.canAuthorize() {
            googleAuthorizationStatus = .authorized(googleAuthorizationCredentials)
        } else {
            googleAuthorizationStatus = .unauthorized()
        }
    }

    private func saveGoogleAuthorizationStatusToVault() {
        switch googleAuthorizationStatus {
            case .authorized(let googleAuthorizationCredentials):
                self.googleAuthorizationCredentials = googleAuthorizationCredentials
                self.requiresGoogleAuthorization = false

                GTMAppAuthFetcherAuthorization.save(
                    googleAuthorizationCredentials,
                    toKeychainForName: Key.googleAuthorizationCredentials.rawValue
                )
            case .unauthorized:
                self.googleAuthorizationCredentials = nil
                GTMAppAuthFetcherAuthorization.removeFromKeychain(
                    forName: Key.googleAuthorizationCredentials.rawValue
                )
        }
    }
}

extension Session {
    private func readRequiresGoogleAuthorizationFlagFromVault() {
        requiresGoogleAuthorization =
            userCache.getObject(for: Key.requiresGoogleAuthorization) ?? true
    }

    private func saveRequiresGoogleAuthorizationFlagToVault() {
        userCache.set(object: requiresGoogleAuthorization, for: Key.requiresGoogleAuthorization)
    }
}

extension Session {
    private func readLastSelectedGoogleCalendarFromVault() {
        lastSelectedGoogleCalendar = userCache.getModel(for: Key.lastSelectedGoogleCalendar)
    }

    private func saveLastSelectedGoogleCalendarToVault() {
        if let lastSelectedGoogleCalendar = lastSelectedGoogleCalendar {
            userCache.set(model: lastSelectedGoogleCalendar, for: Key.lastSelectedGoogleCalendar)
        } else {
            userCache.remove(for: Key.lastSelectedGoogleCalendar)
        }
    }
}

extension Session {
    struct Credentials: Model {
        private enum CodingKeys: String, CodingKey {
            case accessToken
            case refreshToken
            case expireDuration = "expiresIn"
        }

        var isExpired: Bool {
            return expireTime.map { $0.isBeforeDate(Date(), granularity: .second) } ?? true
        }

        let accessToken: String
        let refreshToken: String
        let expireDuration: Int?
        let expireTime: Date?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            accessToken = try container.decode(String.self, forKey: .accessToken)
            refreshToken = try container.decode(String.self, forKey: .refreshToken)
            expireDuration = try container.decodeIfPresent(Int.self, forKey: .expireDuration)

            /// <warning> it will be considered as expired if there are 10 seconds to expire.
            expireTime = expireDuration.map { Date() + max(0, $0 - 10).seconds }
        }
    }
}

extension Session {
    enum Status {
        case none(ZoomAPIError? = nil) /// <note> Not having a connection to API
        case connecting /// <note> Waiting for API response to connect to API
        case refreshing /// <note> Waiting for API response to resume API
        case authorized(Credentials)
        case unauthorized(ZoomAPIError) /// <note> Attempt to authorize API(by refreshing) is failed
    }

    enum GoogleAuthorizationStatus {
        case authorized(GTMAppAuthFetcherAuthorization)
        case unauthorized(NSError? = nil) /// <warning> Not having a connection to API if there is no error
    }
}

extension Session {
    enum Key: String, HIPKeychainKeyConvertible, HIPCacheKeyConvertible {
        case credentials = "session.credentials"
        case googleAuthorizationCredentials = "session.google.authorization.credentials"
        case requiresGoogleAuthorization = "session.requiresGoogleAuthorization"
        case lastSelectedGoogleCalendar = "session.lastSelectedGoogleCalendar"
    }
}
