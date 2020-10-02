//
//  Meeting.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 28.09.2020.
//

import Foundation

final class Meeting: ObservableObject {
    @Published var name = ""
    @Published var date = Date()
    @Published var duration: Duration = .thirtyMins
    @Published var invitees: [Invitee] = []

    let type: Type
    let timeZone: String


    init(type: Type = .scheduled) {
        self.type = type
        self.timeZone = TimeZone.current.identifier
    }
}

extension Meeting {
    enum `Type`: Int {
        case quick = 1
        case scheduled = 2
    }

    enum Duration: Int, CustomStringConvertible {
        case none = -1
        case thirtyMins = 30
        case fortyFiveMins = 45
        case oneHour = 60
        case oneAndHalfHour = 90
        case twoHours = 120

        static var all: [Duration] =
            [.thirtyMins, .fortyFiveMins, .oneHour, .oneAndHalfHour, .twoHours]

        var description: String {
            switch self {
                case .none:
                    return ""
                case .thirtyMins:
                    return "30 mins"
                case .fortyFiveMins:
                    return "45 mins"
                case .oneHour:
                    return "60 mins"
                case .oneAndHalfHour:
                    return "90 mins"
                case .twoHours:
                    return "120 mins"
            }
        }
    }
}

extension Meeting {
    struct Invitee: Equatable {
        let id = UUID().uuidString
        let email: String
    }
}
