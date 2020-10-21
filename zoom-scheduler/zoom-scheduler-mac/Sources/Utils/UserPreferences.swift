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
    var hideFromDock: Bool {
        didSet {
            saveHideFromDock()
        }
    }

    let userCache: HIPCacheConvertible

    init(userCache: HIPCacheConvertible) {
        self.userCache = userCache
        self.hideFromDock = userCache.getObject(for: Key.hideFromDock) ?? false
    }
}

extension UserPreferences {
    private func saveHideFromDock() {
        NSApplication.shared.appDelegate.setupActivationPolicy(isHidden: hideFromDock)
        userCache.set(object: hideFromDock, for: Key.hideFromDock)
    }
}

extension UserPreferences {
    private enum Key: String, HIPCacheKeyConvertible {
        case hideFromDock
    }
}
