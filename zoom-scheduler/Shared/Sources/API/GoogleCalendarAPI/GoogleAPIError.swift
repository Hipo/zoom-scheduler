//
//  GoogleAPIError.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 22.10.2020.
//

import Foundation

enum GoogleAPIError: Error {
    case client(Detail?)
    case server
    case network
    case unexpected(Error)

    init(error: Error) {
        if error is URLError {
            self = .network
        } else {
            let nsError = error as NSError

            switch nsError.code {
                case 400..<500:
                    if let data = nsError.userInfo["data"] as? Data {
                        self = .client(try? Detail.decoded(data))
                    } else {
                        self = .client(nil)
                    }
                case 500...:
                    self = .server
                default:
                    self = .unexpected(error)
            }
        }
    }

    var displayMessage: String {
        switch self {
            case .client(let detail):
                return detail?.message ?? "Sorry, we couldn't fullfill your request."
            case .server:
                return "Sorry, we are having problems reaching to the server."
            case .network:
                return "There is a problem with your internet connection."
            case .unexpected:
                return "Sorry, we couldn't figure out your problem."
        }
    }
}

extension GoogleAPIError {
    struct Detail: Model {
        let code: Int?
        let message: String?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let error = try container.nestedContainer(keyedBy: ErrorCodingKeys.self, forKey: .error)

            code = try error.decodeIfPresent(Int.self, forKey: .code)
            message = try error.decodeIfPresent(String.self, forKey: .message)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            var error = container.nestedContainer(keyedBy: ErrorCodingKeys.self, forKey: .error)

            try error.encode(code, forKey: .code)
            try error.encode(message, forKey: .message)
        }

        private enum CodingKeys: String, CodingKey {
            case error
        }

        private enum ErrorCodingKeys: String, CodingKey {
            case code
            case message
        }
    }
}
