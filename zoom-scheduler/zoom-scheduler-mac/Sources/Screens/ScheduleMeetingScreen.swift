//
//  IntroScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 29.09.2020.
//

import SwiftUI

struct ScheduleMeetingScreen: View {
    @ObservedObject
    var zoomAPI: ZoomAPI
    @ObservedObject
    var googleCalendarAPI: GoogleCalendarAPI
    @ObservedObject
    private var meeting = Meeting(type: .scheduled)

    @State
    private var isCreatingMeeting = false

    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        ScrollView {
            VStack (alignment: .leading, spacing: 24){
                Text("Schedule Event")
                    .font(.custom("SFProDisplay-Medium", size: 28))
                    .kerning(0.37)
                    .foregroundColor(Color("Views/Text/Title/primary"))

                EnterMeetingNameView(meeting: meeting)
                    .padding(.top, 10)

                EnterMeetingDateView(meeting: meeting)

                EnterMeetingDurationView(meeting: meeting)

                EnterMeetingInviteesView(meeting: meeting)

                VStack(spacing: 16) {
                    Button(action: createMeeting) {
                        if isCreatingMeeting {
                            ActivityIndicator()
                                .frame(width: 30, height: 30)
                        } else {
                            Text("Save")
                                .font(.custom("SFProText-Medium", size: 15))
                                .kerning(-0.24)
                                .foregroundColor(Color("Views/Button/Title/primary"))
                                .frame(height: 44)
                                .frame(maxWidth: .infinity)
                                .background(Color("Views/Button/Background/primary"))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .cornerRadius(8)

                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.custom("SFProText-Medium", size: 15))
                            .kerning(-0.24)
                            .foregroundColor(Color("Views/Button/Title/secondary"))
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(Color("Screens/Attributes/Background/primary"))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 50)
            .frame(width: 312)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
        .colorScheme(.dark)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

extension ScheduleMeetingScreen {
    private func createMeeting() {
        isCreatingMeeting = true

        zoomAPI.createMeeting(meeting: meeting) { zoomMeeting in
            isCreatingMeeting = false

            guard let zoomMeeting = zoomMeeting else {
                return
            }

            if let joinURL = zoomMeeting.joinUrl {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(joinURL.absoluteString, forType: .string)
            }

//            if googleCalendarAPI.authState == .connected {
//                googleCalendarAPI.createEvent(
//                    meeting: zoomMeeting,
//                    attendeeEmails: <#T##[String]#>, inCalendar: <#T##GCalendar#>)
//            }
        }
    }
}

struct ScheduleMeetingScreen_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleMeetingScreen(
            zoomAPI: ZoomAPI(),
            googleCalendarAPI: GoogleCalendarAPI(),
            onSave: { },
            onCancel: { }
        )
        .background(Color("Screens/Attributes/Background/primary"))
        .frame(
            width: windowSize.width,
            height: windowSize.height
        )
    }
}
