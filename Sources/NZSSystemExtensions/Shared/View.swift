//
//  View.swift
//  ScriptAway
//
//  Created by Kyle Nazario on 2/24/21.
//

import SwiftUI

@available(macOS 10.15, iOS 13.0, *)
extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
