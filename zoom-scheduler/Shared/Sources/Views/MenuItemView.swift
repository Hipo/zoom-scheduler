//
//  MenuItemView.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 2.10.2020.
//

import SwiftUI

struct MenuItemView: View {
    @Binding
    var icon: String
    @Binding
    var iconSize: CGSize
    @Binding
    var title: String
    @Binding
    var isLoading: Bool

    var onClick: () -> Void

    var body: some View {
        Button(action: {
            onClick()
        }) {
            VStack {
                Group {
                    if isLoading {
                        ActivityIndicator()
                            .frame(
                                width: 30,
                                height: 30
                            )
                    } else {
                        Image(icon)
                    }
                }
                .frame(
                    width: iconSize.width,
                    height: iconSize.height
                )
                .background(Color("Views/Custom/MenuItemView/background"))
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

                Text(title)
                    .font(.custom("SFProText-Regular", size: 13))
                    .kerning(-0.08)
                    .lineSpacing(7.5)
                    .foregroundColor(Color("Views/Custom/MenuItemView/title"))
                    .padding(.top, 12)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        MenuItemView(
            icon: .constant("Screens/Icons/quick_call"),
            iconSize: .constant(CGSize(width: 96, height: 96)),
            title: .constant("Quick Call"),
            isLoading: .constant(true)
        ) {
        }
    }
}
