//
//  MenuScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 2.10.2020.
//

import AppKit
import SwiftUI

struct MenuScreen: View {
    @ObservedObject
    var zoomAPI: ZoomAPI

    @State
    private var quickCallMenuIcon = "Screens/Icons/quick_call"
    @State
    private var quickCallMenuTitle = "Quick Call"
    @State
    private var newEventMenuIcon = "Screens/Icons/new_event"
    @State
    private var newEventMenuTitle = "New Event"
    @State
    private var menuItemSize = CGSize(width: 96, height: 96)

    @State
    private var isCreatingNewQuickMeeting = false

    var onClickNewEvent: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 72) {
            MenuItemView(
                icon: $quickCallMenuIcon,
                iconSize: $menuItemSize,
                title: $quickCallMenuTitle,
                isLoading: $isCreatingNewQuickMeeting,
                onClick: createQuickMeeting
            )

            MenuItemView(
                icon: $newEventMenuIcon,
                iconSize: $menuItemSize,
                title: $newEventMenuTitle,
                isLoading: .constant(false),
                onClick: onClickNewEvent
            )
            .disabled(isCreatingNewQuickMeeting)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

extension MenuScreen {
    func createQuickMeeting() {
        isCreatingNewQuickMeeting = true

        zoomAPI.createQuickMeeting { zoomMeeting in
            isCreatingNewQuickMeeting = false

            if let joinURL = zoomMeeting?.joinUrl {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(joinURL.absoluteString, forType: .string)
            }
        }
    }
}

struct MenuScreen_Previews: PreviewProvider {
    static var previews: some View {
        MenuScreen(
            zoomAPI: ZoomAPI()
        ) {
        }
        .frame(
            width: windowSize.width,
            height: windowSize.height
        )
    }
}
