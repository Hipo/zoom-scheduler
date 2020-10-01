//
//  EnterMeetingParticipantsView.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 1.10.2020.
//

import SwiftUI

struct EnterMeetingInviteesView: View {
    @ObservedObject
    var meeting: Meeting

    @State
    private var emailInput = ""

    var body: some View {
        VStack {
            Text("Meeting Invitees")

            TextField(
                "Emails",
                text: $emailInput,
                onCommit: extractValidEmails
            )

            HStack {
                VStack(alignment: .leading) {
                    ForEach(meeting.invitees, id: \.email) { invitee in
                        MeetingInviteeView(invitee: invitee) {
                            if let idx = meeting.invitees.firstIndex(of: invitee) {
                                meeting.invitees.remove(at: idx)
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

extension EnterMeetingInviteesView {
    private func extractValidEmails() {
        let validator = EmailValidator()

        meeting.invitees += emailInput.components(separatedBy: ",").compactMap { input in
            let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
            return validator.validate(trimmedInput) ? Meeting.Invitee(email: trimmedInput) : nil
        }

        emailInput = ""
    }
}

struct MeetingInviteeView: View {
    var invitee: Meeting.Invitee
    var onRemove: () -> Void

    var body: some View {
        HStack {
            Text(invitee.email)

            Button("X") {
                onRemove()
            }
        }
    }
}

struct EnterMeetingInviteesView_Previews: PreviewProvider {
    static var previews: some View {
        EnterMeetingInviteesView(meeting: Meeting())
    }
}
