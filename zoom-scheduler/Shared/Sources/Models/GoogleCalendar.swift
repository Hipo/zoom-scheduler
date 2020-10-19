//
//  GoogleCalendar.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 15.10.2020.
//

import Foundation
import Magpie
import SwiftUI

final class GoogleCalendar: Model, Identifiable, Equatable {
    var color: Color? {
        return hexColor.map(Color.init(hex:))
    }

    let id: String
    let title: String?
    let hexColor: String?

    static var encodingStrategy: JSONEncodingStrategy {
        return JSONEncodingStrategy()
    }
    static var decodingStrategy: JSONDecodingStrategy {
        return JSONDecodingStrategy()
    }

    static func == (lhs: GoogleCalendar, rhs: GoogleCalendar) -> Bool {
        return lhs.id == rhs.id
    }
}

extension GoogleCalendar {
    private enum CodingKeys: String, CodingKey {
        case id
        case title = "summary"
        case hexColor = "backgroundColor"
    }
}

final class GoogleCalendarList: Model {
    let calendars: [GoogleCalendar]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        calendars = try container.decodeIfPresent([GoogleCalendar].self, forKey: .calendars) ?? []
    }
}

extension GoogleCalendarList {
    private enum CodingKeys: String, CodingKey {
        case calendars = "items"
    }
}
