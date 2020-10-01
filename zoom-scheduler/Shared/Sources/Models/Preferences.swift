//
//  Preferences.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 1.10.2020.
//

import Foundation

final class Preferences: ObservableObject {
    @Published var skipsSyncingGoogleCalendar: Bool {
        didSet {
            UserDefaults.standard.set(skipsSyncingGoogleCalendar, forKey: Key.skipsSyncingGoogleCalendar)
        }
    }

    init() {
        skipsSyncingGoogleCalendar = UserDefaults.standard.bool(forKey: Key.skipsSyncingGoogleCalendar)
    }
}

extension Preferences {
    func reset() {
        skipsSyncingGoogleCalendar = false
    }
}

extension Preferences {
    private enum Key {
        static let skipsSyncingGoogleCalendar = "com.hipo.preferences.skips_syncing_google_calendar"
    }
}
