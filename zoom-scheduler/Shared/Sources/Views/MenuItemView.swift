//
//  MenuItemView.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 2.10.2020.
//

import SwiftUI

struct MenuItemView: View {
    @Binding
    var isLoading: Bool

    let icon: String
    let iconSize: CGSize
    let title: String
    let shortcut: [String]?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Group {
                    if isLoading {
                        ActivityIndicator()
                            .frame(width: 30, height: 30)
                    } else {
                        Image(icon)
                    }
                }
                .frame(width: iconSize.width, height: iconSize.height)
                .background(Color("Views/Custom/MenuItemView/Background/primary"))
                .cornerRadius(24)
                .shadow(
                    color: Color("Views/Attributes/Shadow/tertiary"),
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
                    .foregroundColor(Color("Views/Custom/MenuItemView/title"))
                    .padding(.top, 18)

                if let shortcut = shortcut {
                    Group {
                        HStack(spacing: 4) {
                            ForEach(shortcut, id: \.self) {
                                Text($0)
                                    .font(.custom("SFProText-Semibold", size: 13))
                                    .kerning(-0.08)
                                    .foregroundColor(Color("Views/Custom/MenuItemView/title"))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color("Views/Custom/MenuItemView/Background/secondary"))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        MenuItemView(
            isLoading: .constant(false),
            icon: "Screens/Icons/quick_call",
            iconSize: CGSize(width: 96, height: 96),
            title: "Quick Call",
            shortcut: ["Q"],
            action: { }
        )
        .background(Color("Views/Attributes/Background/primary"))
    }
}
