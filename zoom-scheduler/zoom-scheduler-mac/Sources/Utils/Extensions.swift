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
