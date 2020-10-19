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

    @Binding
    var mode: HomeScreen.Mode

    @State
    private var meetingDraft = CreateMeetingDraft(reason: .scheduled)
    @State
    private var isCreatingMeeting = false
    @State
    private var lastMeetingResult: Swift.Result<URL?, ZoomAPIError>?

    @State
    private var eventDraft = CreateEventDraft()
    @State
    private var isCreatingEvent = false
    @State
    private var lastEventResult: Swift.Result<Bool, Error>?

    var isCreating: Bool {
        return isCreatingMeeting || isCreatingEvent
    }

    let zoomAPI: ZoomAPI
    let googleAPI: GoogleAPI

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack (alignment: .leading, spacing: 24){
                        Text("Schedule Event")
                            .font(.custom("SFProDisplay-Medium", size: 28))
                            .kerning(0.37)
                            .foregroundColor(Color("Views/Text/Title/primary"))

                        EnterMeetingNameView(draft: $meetingDraft)
                            .padding(.top, 10)
                            .focusable()

                        EnterMeetingDateView(draft: $meetingDraft)
                            .focusable()

                        EnterMeetingDurationView(draft: $meetingDraft)

                        if session.isGoogleAccountConnected {
                            SelectCalendarView(
                                draft: $eventDraft,
                                googleAPI: googleAPI
                            )

                            EnterMeetingInviteesView(draft: $eventDraft)
                                .focusable()
                        }

                        VStack(spacing: 16) {
                            Button(action: createMeeting) {
                                if isCreating {
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
                            .disabled(!session.isAuthorized)
                            .allowsHitTesting(!isCreating)

                            Button(action: cancel) {
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 10) {
                    if let result = lastMeetingResult {
                        switch result {
                            case .success:
                                ToastView(
                                    feedback: InAppFeedback(
                                        reason: .info,
                                        message: "Zoom url is copied to pasteboard.",
                                        actionName: "OK",
                                        action: hideLastMeetingResult
                                    )
                                )
                            case .failure(let error):
                                ToastView(
                                    feedback: InAppFeedback(
                                        reason: .error,
                                        message: error.displayMessage,
                                        actionName: "OK",
                                        action: hideLastMeetingResult
                                    )
                                )
                        }
                    }

                    if let result = lastEventResult {
                        switch result {
                            case .success:
                                ToastView(
                                    feedback: InAppFeedback(
                                        reason: .info,
                                        message: "An event is created in the calendar.",
                                        actionName: "OK",
                                        action: hideLastEventResult
                                    )
                                )
                            case .failure(let error):
                                ToastView(
                                    feedback: InAppFeedback(
                                        reason: .error,
                                        message: error.localizedDescription,
                                        actionName: "Try Again",
                                        action: {
                                            hideLastEventResult()
                                            createEvent()
                                        }
                                    )
                                )
                        }
                    }

                    if let statusError = session.statusError {
                        ToastView(
                            feedback: InAppFeedback(
                                reason: .error,
                                message: statusError.displayMessage,
                                actionName: "OK",
                                action: session.hideStatusError
                            )
                        )
                    }

                    if let googleAuthorizationStatusError = session.googleAuthorizationStatusError {
                        ToastView(
                            feedback: InAppFeedback(
                                reason: .error,
                                message: googleAuthorizationStatusError.localizedDescription,
                                actionName: "Try Again",
                                action: toggleGoogleAuthorization
                            )
                        )
                    }
                }
                .frame(maxWidth: geometry.size.width * 0.8)
                .alignmentGuide(.bottom) { $0[.bottom] + 10 }
            }
        }
        .colorScheme(.dark)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDisappear {
            hideLastResult()
        }
        .onReceive(NotificationCenter.default.publisher(for: .save)) { _ in
            if canCreateMeeting() {
                createMeeting()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .cancel)) { _ in
            cancel()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
        ) { _ in
            hideLastResult()
        }
    }
}

extension ScheduleMeetingScreen {
    private func canCreateMeeting() -> Bool {
        return session.isAuthorized && !isCreating
    }

    private func createMeeting() {
        hideLastResult()

        isCreatingMeeting = true

        zoomAPI.createMeeting(meetingDraft) { result in
            isCreatingMeeting = false

            switch result {
                case .success(let zoomMeeting):
                    zoomMeeting.copyToClipboard()
                    lastMeetingResult = .success(zoomMeeting.joinUrl)

                    eventDraft.title = zoomMeeting.topic
                    eventDraft.startDateTime = zoomMeeting.startTime
                    eventDraft.endDateTime = zoomMeeting.endTime
                    eventDraft.zoomJoinUrl = zoomMeeting.joinUrl

                    createEvent()
                case .failure(let apiError, let apiErrorDetail):
                    isCreatingEvent = false

                    let error = ZoomAPIError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                    lastMeetingResult = .failure(error)
            }
        }
    }

    private func createEvent() {
        if !session.isGoogleAccountConnected || eventDraft.calendar == nil {
            isCreatingEvent = false
            return
        }

        isCreatingEvent = true
        googleAPI.createEvent(eventDraft) { error in
            isCreatingEvent = false

            if let error = error {
                lastEventResult = .failure(error)
            } else {
                lastEventResult = .success(true)
            }
        }
    }

    private func cancel() {
        mode = .menu
    }
}

extension ScheduleMeetingScreen {
    private func hideLastResult() {
        hideLastMeetingResult()
        hideLastEventResult()
    }

    private func hideLastMeetingResult() {
        lastMeetingResult = nil
    }

    private func hideLastEventResult() {
        lastEventResult = nil
    }
}

extension ScheduleMeetingScreen {
    private func toggleGoogleAuthorization() {
        session.hideGoogleAuthorizationStatusError()

        if session.isGoogleAccountConnected {
            googleAPI.revokeAuthorization()
        } else {
            googleAPI.requestAuthorization()
        }
    }
}

struct ScheduleMeetingScreen_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleMeetingScreen(
            mode: .constant(.newEvent),
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
            )
        )
        .background(Color("Screens/Attributes/Background/primary"))
        .frame(width: windowSize.width, height: windowSize.height)
    }
}
