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

    @State
    private var hasHotKey = KeyboardShortcuts.getShortcut(for: .autoLaunchHotKey) != nil

    var body: some View {
        let isHideFromDockDisabled = !hasHotKey

        return Preferences.Container(contentWidth: 400) {
            Preferences.Section(title: "Startup:") {
                VStack(alignment: .leading) {
                    LaunchAtLogin.Toggle()

                    Toggle("Hide From Dock", isOn: $userPreferences.hideFromDock)
                        .disabled(isHideFromDockDisabled)

                    Text(
                        (isHideFromDockDisabled
                            ? "You need to assign a hot key before enabling this feature. "
                            : ""
                        ) +
                        "Once 'Hide From Deck' is enabled, Zoom Scheduler will hide itself and " +
                        "will only appear when you press the hot key."
                    )
                    .preferenceDescription()
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 8)
            }

            Preferences.Section(title: "HotKey:") {
                KeyboardShortcuts.Recorder(for: .autoLaunchHotKey) { shortcut in
                    hasHotKey = shortcut != nil
                }
            }
        }
        .colorScheme(.dark)
    }
}

struct PreferencesScreen_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesScreen(userPreferences: UserPreferences(userCache: HIPCache()))
    }
}
