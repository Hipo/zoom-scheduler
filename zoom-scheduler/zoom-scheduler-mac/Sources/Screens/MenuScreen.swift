//
//  MenuScreen.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 2.10.2020.
//

import AppKit
import Magpie
import SwiftUI

struct MenuScreen: View {
    @EnvironmentObject
    var session: Session

    let zoomAPI: ZoomAPI
    let onClickNewEvent: () -> Void

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
        zoomAPI.revokeAccessToken()
//        isCreatingNewQuickMeeting = true
//
//        let draft = CreateMeetingDraft(reason: .instant)
//        zoomAPI.createMeeting(draft) { result in
//            isCreatingNewQuickMeeting = false
//
//            switch result {
//                case .success(let zoomMeeting):
//                    if let joinURL = zoomMeeting.joinUrl {
//                        NSPasteboard.general.clearContents()
//                        NSPasteboard.general.setString(joinURL.absoluteString, forType: .string)
//                    }
//                case .failure(let apiError, let apiErrorDetail):
//                    break
//            }
//        }
    }
}

struct MenuScreen_Previews: PreviewProvider {
    static var previews: some View {
        MenuScreen(
            zoomAPI: ZoomAPI(
                config: ZoomConfig(),
                session: Session(keychain: HIPKeychain(identifier: "preview"))
            )
        ) { }
        .frame(
            width: windowSize.width,
            height: windowSize.height
        )
    }
}
