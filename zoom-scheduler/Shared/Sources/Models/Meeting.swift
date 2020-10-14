//
//  Meeting.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 28.09.2020.
//

import Foundation

final class Meeting: ObservableObject {
}

extension Meeting {
    struct Invitee: Equatable {
        let id = UUID().uuidString
        let email: String
    }
}
