//
//  UserPreferences.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 19.10.2020.
//

import Foundation
import Magpie

class UserPreferences: ObservableObject {
    @Published
    var launchAtLogin = false {
        didSet {
            saveLaunchAtLogin()
        }
    }

    let userCache: HIPCacheConvertible

    init(userCache: HIPCacheConvertible) {
        self.userCache = userCache
        readLaunchAtLogin()
    }
}

extension UserPreferences {
    private func readLaunchAtLogin() {
        launchAtLogin = userCache.getObject(for: Key.launchAtLogin) ?? false
    }

    private func saveLaunchAtLogin() {
        userCache.set(object: launchAtLogin, for: Key.launchAtLogin)
    }
}

extension UserPreferences {
    private enum Key: String, HIPCacheKeyConvertible {
        case launchAtLogin = "preferences.launchAtLogin"
    }
}
