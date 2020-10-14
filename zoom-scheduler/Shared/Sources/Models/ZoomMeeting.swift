//
//  ZoomMeeting.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 14.10.2020.
//

import Foundation
import Magpie
import SwiftDate

final class ZoomMeeting: Model {
    var endTime: Date? {
        guard let startTime = startTime else { return nil }
        guard let duration = duration else { return nil }
        return startTime + duration.minutes
    }

    let topic: String?
    let startTime: Date?
    let duration: Int?
    let joinUrl: URL?
}
