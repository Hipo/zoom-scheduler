//
//  EmailValidator.swift
//  zoom-scheduler
//
//  Created by Karasuluoglu on 1.10.2020.
//

import Foundation

struct EmailValidator {
    private let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    public func validate<T>(_ input: T?) -> Bool {
        if let inputString = input as? String, !inputString.isEmpty {
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            return predicate.evaluate(with: inputString)
        }
        return false
    }
}
