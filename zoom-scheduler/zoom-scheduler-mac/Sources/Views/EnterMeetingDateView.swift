//
//  EnterMeetingDateView.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 1.10.2020.
//

import SwiftUI

struct EnterMeetingDateView: View {
    @Binding
    var draft: CreateMeetingDraft

    var body: some View {
        VStack(alignment: .leading) {
            Text("Event Name")
                .font(.custom("SFProText-Regular", size: 13))
                .kerning(-0.08)
                .lineSpacing(3.5)
                .foregroundColor(Color("Views/TextField/Placeholder/primary"))

            DatePicker(
                "",
                selection: $draft.date,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(StepperFieldDatePickerStyle())
        }
    }
}

struct EnterMeetingDateView_Previews: PreviewProvider {
    static var previews: some View {
        EnterMeetingDateView(draft: .constant(CreateMeetingDraft(reason: .scheduled)))
            .background(Color("Screens/Attributes/Background/primary"))
    }
}
