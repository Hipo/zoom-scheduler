//
//  RootScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 29.09.2020.
//

import Magpie
import SwiftUI

struct RootScreen: View {
    @EnvironmentObject
    var session: Session

    let zoomAPI: ZoomAPI
    let googleAPI: GoogleAPI

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if session.isConnected {
                if session.requiresGoogleAuthorization {
                    SignInGoogleScreen(googleAPI: googleAPI)
                } else {
                    HomeScreen(
                        zoomAPI: zoomAPI,
                        googleAPI: googleAPI
                    )

                    SettingsScreen(
                        zoomAPI: zoomAPI,
                        googleAPI: googleAPI
                    )
                    .alignmentGuide(.trailing) { $0[.trailing] + 20 }
                }
            } else {
                SignInZoomScreen(zoomAPI: zoomAPI)
            }
        }
        .background(Color("Screens/Attributes/Background/primary"))
        .frame(
            minWidth: windowSize.width,
            idealWidth: windowSize.width,
            maxWidth: .infinity,
            minHeight: windowSize.height,
            idealHeight: windowSize.height,
            maxHeight: .infinity,
            alignment: .center
        )
    }
}

struct RootScreen_Previews: PreviewProvider {
    static var previews: some View {
        RootScreen(
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
        .environmentObject(
            Session(
                keychain: HIPKeychain(identifier: "preview"),
                userCache: HIPCache()
            )
        )
    }
}
