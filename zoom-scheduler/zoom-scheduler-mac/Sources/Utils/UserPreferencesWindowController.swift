//
//  UserPreferencesWindowController.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 20.10.2020.
//

import Foundation
import Preferences

class UserPreferencesWindowController: PreferencesWindowController {
    private var preferencesScreen: PreferencesScreen

    init(userPreferences: UserPreferences) {
        let preferencesScreen = PreferencesScreen(userPreferences: userPreferences)
        let paneView = Preferences.Pane(
            identifier: Preferences.PaneIdentifier("preferences"),
            title: "Preferences",
            toolbarIcon: NSImage(named: "Screens/Icons/settings")!
        ) { preferencesScreen }
        let preferencesViewController = Preferences.PaneHostingController(pane: paneView)

        self.preferencesScreen = preferencesScreen

        super.init(
            preferencePanes: [preferencesViewController],
            style: .toolbarItems,
            animated: true,
            hidesToolbarForSingleItem: true
        )

        window?.appearance = NSAppearance(named: .darkAqua)
        window?.backgroundColor = NSColor(named: "Screens/Attributes/Background/primary")
        window?.titlebarAppearsTransparent = true
    }
}
