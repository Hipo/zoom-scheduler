//
//  RootScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 29.09.2020.
//

import SwiftUI

struct RootScreen: View {
    @ObservedObject
    var zoomAPI: ZoomAPI
    @ObservedObject
    var googleCalendarAPI: GoogleCalendarAPI
    @ObservedObject
    var preferences: Preferences

    var body: some View {
        Group {
            switch zoomAPI.authState {
                case .success:
                    if preferences.skipsSyncingGoogleCalendar {
                        SchedulerScreen()
                    } else {
                        switch googleCalendarAPI.authState {
                            case .connected:
                                SchedulerScreen()
                            default:
                                SyncGoogleCalendarScreen(
                                    googleCalendarAPI: googleCalendarAPI,
                                    preferences: preferences
                                )
                        }
                    }
                default:
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
    }
}

struct RootScreen_Previews: PreviewProvider {
    static var previews: some View {
        RootScreen(
            zoomAPI: ZoomAPI(),
            googleCalendarAPI: GoogleCalendarAPI(),
            preferences: Preferences()
        )
    }
}
