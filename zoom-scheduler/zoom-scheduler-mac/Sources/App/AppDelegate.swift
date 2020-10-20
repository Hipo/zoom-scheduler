//
//  AppDelegate.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 28.09.2020.
//

import Cocoa
import KeyboardShortcuts
import Magpie
import Preferences
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    private lazy var target = Target()
    private lazy var userCache = HIPCache()
    private lazy var session = Session(
        keychain: HIPKeychain(
            identifier: "\(Bundle.main.bundleIdentifier ?? "com.hipo.zoomscheduler").keychain"
        ),
        userCache: userCache
    )
    private lazy var zoomAPI = ZoomAPI(config: target.zoomConfig, session: session)
    private lazy var googleAPI = GoogleAPI(config: target.googleConfig, session: session)

    private lazy var userPreferences = UserPreferences(userCache: userCache)
    private lazy var preferencesWindowController =
        UserPreferencesWindowController(userPreferences: userPreferences)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = MainWindow(
            contentRect: NSRect(origin: .zero, size: MainWindow.windowSize),
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                .resizable,
                .fullSizeContentView
            ],
            backing: .buffered,
            defer: false
        )
        window.backgroundColor = NSColor(named: "Screens/Attributes/Background/primary")
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(
            rootView: RootScreen(
                zoomAPI: zoomAPI,
                googleAPI: googleAPI
            )
            .environmentObject(target)
            .environmentObject(session)
        )
        window.makeKeyAndOrderFront(nil)

        window.setFrameAutosaveName("Main Window")
        window.center()

        setupHotKey()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        switch session.status {
            case .authorized(let credentials):
                if credentials.isExpired {
                    zoomAPI.refreshAccessToken()
                }
            case .unauthorized:
                if session.credentials != nil {
                    zoomAPI.refreshAccessToken()
                }
            default:
                break
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }

        if url.scheme == "zoomscheduler" {
            var draft = RequestAccessTokenDraft()
            draft.authorizationCode = url.host
            zoomAPI.requestAccessToken(draft)
        } else {
            googleAPI.completeAuthorization(redirectUrl: url)
        }
        window.makeKeyAndOrderFront(nil)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag { return false }

        window.makeKeyAndOrderFront(nil)
        return true
    }
}

extension AppDelegate {
    private func setupHotKey() {
        KeyboardShortcuts.onKeyDown(for: .autoLaunchHotKey) {
            let application = NSApplication.shared
            let mainWindow = application.orderedWindows.first { $0 is MainWindow }

            guard let aMainWindow = mainWindow as? MainWindow else { return }

            if application.isActive {
                if aMainWindow.isMiniaturized {
                    application.unhideWithoutActivation()

                    aMainWindow.deminiaturize(nil)
                    aMainWindow.makeKeyAndOrderFront(nil)
                } else {
                    application.hide(nil)
                }
            } else {
                application.unhideWithoutActivation()
                application.activate(ignoringOtherApps: true)

                aMainWindow.makeKeyAndOrderFront(nil)
            }
        }
    }
}

extension AppDelegate {
    @IBAction
    func newQuickCall(_ sender: Any) {
        NotificationCenter.default.post(Notification(name: .newQuickCall))
    }

    @IBAction
    func newEvent(_ sender: Any) {
        NotificationCenter.default.post(Notification(name: .newEvent))
    }

    @IBAction
    func save(_ sender: Any) {
        NotificationCenter.default.post(Notification(name: .save))
    }

    @IBAction
    func cancel(_ sender: Any) {
        NotificationCenter.default.post(Notification(name: .cancel))
    }

    @IBAction
    func openPreferences(_ sender: Any) {
        preferencesWindowController.show()
    }
}

extension Notification.Name {
    static let newQuickCall = Notification.Name("new.quick.call")
    static let newEvent = Notification.Name("new.event")
    static let save = Notification.Name("save")
    static let cancel = Notification.Name("cancel")
}

extension KeyboardShortcuts.Name {
    static let autoLaunchHotKey = Self("preferences.autoLaunchHotKey")
}
