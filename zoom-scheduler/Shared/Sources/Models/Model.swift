//
//  Model.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 12.10.2020.
//

import Foundation
import Magpie
import SwiftDate

protocol Model: Magpie.Model { }

extension Model {
    static var encodingStrategy: JSONEncodingStrategy {
        return JSONEncodingStrategy(
            keys: .convertToSnakeCase,
            date: .formatted(Date().formatter(format: "yyyy-MM-dd'T'HH:mm:ssZ")),
            data: .base64
        )
    }
    static var decodingStrategy: JSONDecodingStrategy {
        return JSONDecodingStrategy(
            keys: .convertFromSnakeCase,
            date: .formatted(Date().formatter(format: "yyyy-MM-dd'T'HH:mm:ssZ")),
            data: .base64
        )
    }
}
