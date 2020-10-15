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

    @ObservedObject
    var preferences: Preferences

    let zoomAPI: ZoomAPI
    let googleAPI: GoogleAPI

    var body: some View {
        Group {
            if session.isAuthorized {
                if preferences.skipsSyncingGoogleCalendar {
                    HomeScreen(
                        zoomAPI: zoomAPI,
                        googleAPI: googleAPI
                    )
                } else {
                    switch session.googleAuthorizationStatus {
                        case .authorized:
                            HomeScreen(
                                zoomAPI: zoomAPI,
                                googleAPI: googleAPI
                            )
                        default:
                            SyncGoogleCalendarScreen(
                                preferences: preferences,
                                googleAPI: googleAPI
                            )
                    }
                }
            } else {
                WelcomeScreen(zoomAPI: zoomAPI)
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
        .onAppear {
            print("Root is on appear.")
        }
    }
}

struct RootScreen_Previews: PreviewProvider {
    static var previews: some View {
        RootScreen(
            preferences: Preferences(userCache: nil),
            zoomAPI: ZoomAPI(
                config: ZoomConfig(),
                session: Session(keychain: HIPKeychain(identifier: "preview"))
            ),
            googleAPI: GoogleAPI(
                config: GoogleConfig(),
                session: Session(keychain: HIPKeychain(identifier: "preview"))
            )
        )
    }
}
