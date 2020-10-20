//
//  MenuScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 2.10.2020.
//

import AppKit
import Magpie
import SwiftUI

struct MenuScreen: View {
    @EnvironmentObject
    var session: Session

    @Binding
    var mode: HomeScreen.Mode

    @State
    private var isCreatingNewQuickMeeting = false
    @State
    private var lastQuickMeetingResult: Swift.Result<URL?, ZoomAPIError>?

    let zoomAPI: ZoomAPI
    let googleAPI: GoogleAPI

    var body: some View {
        let menuItemSize = CGSize(width: 96, height: 96)

        return GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                HStack(alignment: .top, spacing: 72) {
                    MenuItemView(
                        isLoading: $isCreatingNewQuickMeeting,
                        icon: "Screens/Icons/quick_call",
                        iconSize: menuItemSize,
                        title: "Quick Call",
                        action: createQuickMeeting
                    )
                    .disabled(!session.isAuthorized)
                    .allowsHitTesting(!isCreatingNewQuickMeeting)

                    MenuItemView(
                        isLoading: .constant(false),
                        icon: "Screens/Icons/new_event",
                        iconSize: menuItemSize,
                        title: "New Event",
                        action: createNewMeeting
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 10) {
                    if let result = lastQuickMeetingResult {
                        switch result {
                            case .success:
                                ToastView(
                                    feedback: InAppFeedback(
                                        reason: .info,
                                        message: "Zoom url is copied to pasteboard.",
                                        actionName: "OK",
                                        action: hideLastQuickMeetingResult
                                    )
                                )
                            case .failure(let error):
                                ToastView(
                                    feedback: InAppFeedback(
                                        reason: .error,
                                        message: error.displayMessage,
                                        actionName: "OK",
                                        action: hideLastQuickMeetingResult
                                    )
                                )
                        }
                    }

                    if let statusError = session.statusError {
                        ToastView(
                            feedback: InAppFeedback(
                                reason: .error,
                                message: statusError.displayMessage,
                                actionName: "OK",
                                action: session.hideStatusError
                            )
                        )
                    }

                    if let googleAuthorizationStatusError = session.googleAuthorizationStatusError {
                        ToastView(
                            feedback: InAppFeedback(
                                reason: .error,
                                message: googleAuthorizationStatusError.localizedDescription,
                                actionName: "Try Again",
                                action: toggleGoogleAuthorization
                            )
                        )
                    }
                }
                .frame(maxWidth: geometry.size.width * 0.8)
                .alignmentGuide(.bottom) { $0[.bottom] + 10 }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDisappear(perform: hideLastQuickMeetingResult)
        .onReceive(NotificationCenter.default.publisher(for: .newQuickCall)) { _ in
            createQuickMeeting()
        }
        .onReceive(NotificationCenter.default.publisher(for: .newEvent)) { _ in
            createNewMeeting()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
        ) { _ in
            hideLastQuickMeetingResult()
        }
    }
}

extension MenuScreen {
    func createQuickMeeting() {
        hideLastQuickMeetingResult()

        isCreatingNewQuickMeeting = true

        let draft = CreateMeetingDraft(reason: .instant)
        zoomAPI.createMeeting(draft) { result in
            isCreatingNewQuickMeeting = false

            switch result {
                case .success(let zoomMeeting):
                    zoomMeeting.copyToClipboard()
                    lastQuickMeetingResult = .success(zoomMeeting.joinUrl)
                case .failure(let apiError, let apiErrorDetail):
                    let error = ZoomAPIError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                    lastQuickMeetingResult = .failure(error)
            }
        }
    }

    func createNewMeeting() {
        mode = .newEvent
    }
}

extension MenuScreen {
    private func hideLastQuickMeetingResult() {
        lastQuickMeetingResult = nil
    }
}

extension MenuScreen {
    private func toggleGoogleAuthorization() {
        session.hideGoogleAuthorizationStatusError()

        if session.isGoogleAccountConnected {
            googleAPI.revokeAuthorization()
        } else {
            googleAPI.requestAuthorization()
        }
    }
}

struct MenuScreen_Previews: PreviewProvider {
    static var previews: some View {
        let windowSize = MainWindow.windowSize

        return MenuScreen(
            mode: .constant(.menu),
            zoomAPI: ZoomAPI(
                config: ZoomConfig(),
                session: Session(
                    keychain: HIPKeychain(identifier: "preview"),
                    userCache: HIPCache()
                )
            ),
            googleAPI: GoogleAPI(
                config: GoogleConfig(),
                session: Session(
                    keychain: HIPKeychain(identifier: "preview"),
                    userCache: HIPCache()
                )
            )
        )
        .frame(
            width: windowSize.width,
            height: windowSize.height
        )
        .background(Color("Screens/Attributes/Background/primary"))
        .environmentObject(
            Session(
                keychain: HIPKeychain(identifier: "preview"),
                userCache: HIPCache()
            )
        )
    }
}
