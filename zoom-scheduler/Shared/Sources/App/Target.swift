//
//  Target.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 13.10.2020.
//

import Foundation
import SwiftDate

final class Target: ObservableObject {
    let zoomConfig = ZoomConfig()

    init() {
        setupFrameworks()
    }
}

extension Target {
    private func setupFrameworks() {
        setupSwiftDateFramework()
    }

    private func setupSwiftDateFramework() {
        SwiftDate.defaultRegion = Region(
            calendar: Calendar.autoupdatingCurrent,
            zone: TimeZone.autoupdatingCurrent,
            locale: Locales.englishUnitedStatesComputer
        )
    }
}

final class ZoomConfig {
    var oauthAuthorizeUrl: String {
        return oauthBase + "/authorize"
    }

    let clientId = "gpoWkKXrQkuPoK6xGCCjmw"
    let redirectUri = "https://zoomscheduler.app/oauth"
    let oauthBase = "https://zoom.us/oauth"
    let oauthAuthorizationToken = "Z3BvV2tLWHJRa3VQb0s2eEdDQ2ptdzozYzRGb1M4ME5Ca3JGdDE5YWc1RVU0R0FYMTZWbXYycA=="
}
