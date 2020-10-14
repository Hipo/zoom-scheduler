//
//  Preferences.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 1.10.2020.
//

import Foundation
import Magpie

final class Preferences: ObservableObject {
    @Published var skipsSyncingGoogleCalendar: Bool {
        didSet {
            userCache?.set(object: skipsSyncingGoogleCalendar, for: Key.skipsSyncingGoogleCalendar)
        }
    }

    let userCache: HIPCacheConvertible?

    init(userCache: HIPCacheConvertible?) {
        self.userCache = userCache
        self.skipsSyncingGoogleCalendar =
            userCache?.getObject(for: Key.skipsSyncingGoogleCalendar) ?? false
    }
}

extension Preferences {
    func revoke() {
        userCache?.remove(for: Key.skipsSyncingGoogleCalendar)
        skipsSyncingGoogleCalendar = false
    }
}

extension Preferences {
    private enum Key: String, HIPCacheKeyConvertible {
        case skipsSyncingGoogleCalendar = "preferences.skipsSyncingGoogleCalendar"
    }
}
