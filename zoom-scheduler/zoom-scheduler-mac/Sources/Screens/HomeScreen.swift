//
//  HomeScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 2.10.2020.
//

import SwiftUI

struct HomeScreen: View {
    @ObservedObject
    var zoomAPI: ZoomAPI

    @State
    private var mode: Mode = .menu

    var body: some View {
        Group {
            switch zoomAPI.authState {
                case .success:
                    switch mode {
                        case .menu:
                            MenuScreen(zoomAPI: zoomAPI) {
                                mode = .newEvent
                            }
                        case .newEvent:
                            SchedulerScreen()
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
        HomeScreen(zoomAPI: ZoomAPI())
            .frame(
                width: windowSize.width,
                height: windowSize.height
            )
    }
}
