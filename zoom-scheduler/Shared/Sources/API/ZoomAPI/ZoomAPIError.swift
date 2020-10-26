//
//  ZoomAPIError.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 14.10.2020.
//

import Foundation
import Magpie

enum ZoomAPIError: Error {
    case sessionExpired
    case sessionCancelled
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

    var displayMessage: String {
        switch self {
            case .sessionExpired:
                return "Wait a moment while we are refreshing your session."
            case .sessionCancelled:
                return "We cancelled your session because we couldn't refresh your session."
            case .client(_, let detail):
                return detail?.displayMessage ?? "Sorry, we couldn't fullfill your request."
            case .server:
                return "Sorry, we are having problems reaching to the server."
            case .network:
                return "There is a problem with your internet connection."
            case .unexpected:
                return "Sorry, we couldn't figure out your problem."
        }
    }
}

extension ZoomAPIError {
    struct Detail: Model {
        var displayMessage: String {
            return message ?? "Sorry, we couldn't fulfill your request."
        }

        let code: Int
        let message: String?
    }
}
