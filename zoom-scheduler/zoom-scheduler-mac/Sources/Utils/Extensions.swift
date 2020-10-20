//
//  Extensions.swift
//  zoom-scheduler-mac
//
//  Created by Karasuluoglu on 2.10.2020.
//

import AppKit
import Foundation

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}

extension NSApplication {
    var appDelegate: AppDelegate {
        if let delegate = delegate as? AppDelegate {
            return delegate
        }
        fatalError("We shouldn't have a problem with the app delegate.")
    }
}
