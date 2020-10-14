//
//  HomeScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 2.10.2020.
//

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject
    var zoomAPI: ZoomAPIV2

    var googleCalendarAPI: GoogleCalendarAPI

    @State
    private var mode: Mode = .menu

    var body: some View {
        Group {
            switch zoomAPI.session.status {
                case .authorized:
                    switch mode {
                        case .menu:
                            MenuScreen() {
                                mode = .newEvent
                            }
                        case .newEvent:
                            ScheduleMeetingScreen(
                                googleCalendarAPI: googleCalendarAPI,
                                onSave: {
                                    mode = .menu
                                },
                                onCancel: {
                                    mode = .menu
                                }
                            )
                    }
                default:
                    ActivityIndicator()
                        .frame(
                            width: 50,
                            height: 50
                        )
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

extension HomeScreen {
    private enum Mode {
        case menu
        case newEvent
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(googleCalendarAPI: GoogleCalendarAPI())
            .frame(
                width: windowSize.width,
                height: windowSize.height
            )
    }
}
