//
//  SelectCalendarView.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 2.10.2020.
//

import Magpie
import SwiftUI

struct SelectCalendarView: View {
    @EnvironmentObject
    var session: Session

    @Binding
    var draft: CreateEventDraft

    @State
    private var isEditing = false

    @State
    private var status: CalendarsStatus = .ready

    let googleAPI: GoogleAPI

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Calendar")
                .font(.custom("SFProText-Regular", size: 13))
                .kerning(-0.08)
                .lineSpacing(3.5)
                .foregroundColor(Color("Views/TextField/Placeholder/primary"))

            HStack {
                if let color = draft.calendar?.color {
                    Circle()
                        .fill(color)
                        .frame(width: 6, height: 6)
                }

                Text(draft.calendar?.title ?? "")
                    .font(.custom("SFProText-Regular", size: 15))
                    .foregroundColor(Color("Views/TextField/Input/primary"))

                Spacer()

                Image("Screens/Accessories/dropdown")
            }
            .padding(.leading, 16)
            .padding(.trailing, 10)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
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
            .onTapGesture {
                isEditing.toggle()
            }

            if isEditing {
                Group {
                    switch status {
                        case .loading:
                            VStack {
                                ActivityIndicator()
                                    .frame(width: 20, height: 20)
                                    .padding(.top, 20)

                                Spacer()
                            }
                        case .failed(let error):
                            VStack(spacing: 16) {
                                Text(error.localizedDescription)
                                    .font(.custom("SFProText-Medium", size: 11))
                                    .kerning(-0.08)
                                    .lineSpacing(3.5)
                                    .foregroundColor(Color("Views/Text/Body/primary"))
                                    .multilineTextAlignment(.center)

                                Button(action: loadCalendars) {
                                    Text("Try Again")
                                        .font(.custom("SFProText-Medium", size: 11))
                                        .foregroundColor(Color("Views/Button/Title/tertiary"))
                                        .kerning(-0.08)
                                        .padding(10)
                                        .background(Color("Views/Button/Background/secondary"))
                                }
                                .buttonStyle(PlainButtonStyle())
                                .cornerRadius(6)
                            }
                            .padding(.horizontal, 16)
                        case .ready:
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(session.googleCalendars) { calendar in
                                        CalendarView(calendar: calendar, isSelected: draft.calendar == calendar)
                                            .padding(.vertical, 8)
                                            .background(Color("Views/Attributes/Background/primary"))
                                            .onTapGesture {
                                                draft.calendar = calendar
                                                isEditing = false
                                            }
                                    }
                                }
                            }
                            .colorScheme(.dark)
                            .padding(.leading, 16)
                    }
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(Color("Views/Attributes/Background/primary"))
                .cornerRadius(12)
            }
        }
        .onAppear(perform: loadCalendars)
    }
}

extension SelectCalendarView {
    private func loadCalendars() {
        status = session.googleCalendars.isEmpty ? .loading : .ready

        googleAPI.loadCalendars { error in
            if let error = error {
                status = .failed(error)
            } else {
                status = .ready
            }
        }
    }
}

extension SelectCalendarView {
    private enum CalendarsStatus {
        case loading
        case failed(Error)
        case ready
    }
}

private struct CalendarView: View {
    let calendar: GoogleCalendar
    let isSelected: Bool

    var body: some View {
        HStack {
            Text(calendar.title ?? "No Title")
                .font(.custom("SFProText-Regular", size: 13))
                .kerning(-0.24)
                .lineSpacing(7.5)
                .foregroundColor(Color("Views/TextField/Input/primary"))

            Spacer()

            if isSelected {
                Image("Screens/Accessories/checkmark")
                    .foregroundColor(.white)
            }
        }
        .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
    }
}

struct SelectCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        SelectCalendarView(
            draft: .constant(CreateEventDraft()),
            googleAPI: GoogleAPI(
                config: GoogleConfig(),
                session: Session(
                    keychain: HIPKeychain(identifier: "preview"),
                    userCache: HIPCache()
                )
            )
        )
        .frame(width: 350)
        .background(Color("Screens/Attributes/Background/primary"))
        .environmentObject(
            Session(
                keychain: HIPKeychain(identifier: "preview"),
                userCache: HIPCache()
            )
        )
    }
}
