//
//  SyncGoogleCalendarScreen.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 1.10.2020.
//

import Magpie
import SwiftUI

struct SyncGoogleCalendarScreen: View {
    @EnvironmentObject
    var session: Session

    let preferences: Preferences
    let googleAPI: GoogleAPI

    var body: some View {
        VStack {
            HStack {
                LogoView(icon: "Screens/Icons/calendar")
                    .frame(width: 80, height: 80)

                Image("Screens/Accessories/arrow-right")
                    .padding(.horizontal, 30)

                LogoView(
                    icon: "Screens/Icons/logo",
                    offset: CGPoint(x: 3.0, y: 2.0)
                )
                .frame(width: 80, height: 80)
            }
            .padding(.bottom, 40)

            Text("Sync Google Calendar")
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
                googleAPI.requestAuthorization()
            }) {
                HStack {
                    Image("Screens/Icons/google")

                    Spacer()

                    Text(session.isGoogleAuthorized ? "Connected" : "Sign in with Google")
                        .font(.custom("SFProText-Medium", size: 15))
                        .kerning(-0.24)
                        .lineSpacing(6.5)
                        .foregroundColor(Color("Views/Button/Title/primary"))
                        .padding()

                    Spacer()
                }
                .frame(width: 240, height: 52)
                .background(Color("Views/Button/Background/primary"))
            }
            .buttonStyle(PlainButtonStyle())
            .cornerRadius(8)
            .allowsHitTesting(!session.isGoogleAuthorized)

            if session.isGoogleUnauthorized {
                Text("We couldn't sign in. Please try again.")
                    .font(.custom("SFProText-Regular", size: 16))
                    .foregroundColor(Color("Views/Text/Error/primary"))
                    .padding(.top, 10)
            }

            if !session.isGoogleAuthorized {
                Button(action: {
                    preferences.skipsSyncingGoogleCalendar = true
                }) {
                    Text("Skip for now")
                        .font(.custom("SFProText-Regular", size: 13))
                        .kerning(-0.08)
                        .foregroundColor(Color("Views/Button/Title/secondary"))
                        .padding()
                        .background(Color.clear)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 6)
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

struct SyncGoogleCalendarScreen_Previews: PreviewProvider {
    static var previews: some View {
        SyncGoogleCalendarScreen(
            preferences: Preferences(userCache: nil),
            googleAPI: GoogleAPI(
                config: GoogleConfig(),
                session: Session(keychain: HIPKeychain(identifier: "preview"))
            )
        )
        .frame(
            width: windowSize.width,
            height: windowSize.height
        )
    }
}
