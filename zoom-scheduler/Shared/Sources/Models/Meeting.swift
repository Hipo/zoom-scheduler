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
}

extension Meeting {
    enum Duration: CaseIterable, CustomStringConvertible {
        case thirtyMins
        case fortyFiveMins
        case oneHour
        case oneAndHalfHour
        case twoHours

        var description: String {
            switch self {
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
