//
//  TextInputView.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 23.10.2020.
//

import SwiftUI

struct TextInputView: View {
    @Binding
    var text: String

    @State
    private var isEditing = false

    let title: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("SFProText-Regular", size: 13))
                .kerning(-0.08)
                .lineSpacing(3.5)
                .foregroundColor(Color("Views/TextField/Placeholder/primary"))

            Group {
                TextField(
                    placeholder,
                    text: $text,
                    onEditingChanged: { editing in
                        isEditing = editing
                    }
                )
                .textFieldStyle(PlainTextFieldStyle())
                .font(.custom("SFProText-Regular", size: 15))
                .foregroundColor(Color("Views/TextField/Input/primary"))
                .frame(height: 44)
                .padding(.horizontal, 16)
            }
            .background(Color("Views/TextField/Background/primary"))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isEditing
                            ? Color("Views/TextField/Border/Editing/primary")
                            : Color("Views/TextField/Border/primary"),
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isEditing
                    ? Color("Views/TextField/Shadow/primary")
                    : Color.clear,
                radius: 4,
                x: 0.0,
                y: 0.0
            )
        }
        .colorScheme(.dark)
    }
}

struct TextInputView_Previews: PreviewProvider {
    static var previews: some View {
        TextInputView(
            text: .constant(""),
            title: "",
            placeholder: "Placeholder"
        )
        .background(Color("Screens/Attributes/Background/primary"))
    }
}
