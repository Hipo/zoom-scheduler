//
//  SignInZoomScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 29.09.2020.
//

import Magpie
import SwiftUI

struct SignInZoomScreen: View {
    @EnvironmentObject
    var session: Session

    @State
    private var draft = RequestAuthorizationDraft(method: .jwt)

    let zoomAPI: ZoomAPI

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
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
                        .padding(.bottom, 20)
                        .fixedSize(horizontal: false, vertical: true)

                    TextInputView(
                        text: $draft.jwt.apiKey,
                        title: "API Key",
                        placeholder: "Copy Your API Key Here"
                    )
                    .frame(width: 432)
                    .focusable()

                    TextInputView(
                        text: $draft.jwt.apiSecret,
                        title: "API Secret",
                        placeholder: "Copy Your API Secret Here"
                    )
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                    .frame(width: 432)
                    .focusable()

                    Button(action: requestAuthorization) {
                        HStack {
                            if session.isConnecting {
                                ActivityIndicator()
                                    .frame(width: 30, height: 30)
                            } else {
                                Image("Screens/Icons/zoom")

                                Text("Connect Zoom Account")
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
                    .disabled(!draft.isValid)
                    .allowsHitTesting(!session.isConnecting)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if let statusError = session.statusError {
                    ToastView(
                        feedback: InAppFeedback(
                            reason: .error,
                            message: statusError.displayMessage,
                            actionName: "OK",
                            action: session.hideStatusError
                        )
                    )
                    .frame(maxWidth: geometry.size.width * 0.8)
                    .alignmentGuide(.bottom) { $0[.bottom] + 10 }
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

extension SignInZoomScreen {
    private func requestAuthorization() {
        zoomAPI.requestAuthorization(draft)
    }
}

struct SignInZoomScreen_Previews: PreviewProvider {
    static var previews: some View {
        let windowSize = MainWindow.windowSize

        return SignInZoomScreen(
            zoomAPI: ZoomAPI(
                config: ZoomConfig(),
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
        .background(Color("Screens/Attributes/Background/primary"))
        .environmentObject(
            Session(
                keychain: HIPKeychain(identifier: "preview"),
                userCache: HIPCache()
            )
        )
    }
}
