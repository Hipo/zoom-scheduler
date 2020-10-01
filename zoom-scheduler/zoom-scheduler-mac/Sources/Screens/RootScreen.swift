//
//  RootScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 29.09.2020.
//

import SwiftUI

struct RootScreen: View {
    @ObservedObject var zoomAPI: ZoomAPI

    var body: some View {
        Group {
            switch zoomAPI.authState {
                case .success:
                    SchedulerScreen()
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
        RootScreen(zoomAPI: ZoomAPI())
    }
}
