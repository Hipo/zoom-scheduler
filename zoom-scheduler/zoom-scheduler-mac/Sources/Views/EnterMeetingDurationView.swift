//
//  EnterMeetingDurationView.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 2.10.2020.
//

import SwiftUI

struct EnterMeetingDurationView: View {
    @ObservedObject
    var meeting: Meeting

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .lastTextBaseline) {
                Text("Duration")
                    .font(.custom("SFProText-Regular", size: 13))
                    .kerning(-0.08)
                    .lineSpacing(3.5)
                    .foregroundColor(Color("Views/TextField/Placeholder/primary"))

                Spacer()
            }

            HStack {
                HStack(spacing: 12) {
                    ForEach(Meeting.Duration.all, id: \.self) { duration in
                        Button(action: {
                            meeting.duration = duration
                        }) {
                            Text(duration.description)
                                .font(.custom("SFProText-Regular", size: 13))
                                .kerning(-0.08)
                                .foregroundColor(Color("Views/Custom/EnterMeetingDurationView/Button/Title/primary"))
                                .padding(.horizontal, 10)
                                .frame(height: 34)
                                .background(meeting.duration == duration ? Color("Views/Custom/EnterMeetingDurationView/Button/Background/selected") : Color.clear)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    meeting.duration == duration
                                        ? Color.clear
                                        : Color("Views/Button/Border/primary"),
                                    lineWidth: 2
                                )
                        )
                    }
                }
            }
        }
    }
}

struct EnterMeetingDurationView_Previews: PreviewProvider {
    static var previews: some View {
        EnterMeetingDurationView(meeting: Meeting())
            .background(Color("Screens/Attributes/Background/primary"))
    }
}
