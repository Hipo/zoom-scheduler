//
//  EventDrafts.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 15.10.2020.
//

import Foundation
import Magpie
import SwiftDate

struct CreateEventDraft: JSONObjectBody {
    var calendar: GoogleCalendar?
    var title: String?
    var startDateTime: Date?
    var endDateTime: Date?
    var zoomJoinUrl: URL?
    var invitees: [Invitee] = []

    var timeZone: String {
        return TimeZone.current.identifier
    }

    var bodyParams: [GoogleAPI.BodyParam] {
        var params: [GoogleAPI.BodyParam] = []
        params.append(.init(.summary, title, .setIfPresent))
        params.append(.init(.start, DateComponents(dateTime: startDateTime, timeZone: timeZone)))
        params.append(.init(.end, DateComponents(dateTime: endDateTime, timeZone: timeZone)))
        params.append(.init(.description, zoomJoinUrl?.absoluteString, .setIfPresent))
        params.append(.init(.location, zoomJoinUrl?.absoluteString, .setIfPresent))
        params.append(.init(.attendees, invitees))
        return params
    }
}

extension CreateEventDraft {
    struct Invitee: JSONObjectBody, Equatable {
        var bodyParams: [GoogleAPI.BodyParam] {
            var params: [GoogleAPI.BodyParam] = []
            params.append(.init(.email, email))
            return params
        }

        let id = UUID().uuidString
        let email: String
    }

    private struct DateComponents: JSONObjectBody {
        var dateTime: Date?
        var timeZone: String?

        var bodyParams: [GoogleAPI.BodyParam] {
            var params: [GoogleAPI.BodyParam] = []
            params.append(.init(.dateTime, dateTime?.toFormat("yyyy-MM-dd'T'HH:mm:ss"), .setIfPresent))
            params.append(.init(.timeZone, timeZone, .setIfPresent))
            return params
        }
    }
}
