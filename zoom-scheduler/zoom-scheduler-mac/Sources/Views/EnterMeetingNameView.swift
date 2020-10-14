//
//  EnterMeetingNameView.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 1.10.2020.
//

import SwiftUI

struct EnterMeetingNameView: View {
    @Binding
    var draft: CreateMeetingDraft

    @State
    private var name = ""
    @State
    private var isEditing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Event Name")
                .font(.custom("SFProText-Regular", size: 13))
                .kerning(-0.08)
                .lineSpacing(3.5)
                .foregroundColor(Color("Views/TextField/Placeholder/primary"))

            Group {
                TextField(
                    "Name",
                    text: $draft.name,
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
                        isEditing ? Color("Views/TextField/Border/Editing/primary") : Color("Views/TextField/Border/primary"),
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isEditing ?  Color("Views/TextField/Shadow/primary") : Color.clear,
                radius: 4,
                x: 0.0,
                y: 0.0
            )
        }
    }
}

struct EnterMeetingNameView_Previews: PreviewProvider {
    static var previews: some View {
        EnterMeetingNameView(draft: .constant(CreateMeetingDraft(reason: .scheduled)))
            .background(Color("Screens/Attributes/Background/primary"))
    }
}
