//
//  ZoomAPIInterceptor.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 14.10.2020.
//

import Foundation
import JWTKit
import Magpie
import SwiftDate

struct ZoomAPIInterceptor: APIInterceptor {
    let config: ZoomConfig
    let session: Session

    func intercept(_ endpoint: EndpointOperatable) {
        endpoint.set(additionalHeader: AcceptHeader.json())
        endpoint.set(additionalHeader: ContentTypeHeader.json())

        if endpoint.request.base.contains(config.oauthBase) {
            endpoint.set(additionalHeader: AuthorizationHeader.basic(config.oauthAuthorizationToken))
            return
        }

        switch session.authorizationMethod {
            case .oauth:
                if let credentials = session.credentials as? Session.Credentials {
                    endpoint.set(additionalHeader: AuthorizationHeader.bearer(credentials.accessToken))
                }
            case .jwt:
                if let credentials = session.credentials as? Session.JWTCredentials {
                    let signer = JWTSigner.hs256(key: credentials.apiSecret)
                    let payload = ZoomAPIJWTPayload(apiKey: credentials.apiKey)
                    let token = try? signer.sign(payload)
                    endpoint.set(additionalHeader: AuthorizationHeader.bearer(token))
                }
        }
    }

    init(
        config: ZoomConfig,
        session: Session
    ) {
        self.config = config
        self.session = session
    }
}

extension ZoomAPIInterceptor {
    var description: String {
        return """
        Config: \(config)
        session: \(session)
        """
    }
}

struct ZoomAPIJWTPayload: JWTPayload {
    var issuer: IssuerClaim
    var expiration: ExpirationClaim

    init(apiKey: String) {
        self.issuer = .init(value: apiKey)
        self.expiration = .init(value: Date() + 30.seconds)
    }

    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}

extension ZoomAPIJWTPayload {
    private enum CodingKeys: String, CodingKey {
        case issuer = "iss"
        case expiration = "exp"
    }
}

extension AuthorizationHeader {
    public static func basic(_ value: String?) -> Self {
        let tokenValue = value.map { "Basic \($0)" }
        return Self(tokenValue)
    }
}
