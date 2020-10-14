//
//  CreateMeetingDraft.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 14.10.2020.
//

import Foundation
import Magpie
import SwiftDate

struct CreateMeetingDraft: JSONObjectBody {
    var timeZone: String {
        return TimeZone.current.identifier
    }
    var bodyParams: [ZoomAPIV2.BodyParam] {
        var params: [ZoomAPIV2.BodyParam] = []
        params.append(.init(.type, reason.rawValue))
        params.append(.init(.topic, name))
        params.append(.init(.startTime, date.toFormat("yyyy-MM-dd'T'HH:mm:ss")))
        params.append(.init(.timezone, timeZone))
        params.append(.init(.duration, duration.minutes, .setIfPresent))
        params.append(.init(.password, generatePassword()))
        return params
    }

    var name = "Zoom Meeting"
    var date = Date()
    var duration: Duration

    let reason: Reason

    init(reason: Reason) {
        self.reason = reason

        switch reason {
            case .instant:
                self.duration = .none
            case .scheduled:
                self.duration = .thirtyMins
        }
    }
}

extension CreateMeetingDraft {
    private func generatePassword() -> String {
        let allowedCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@-_*"
        return String(allowedCharacters.shuffled()[0..<10])
    }
}

extension CreateMeetingDraft {
    enum Reason: Int {
        case instant = 1
        case scheduled = 2
    }

    enum Duration: Hashable {
        case none
        case thirtyMins
        case fortyFiveMins
        case oneHour
        case oneAndHalfHour
        case custom(Int)

        static let selectables: [Duration]
            = [.thirtyMins, .fortyFiveMins, .oneHour, .oneAndHalfHour]

        var minutes: Int? {
            switch self {
                case .none:
                    return nil
                case .thirtyMins:
                    return 30
                case .fortyFiveMins:
                    return 45
                case .oneHour:
                    return 60
                case .oneAndHalfHour:
                    return 90
                case .custom(let customMinutes):
                    return customMinutes
            }
        }

        var description: String {
            return minutes.map { "\($0) mins" } ?? "No duration"
        }
    }
}
