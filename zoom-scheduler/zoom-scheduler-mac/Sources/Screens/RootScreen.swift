//
//  RootScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 29.09.2020.
//

import SwiftUI

struct RootScreen: View {
    @State
    private var hasOngoingScheduler = false

    var body: some View {
        Group {
            if hasOngoingScheduler {
                SchedulerScreen()
            } else {
                WelcomeScreen {
                    hasOngoingScheduler = true
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

struct RootScreen_Previews: PreviewProvider {
    static var previews: some View {
        RootScreen()
    }
}
