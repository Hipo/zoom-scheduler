//
//  LogoView.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 1.10.2020.
//

import SwiftUI

struct LogoView: View {
    @State
    var icon: String?
    @State
    var offset: CGPoint = .zero

    var body: some View {
        Group {
            if let icon = icon {
                Image(icon)
                    .offset(x: offset.x, y: offset.y)
                    .shadow(
                        color: Color("Views/Attributes/Shadow/secondary"),
                        radius: 12,
                        x: 0,
                        y: 4
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color("Views/Custom/LogoView/Background/gradient_1"),
                        Color("Views/Custom/LogoView/Background/gradient_2")
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(24)
        .shadow(
            color: Color("Views/Attributes/Shadow/primary"),
            radius: 100,
            x: 0,
            y: 20
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color("Views/Custom/LogoView/Border/gradient_1"),
                                Color("Views/Custom/LogoView/Border/gradient_2")
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 2
                )
        )
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView(icon: "Screens/Icons/logo", offset: CGPoint(x: 3.0, y: 2.0))
            .frame(width: 100, height: 100)
    }
}
