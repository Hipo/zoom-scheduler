//
//  Session.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 12.10.2020.
//

import Foundation
import Magpie
import SwiftDate

final class Session: ObservableObject {
    @Published
    var status: Status = .none {
        didSet { saveStatusToVault() }
    }

    private(set) var credentials: Credentials?

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

    let keychain: HIPKeychainConvertible

    init(keychain: HIPKeychainConvertible) {
        self.keychain = keychain
        readStatusFromVault()
    }
}

extension Session {
    func revoke() {
        status = .none
    }
}

extension Session {
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
        case unknown /// <note> Waiting for API response to determine the status
        case authorized(Credentials)
        case unauthorized(ZoomAPIError) /// <note> Attempt to authorize API is failed
    }
}

extension Session {
    private enum Key: String, HIPKeychainKeyConvertible, HIPCacheKeyConvertible {
        case credentials = "session.credentials"
    }
}
