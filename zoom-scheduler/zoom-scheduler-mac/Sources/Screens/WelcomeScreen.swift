//
//  HomeScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 29.09.2020.
//

import SwiftUI

struct WelcomeScreen: View {
    var onGetStarted: (() -> Void)

    var body: some View {
        VStack {
            Button(
                action: {
                    onGetStarted()
                },
                label: {
                    Text("Get Started")
                }
            )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

struct WelcomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen(onGetStarted: { })
    }
}
