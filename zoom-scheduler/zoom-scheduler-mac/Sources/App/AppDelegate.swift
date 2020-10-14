//
//  AppDelegate.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 28.09.2020.
//

import Cocoa
import Magpie
import SwiftUI

let windowSize = CGSize(width: 720.0, height: 562.0)

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    private lazy var target = Target()
    private lazy var userCache = HIPCache()
    private lazy var session = Session(
        keychain: HIPKeychain(
            identifier: "\(Bundle.main.bundleIdentifier ?? "com.hipo.zoomscheduler").keychain"
        )
    )
    private lazy var zoomAPI = ZoomAPIV2(config: target.zoomConfig, session: session)
    private lazy var googleCalendarAPI = GoogleCalendarAPI()

    private lazy var preferences = Preferences(userCache: userCache)

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
                googleCalendarAPI: googleCalendarAPI,
                preferences: preferences
            )
            .environmentObject(target)
            .environmentObject(zoomAPI)
        )
        window.makeKeyAndOrderFront(nil)

        window.setFrameAutosaveName("Main Window")
        window.center()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        switch zoomAPI.session.status {
            case .authorized(let credentials):
                if credentials.isExpired {
                    zoomAPI.refreshAccessToken()
                }
            case .unauthorized:
                zoomAPI.refreshAccessToken()
            default:
                break
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }

        if url.scheme == "zoomscheduler" {
            var draft = RequestAccessTokenDraft()
            draft.config = target.zoomConfig
            draft.authorizationCode = url.host
            zoomAPI.requestAccessToken(draft)
        } else {
            googleCalendarAPI.authFlow?.resumeExternalUserAgentFlow(with: url)
        }
        window.makeKeyAndOrderFront(nil)
    }
}
