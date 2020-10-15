//
//  HomeScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 29.09.2020.
//

import Magpie
import SwiftUI

struct WelcomeScreen: View {
    @EnvironmentObject
    var session: Session

    let zoomAPI: ZoomAPI

    var body: some View {
        VStack {
            LogoView(
                icon: "Screens/Icons/logo",
                offset: CGPoint(x: 3.0, y: 2.0)
            )
            .frame(width: 80, height: 80)
            .padding(.bottom, 40)

            Text("Welcome to Zoom Scheduler")
                .font(.custom("SFProDisplay-Medium", size: 34))
                .kerning(0.37)
                .foregroundColor(Color("Views/Text/Title/primary"))
                .padding(.bottom, 20)

            Text("Scheduler is a Mac app for quickly creating calendar\nevents with attached Zoom calls.")
                .font(.custom("SFProText-Regular", size: 15))
                .kerning(-0.24)
                .lineSpacing(6.5)
                .foregroundColor(Color("Views/Text/Body/primary"))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .padding(.bottom, 40)

            Button(action: {
                zoomAPI.requestAuthorization()
            }) {
                HStack {
                    switch session.status {
                        case .connecting:
                            ActivityIndicator()
                                .frame(
                                    width: 30,
                                    height: 30
                                )
                        default:
                            Image("Screens/Icons/zoom")

                            Text(session.isAuthorized ? "Connected" : "Sign in Zoom Account")
                                .font(.custom("SFProText-Medium", size: 15))
                                .kerning(-0.24)
                                .lineSpacing(6.5)
                                .foregroundColor(Color("Views/Button/Title/primary"))
                    }
                }
                .frame(width: 240, height: 52)
                .background(Color("Views/Button/Background/primary"))
            }
            .buttonStyle(PlainButtonStyle())
            .cornerRadius(8)
            .allowsHitTesting(session.isUnauthorized)

            if let error = session.error {
                Text("We couldn't sign in. Please try again.")
                    .font(.custom("SFProText-Regular", size: 16))
                    .foregroundColor(Color("Views/Text/Error/primary"))
                    .padding(.top, 10)
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

struct WelcomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen(
            zoomAPI: ZoomAPI(
                config: ZoomConfig(),
                session: Session(keychain: HIPKeychain(identifier: "preview"))
            )
        )
        .frame(
            width: windowSize.width,
            height: windowSize.height
        )
    }
}
