//
//  PreferencesScreen.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 19.10.2020.
//

import AppKit
import KeyboardShortcuts
import Magpie
import Preferences
import SwiftUI

struct PreferencesScreen: View {
    @ObservedObject
    var userPreferences: UserPreferences

    var body: some View {
        Preferences.Container(contentWidth: 400) {
            Preferences.Section(title: "Startup:") {
                Toggle("Launch At Login", isOn: $userPreferences.launchAtLogin)
            }

            Preferences.Section(title: "HotKey:") {
                KeyboardShortcuts.Recorder(for: .autoLaunchHotKey)
            }
        }
        .colorScheme(.dark)
        .frame(height: 120)
    }
}

struct PreferencesScreen_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesScreen(userPreferences: UserPreferences(userCache: HIPCache()))
    }
}
