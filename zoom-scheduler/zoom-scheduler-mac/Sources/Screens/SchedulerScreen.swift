//
//  IntroScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 29.09.2020.
//

import SwiftUI

struct SchedulerScreen: View {
    @ObservedObject
    private var meeting = Meeting()

    var body: some View {
        VStack (spacing: 30){
            EnterMeetingNameView(meeting: meeting)

            EnterMeetingDateView(meeting: meeting)

            EnterMeetingInviteesView(meeting: meeting)
        }
        .padding(.horizontal, 10)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

struct SchedulerScreen_Previews: PreviewProvider {
    static var previews: some View {
        SchedulerScreen()
    }
}
