//
//  ZoomAPIError.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 14.10.2020.
//

import Foundation
import Magpie

enum ZoomAPIError {
    case sessionExpired
    case client(HTTPError, Detail?)
    case server(HTTPError)
    case network(NetworkError)
    case unexpected(APIError)

    init(
        apiError: APIError,
        apiErrorDetail: Detail? = nil
    ) {
        if let httpError = apiError as? HTTPError {
            if httpError.isUnauthorized {
                self = .sessionExpired
                return
            }
            if httpError.isClient {
                self = .client(httpError, apiErrorDetail)
                return
            }
            if httpError.isServer {
                self = .server(httpError)
                return
            }
        }
        if let networkError = apiError as? NetworkError {
            self = .network(networkError)
            return
        }
        self = .unexpected(apiError)
    }
}

extension ZoomAPIError {
    struct Detail: Model {
        var displayMessage: String {
            return message ?? "Sorry, we couldn't fulfill your request!"
        }

        let code: Int
        let message: String?
    }
}
