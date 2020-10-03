//
//  SelectCalendarView.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 2.10.2020.
//

import SwiftUI

struct SelectCalendarView: View {
    @ObservedObject
    var meeting: Meeting
    @ObservedObject
    var googleCalendarAPI: GoogleCalendarAPI

    @State
    private var isEditing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Calendar")
                .font(.custom("SFProText-Regular", size: 13))
                .kerning(-0.08)
                .lineSpacing(3.5)
                .foregroundColor(Color("Views/TextField/Placeholder/primary"))

            HStack {
                Text(meeting.calendar?.name ?? "")
                    .font(.custom("SFProText-Regular", size: 15))
                    .foregroundColor(Color("Views/TextField/Input/primary"))

                Spacer()

                Image("Screens/Accessories/dropdown")
            }
            .padding(.horizontal, 10)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(Color("Views/TextField/Background/primary"))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isEditing ? Color("Views/TextField/Border/Editing/primary") : Color("Views/TextField/Border/primary"),
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isEditing ?  Color("Views/TextField/Shadow/primary") : Color.clear,
                radius: 4,
                x: 0.0,
                y: 0.0
            )
            .onTapGesture {
                isEditing.toggle()
            }

            if isEditing {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(googleCalendarAPI.calendars) { calendar in
                        CalendarView(calendar: calendar, isSelected: meeting.calendar == calendar)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color("Views/Attributes/Background/primary"))
                            .onTapGesture {
                                meeting.calendar = calendar
                                isEditing = false
                            }
                    }
                }
                .padding(.leading, 16)
                .background(Color("Views/Attributes/Background/primary"))
                .cornerRadius(12)
                .padding(.top, 12)
            }
        }
    }
}

struct CalendarView: View {
    let calendar: GCalendar
    let isSelected: Bool

    var body: some View {
        HStack {
            Text(calendar.name)
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
            meeting: Meeting(),
            googleCalendarAPI: GoogleCalendarAPI()
        )
        .background(Color("Screens/Attributes/Background/primary"))
    }
}