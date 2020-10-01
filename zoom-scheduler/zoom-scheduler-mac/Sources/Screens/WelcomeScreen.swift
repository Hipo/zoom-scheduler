//
//  HomeScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 29.09.2020.
//

import SwiftUI

struct WelcomeScreen: View {
    @ObservedObject
    var zoomAPI: ZoomAPI

    var body: some View {
        VStack {
            LogoView(icon: "Screens/Icons/logo")
                .frame(width: 80, height: 80)
                .padding(.bottom, 40)

            Text("Welcome to Zoom Scheduler")
                .font(.custom("SFProDisplay-Medium", size: 34))
                .foregroundColor(Color("Views/Text/Title/primary"))
                .kerning(0.37)
                .padding(.bottom, 20)

            Text("Scheduler is a Mac app for quickly creating calendar\nevents with attached Zoom calls.")
                .font(.custom("SFProText-Regular", size: 15))
                .foregroundColor(Color("Views/Text/Body/primary"))
                .kerning(-0.24)
                .lineSpacing(6.5)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .padding(.bottom, 40)

            Button(action: {
                zoomAPI.launchAuthFlow()
            }) {
                HStack {
                    if zoomAPI.authState == .connecting {
                        ActivityIndicator()
                            .frame(
                                width: 30,
                                height: 30
                            )
                    } else {
                        Image("Screens/Icons/zoom")

                        Text(zoomAPI.authState == .success ? "Connected" : "Sign in Zoom Account")
                            .font(.custom("SFProText-Medium", size: 15))
                            .foregroundColor(Color("Views/Button/Title/primary"))
                            .kerning(-0.24)
                            .lineSpacing(6.5)
                    }
                }
                .frame(width: 240, height: 52)
                .background(Color("Views/Button/Background/primary"))
            }
            .buttonStyle(PlainButtonStyle())
            .cornerRadius(8)
            .disabled(zoomAPI.authState == .connecting || zoomAPI.authState == .success)

            if zoomAPI.authState == .failed {
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
        WelcomeScreen(zoomAPI: ZoomAPI())
            .frame(
                width: windowSize.width,
                height: windowSize.height
            )
    }
}
