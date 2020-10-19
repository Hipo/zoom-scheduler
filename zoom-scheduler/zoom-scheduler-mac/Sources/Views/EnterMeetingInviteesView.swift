//
//  EnterMeetingParticipantsView.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 1.10.2020.
//

import SwiftUI

struct EnterMeetingInviteesView: View {
    @Binding
    var draft: CreateEventDraft

    @State
    private var emailInput = ""
    @State
    private var isEditing = false

    var body: some View {
        let inviteesView = VStack(alignment: .leading, spacing: 0) {
            ForEach(draft.invitees, id: \.id) { invitee in
                MeetingInviteeView(invitee: invitee) {
                    if let idx = draft.invitees.firstIndex(of: invitee) {
                        draft.invitees.remove(at: idx)
                    }
                }
            }
        }
        .padding(.leading, 16)

        return VStack(alignment: .leading, spacing: 0) {
            Text("Invitees")
                .font(.custom("SFProText-Regular", size: 13))
                .kerning(-0.08)
                .lineSpacing(3.5)
                .foregroundColor(Color("Views/TextField/Placeholder/primary"))

            Group {
                TextField(
                    "Emails of invitees",
                    text: $emailInput,
                    onEditingChanged: { editing in
                        isEditing = editing
                    },
                    onCommit: extractValidEmails
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
            .padding(.top, 8)

            Group {
                if draft.invitees.count > 2 {
                    ScrollView {
                        inviteesView
                    }
                    .colorScheme(.dark)
                    .frame(height: 120)
                } else {
                    inviteesView
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color("Views/Attributes/Background/primary"))
            .cornerRadius(12)
            .padding(.top, 7)
        }
    }
}

extension EnterMeetingInviteesView {
    private func extractValidEmails() {
        let validator = EmailValidator()

        draft.invitees += emailInput.components(separatedBy: ",").compactMap { input in
            let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
            return validator.validate(trimmedInput)
                ? CreateEventDraft.Invitee(email: trimmedInput)
                : nil
        }

        emailInput = ""
    }
}

private struct MeetingInviteeView: View {
    var invitee: CreateEventDraft.Invitee
    var onRemove: () -> Void

    var body: some View {
        HStack {
            Text(invitee.email)
                .font(.custom("SFProText-Regular", size: 13))
                .kerning(-0.24)
                .lineSpacing(7.5)
                .foregroundColor(Color("Views/TextField/Input/primary"))

            Spacer()

            Button(action: onRemove) {
                Image("Screens/Accessories/remove")
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 32, height: 32)
        }
        .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
    }
}

struct EnterMeetingInviteesView_Previews: PreviewProvider {
    static var previews: some View {
        EnterMeetingInviteesView(draft: .constant(CreateEventDraft()))
            .background(Color("Screens/Attributes/Background/primary"))
    }
}
