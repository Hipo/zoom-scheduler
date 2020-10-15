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
    var status: Status = .none {
        didSet { statusDidChange() }
    }
    @Published
    var googleAuthorizationStatus: GoogleAuthorizationStatus = .none {
        didSet { googleAuthorizationStatusDidChange() }
    }
    @Published
    var googleCalendars: [GoogleCalendar] = []

    private(set) var credentials: Credentials?
    private(set) var googleAuthorizationCredentials: GTMAppAuthFetcherAuthorization?

    var isAuthorized: Bool {
        switch status {
            case .authorized:
                return true
            default:
                return false
        }
    }
    var isUnauthorized: Bool {
        switch status {
            case .none,
                 .unauthorized:
                return true
            default:
                return false
        }
    }
    var error: ZoomAPIError? {
        switch status {
            case .unauthorized(let apiError):
                return apiError
            default:
                return nil
        }
    }

    var isGoogleAuthorized: Bool {
        switch googleAuthorizationStatus {
            case .authorized:
                return true
            default:
                return false
        }
    }
    var isGoogleUnauthorized: Bool {
        switch googleAuthorizationStatus {
            case .unauthorized:
                return true
            default:
                return false
        }
    }

    let keychain: HIPKeychainConvertible

    init(keychain: HIPKeychainConvertible) {
        self.keychain = keychain

        readStatusFromVault()
        readGoogleAuthorizationStatusFromVault()
    }
}

extension Session {
    func revoke() {
        googleAuthorizationStatus = .none
        status = .none
    }
}

extension Session {
    private func statusDidChange() {
        saveStatusToVault()
    }

    private func readStatusFromVault() {
        if let credentials: Credentials = try? keychain.getModel(for: Key.credentials) {
            self.credentials = credentials
            status = .unauthorized(.sessionExpired)
        } else {
            status = .none
        }
    }

    private func saveStatusToVault() {
        switch status {
            case .none:
                self.credentials = nil
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
        saveGoogleAuthorizationStatusToVault()
    }

    private func readGoogleAuthorizationStatusFromVault() {
        if let googleAuthorizationCredentials = GTMAppAuthFetcherAuthorization(
            fromKeychainForName: Key.googleAuthorizationCredentials.rawValue
        ), googleAuthorizationCredentials.canAuthorize() {
            googleAuthorizationStatus = .authorized(googleAuthorizationCredentials)
        } else {
            googleAuthorizationStatus = .none
        }
    }

    private func saveGoogleAuthorizationStatusToVault() {
        switch googleAuthorizationStatus {
            case .none:
                self.googleAuthorizationCredentials = nil
                GTMAppAuthFetcherAuthorization.removeFromKeychain(
                    forName: Key.googleAuthorizationCredentials.rawValue
                )
            case .authorized(let googleAuthorizationCredentials):
                self.googleAuthorizationCredentials = googleAuthorizationCredentials
                GTMAppAuthFetcherAuthorization.save(
                    googleAuthorizationCredentials,
                    toKeychainForName: Key.googleAuthorizationCredentials.rawValue
                )
            default:
                break
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
        case none /// <note> Not having a connection to API
        case connecting /// <note> Waiting for API response to determine the status
        case authorized(Credentials)
        case unauthorized(ZoomAPIError) /// <note> Attempt to authorize API is failed
    }

    enum GoogleAuthorizationStatus {
        case none /// <note> Not having a connection to API
        case authorized(GTMAppAuthFetcherAuthorization)
        case unauthorized(NSError?)
    }
}

extension Session {
    enum Key: String, HIPKeychainKeyConvertible, HIPCacheKeyConvertible {
        case credentials = "session.credentials"
        case googleAuthorizationCredentials = "session.google.authorization.credentials"
    }
}
