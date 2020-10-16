//
//  IntroScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 29.09.2020.
//

import Magpie
import SwiftUI

struct ScheduleMeetingScreen: View {
    @EnvironmentObject
    var session: Session

    @State
    private var meetingDraft = CreateMeetingDraft(reason: .scheduled)
    @State
    private var eventDraft = CreateEventDraft()

    @State
    private var isCreatingMeeting = false

    let zoomAPI: ZoomAPI
    let googleAPI: GoogleAPI

    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ScrollView {
            VStack (alignment: .leading, spacing: 24){
                Text("Schedule Event")
                    .font(.custom("SFProDisplay-Medium", size: 28))
                    .kerning(0.37)
                    .foregroundColor(Color("Views/Text/Title/primary"))

                EnterMeetingNameView(draft: $meetingDraft)
                    .padding(.top, 10)

                EnterMeetingDateView(draft: $meetingDraft)

                EnterMeetingDurationView(draft: $meetingDraft)

                SelectCalendarView(
                    draft: $eventDraft,
                    googleAPI: googleAPI
                )

                EnterMeetingInviteesView(draft: $eventDraft)

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
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color("Views/Button/Background/primary"))
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

        zoomAPI.createMeeting(meetingDraft) { result in
            isCreatingMeeting = false

            switch result {
                case .success(let zoomMeeting):
                    if let joinURL = zoomMeeting.joinUrl {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(joinURL.absoluteString, forType: .string)
                    }

                    if session.isGoogleAccountConnected, eventDraft.calendar != nil {
                        eventDraft.title = zoomMeeting.topic
                        eventDraft.startDateTime = zoomMeeting.startTime
                        eventDraft.endDateTime = zoomMeeting.endTime
                        eventDraft.zoomJoinUrl = zoomMeeting.joinUrl

                        googleAPI.createEvent(eventDraft) { _ in
                        }
                    }
                    onSave()
                case .failure(let apiError, let apiErrorDetail):
                    break
            }
        }
    }
}

struct ScheduleMeetingScreen_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleMeetingScreen(
            zoomAPI: ZoomAPI(
                config: ZoomConfig(),
                session: Session(
                    keychain: HIPKeychain(identifier: "preview"),
                    userCache: HIPCache()
                )
            ),
            googleAPI: GoogleAPI(
                config: GoogleConfig(),
                session: Session(
                    keychain: HIPKeychain(identifier: "preview"),
                    userCache: HIPCache()
                )
            ),
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
