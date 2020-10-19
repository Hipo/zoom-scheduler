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

                            googleAPI.revokeAuthorization()

                            zoomAPI.revokeAccessToken() { _ in
                                isDisconnecting = false
                            }
                        }
                        .disabled(session.isRefreshing || isDisconnecting)

                        if session.isGoogleAccountConnected {
                            SettingItemView(
                                title: "Disconnect Google Account"
                            ) {
                                googleAPI.revokeAuthorization()
                            }
                        } else {
                            SettingItemView(
                                title: "Connect Google Account"
                            ) {
                                googleAPI.requestAuthorization()
                            }
                        }

                        SettingItemView(title: "Help") {
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
