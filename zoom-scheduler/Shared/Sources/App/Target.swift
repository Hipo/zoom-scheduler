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
    let googleConfig = GoogleConfig()

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

final class GoogleConfig {
    let clientId = "926865165137-kmdns9cjc1u67tq1l0eb3olbbemk18he.apps.googleusercontent.com"
    let clientSecret = "nWwiFQZVZKkC3viItNnAD1me"
    let scopes = [
        "https://www.googleapis.com/auth/calendar.readonly",
        "https://www.googleapis.com/auth/calendar.events"
    ]
    let redirectUrl = URL(string: "com.googleusercontent.apps.926865165137-kmdns9cjc1u67tq1l0eb3olbbemk18he:/oauthredirect")
}
