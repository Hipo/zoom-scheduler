//
//  AppDelegate.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 28.09.2020.
//

import Cocoa
import SwiftUI

let windowSize = CGSize(width: 720.0, height: 562.0)

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    private lazy var zoomAPI = ZoomAPI()
    private lazy var googleCalendarAPI = GoogleCalendarAPI()

    private lazy var preferences = Preferences()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.backgroundColor = NSColor(named: "Screens/Attributes/Background/primary")
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(
            rootView: RootScreen(
                zoomAPI: zoomAPI,
                googleCalendarAPI: googleCalendarAPI,
                preferences: preferences
            )
        )
        window.makeKeyAndOrderFront(nil)

        window.setFrameAutosaveName("Main Window")
        window.center()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else {
            return
        }

        if url.scheme == "zoomscheduler" {
            zoomAPI.authCode = url.host
        } else {
            googleCalendarAPI.authFlow?.resumeExternalUserAgentFlow(with: url)
        }

        window.makeKeyAndOrderFront(nil)
    }
}
