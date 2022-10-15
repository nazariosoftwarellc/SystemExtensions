//
//  NSTextAlignment.swift
//
//
//  Created by Kyle Nazario on 11/1/20.
//

import SwiftUI
#if os(macOS)
import AppKit
public typealias UserInterfaceLayoutDirection = NSUserInterfaceLayoutDirection
#elseif !os(watchOS)
import UIKit
public typealias UserInterfaceLayoutDirection = UIUserInterfaceLayoutDirection

public extension NSTextAlignment {
    init(textAlignment: TextAlignment, userInterfaceLayoutDirection direction: UserInterfaceLayoutDirection) {
        switch textAlignment {
        case .center:
            self.init(rawValue: NSTextAlignment.center.rawValue)!
        case .leading:
            self.init(rawValue: NSTextAlignment.natural.rawValue)!
        case .trailing:
            if direction == .leftToRight {
                self.init(rawValue: NSTextAlignment.right.rawValue)!
            } else {
                self.init(rawValue: NSTextAlignment.left.rawValue)!
            }
        }
    }
}
#endif
