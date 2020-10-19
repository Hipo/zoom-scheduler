//
//  Extensions.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 19.10.2020.
//

import Foundation

extension Result {
    var isSuccess: Bool {
        switch self {
            case .success:
                return true
            case .failure:
                return false
        }
    }

    var isFailure: Bool {
        return !isSuccess
    }
}
