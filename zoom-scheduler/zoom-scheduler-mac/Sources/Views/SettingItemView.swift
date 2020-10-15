//
//  SettingItemView.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 15.10.2020.
//

import SwiftUI

struct SettingItemView: View {
    @State
    private var isHighlighted = false

    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.custom("SFProText-Regular", size: 13))
                    .kerning(-0.08)
                    .foregroundColor(Color("Views/Button/Title/primary"))

                Spacer()
            }
            .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 0))
            .background(
                Color(isHighlighted
                        ? "Views/Custom/SettingItemView/Background/highlighted"
                        : "Views/Custom/SettingItemView/Background/normal"
                )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHighlighted = hovering
        }
    }
}

struct SettingItemView_Previews: PreviewProvider {
    static var previews: some View {
        SettingItemView(
            title: "Action",
            action: { }
        )
        .frame(width: 100)
    }
}
