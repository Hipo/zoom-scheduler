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
    private var isEditing = false

    var body: some View {
        TextInputView(
            text: $draft.name,
            title: "Event Name",
            placeholder: "Name"
        )
    }
}

struct EnterMeetingNameView_Previews: PreviewProvider {
    static var previews: some View {
        EnterMeetingNameView(draft: .constant(CreateMeetingDraft(reason: .scheduled)))
            .background(Color("Screens/Attributes/Background/primary"))
    }
}
