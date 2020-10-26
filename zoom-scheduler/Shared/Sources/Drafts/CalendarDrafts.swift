//
//  CalendarDrafts.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 22.10.2020.
//

import Foundation
import Magpie

struct LoadCalendarsDraft: ObjectQuery {
    var queryParams: [GoogleAPI.QueryParam] {
        var params: [GoogleAPI.QueryParam] = []
        params.append(.init(.maxResults, 250))
        params.append(.init(.showHidden, true))
        return params
    }
}
