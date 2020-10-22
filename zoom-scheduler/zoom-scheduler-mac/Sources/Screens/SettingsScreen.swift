//
//  SettingsScreen.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 15.10.2020.
//

import Magpie
import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject
    var session: Session

    @State
    private var isActive = false

    @State
    private var isDisconnecting = false
    @State
    private var disconnectAccountAlertItem: DisconnectAccountAlertItem?

    let zoomAPI: ZoomAPI
    let googleAPI: GoogleAPI

    var body: some View {
        VStack(alignment: .trailing) {
            Button(action: {
                isActive.toggle()
            }) {
                Image("Screens/Icons/settings")
                    .frame(width: 36, height: 36)
                    .background(Color("Views/BarButton/Background/primary"))
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())

            if isActive {
                Group {
                    VStack(spacing: 4) {
                        SettingItemView(title: "Disconnect Zoom Account") {
                            isDisconnecting = true

                            disconnectAccountAlertItem = DisconnectAccountAlertItem(
                                account: .zoom,
                                confirmAction: {
                                    googleAPI.revokeAuthorization()

                                    zoomAPI.revokeAccessToken() { _ in
                                        isDisconnecting = false
                                    }
                                },
                                cancelAction: {
                                    isDisconnecting = false
                                }
                            )
                        }
                        .disabled(session.isRefreshing || isDisconnecting)

                        if session.isGoogleAccountConnected {
                            SettingItemView(
                                title: "Disconnect Google Account"
                            ) {
                                disconnectAccountAlertItem = DisconnectAccountAlertItem(
                                    account: .google,
                                    confirmAction: {
                                        googleAPI.revokeAuthorization()
                                    },
                                    cancelAction: nil
                                )
                            }
                        } else {
                            SettingItemView(
                                title: "Connect Google Account"
                            ) {
                                googleAPI.requestAuthorization()
                            }
                        }

                        SettingItemView(title: "Preferences") {
                            isActive = false

                            NSApplication.shared.openPreferences()
                        }

                        SettingItemView(title: "Help") {
                            isActive = false

                            NSApplication.shared.openSafari("https://zoomscheduler.app")
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(width: 200)
                .background(Color("Screens/Attributes/Background/secondary"))
                .cornerRadius(8)
                .shadow(
                    color: Color("Views/Attributes/Shadow/tertiary"),
                    radius: 16,
                    x: 0,
                    y: 8
                )
            }
        }
        .padding(8)
        .onHover { hovering in
            if !hovering {
                isActive = false
            }
        }
        .alert(item: $disconnectAccountAlertItem) { item in
            Alert(
                title: Text(item.title),
                message: Text(item.message),
                primaryButton: .default(Text("OK"), action: item.confirmAction),
                secondaryButton: .cancel(item.cancelAction)
            )
        }
    }
}

extension SettingsScreen {
    private struct DisconnectAccountAlertItem: Identifiable {
        typealias Action = () -> Void

        let id: String
        let title: String
        let message: String
        let account: Account
        let confirmAction: () -> Void
        let cancelAction: (() -> Void)?

        init(
            account: Account,
            confirmAction: @escaping Action,
            cancelAction: Action?
        ) {
            self.id = account.rawValue
            self.title = account.title
            self.message = account.message
            self.account = account
            self.confirmAction = confirmAction
            self.cancelAction = cancelAction
        }

        enum Account: String {
            case zoom
            case google

            var title: String {
                return "Confirmation"
            }

            var message: String {
                switch self {
                    case .zoom:
                        return "Are you sure you would like to disconnect your Zoom account?"
                    case .google:
                        return "Are you sure you would like to disconnect your Google account?"
                }
            }
        }
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen(
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
    }
}
