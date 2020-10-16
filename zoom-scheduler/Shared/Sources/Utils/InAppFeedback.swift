//
//  InAppFeedback.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 16.10.2020.
//

import Foundation
import SwiftUI

struct InAppFeedback {
    typealias Action = () -> Void

    var backgroundColor: Color {
        switch reason {
            case .info:
                return Color("Views/Toast/Info/Background/primary")
            case .error:
                return Color("Views/Toast/Error/Background/primary")
        }
    }

    var foregroundColor: Color {
        switch reason {
            case .info:
                return Color("Views/Toast/Info/Foreground/primary")
            case .error:
                return Color("Views/Toast/Error/Foreground/primary")
        }
    }

    var actionColor: Color {
        switch reason {
            case .info:
                return Color("Views/Toast/Info/Action/primary")
            case .error:
                return Color("Views/Toast/Error/Action/primary")
        }
    }

    let reason: Reason
    let message: String
    let actionName: String
    let action: Action?

    init(
        reason: Reason,
        message: String,
        actionName: String = "OK",
        action: Action? = nil
    ) {
        self.reason = reason
        self.message = message
        self.actionName = actionName
        self.action = action
    }
}

extension InAppFeedback {
    enum Reason {
        case info
        case error
    }
}
