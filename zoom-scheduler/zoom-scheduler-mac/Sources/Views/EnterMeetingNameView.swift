//
//  EnterMeetingNameView.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 1.10.2020.
//

import SwiftUI

struct EnterMeetingNameView: View {
    @ObservedObject
    var meeting: Meeting

    @State
    private var name = ""

    var body: some View {
        VStack {
            TextField(
                "Meeting Name",
                text: $meeting.name
            )
            .multilineTextAlignment(.center)
        }
    }
}

struct EnterMeetingNameView_Previews: PreviewProvider {
    static var previews: some View {
        EnterMeetingNameView(meeting: Meeting())
    }
}
