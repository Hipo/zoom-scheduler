//
//  RootScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 29.09.2020.
//

import SwiftUI

struct RootScreen: View {
    @EnvironmentObject
    var zoomAPI: ZoomAPIV2

    @ObservedObject
    var googleCalendarAPI: GoogleCalendarAPI
    @ObservedObject
    var preferences: Preferences

    var body: some View {
        Group {
            if zoomAPI.session.isAuthorized {
                if preferences.skipsSyncingGoogleCalendar {
                    HomeScreen(googleCalendarAPI: googleCalendarAPI)
                } else {
                    switch googleCalendarAPI.authState {
                        case .connected:
                            HomeScreen(googleCalendarAPI: googleCalendarAPI)
                        default:
                            SyncGoogleCalendarScreen(
                                googleCalendarAPI: googleCalendarAPI,
                                preferences: preferences
                            )
                    }
                }
            } else {
                WelcomeScreen()
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
            googleCalendarAPI: GoogleCalendarAPI(),
            preferences: Preferences(userCache: nil)
        )
    }
}
