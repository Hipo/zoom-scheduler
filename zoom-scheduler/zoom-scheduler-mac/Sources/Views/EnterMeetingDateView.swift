//
//  EnterMeetingDateView.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 1.10.2020.
//

import SwiftUI

struct EnterMeetingDateView: View {
    @ObservedObject
    var meeting: Meeting

    var body: some View {
        VStack {
            DatePicker(
                "Meeting Date",
                selection: $meeting.date,
                in: Date()...,
                displayedComponents: .date
            )

            HStack {
                Text("Duration")

                HStack {
                    ForEach(Meeting.Duration.allCases, id: \.self) { duration in
                        Button(duration.description) {
                            meeting.duration = duration
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        .background(meeting.duration == duration ? Color.orange : Color.yellow)
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
}

struct EnterMeetingDateView_Previews: PreviewProvider {
    static var previews: some View {
        EnterMeetingDateView(meeting: Meeting())
    }
}
