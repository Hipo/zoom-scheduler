//
//  HomeScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 2.10.2020.
//

import Magpie
import SwiftUI

struct HomeScreen: View {
    @State
    private var mode: Mode = .menu

    let zoomAPI: ZoomAPI
    let googleAPI: GoogleAPI

    var body: some View {
        Group {
            switch mode {
                case .menu:
                    MenuScreen(
                        mode: $mode,
                        zoomAPI: zoomAPI,
                        googleAPI: googleAPI
                    )
                case .newEvent:
                    ScheduleMeetingScreen(
                        mode: $mode,
                        zoomAPI: zoomAPI,
                        googleAPI: googleAPI
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension HomeScreen {
    enum Mode {
        case menu
        case newEvent
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(
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
        .frame(width: windowSize.width, height: windowSize.height)
    }
}
