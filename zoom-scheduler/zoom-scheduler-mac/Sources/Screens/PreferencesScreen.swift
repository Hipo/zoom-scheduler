//
//  PreferencesScreen.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 19.10.2020.
//

import AppKit
import KeyboardShortcuts
import LaunchAtLogin
import Magpie
import Preferences
import SwiftUI

struct PreferencesScreen: View {
    @ObservedObject
    var userPreferences: UserPreferences

    var body: some View {
        Preferences.Container(contentWidth: 400) {
            Preferences.Section(title: "Startup:") {
                VStack(alignment: .leading) {
                    LaunchAtLogin.Toggle()

                    Toggle("Hide From Dock", isOn: $userPreferences.hideFromDock)
                }
            }

            Preferences.Section(title: "") {
                Spacer()
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
