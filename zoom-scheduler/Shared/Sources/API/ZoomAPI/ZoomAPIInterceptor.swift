//
//  ZoomAPIInterceptor.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 14.10.2020.
//

import Foundation
import Magpie

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
        if let credentials = session.credentials {
            endpoint.set(additionalHeader: AuthorizationHeader.bearer(credentials.accessToken))
            return
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

extension AuthorizationHeader {
    public static func basic(_ value: String?) -> Self {
        let tokenValue = value.map { "Basic \($0)" }
        return Self(tokenValue)
    }
}
