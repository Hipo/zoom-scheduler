//
//  HomeScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 2.10.2020.
//

import Magpie
import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject
    var session: Session

    @State
    private var mode: Mode = .menu

    let zoomAPI: ZoomAPI
    let googleAPI: GoogleAPI

    var body: some View {
        Group {
            switch session.status {
                case .authorized:
                    switch mode {
                        case .menu:
                            MenuScreen(zoomAPI: zoomAPI) {
                                mode = .newEvent
                            }
                        case .newEvent:
                            ScheduleMeetingScreen(
                                zoomAPI: zoomAPI,
                                googleAPI: googleAPI,
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
        .frame(
            width: windowSize.width,
            height: windowSize.height
        )
    }
}
