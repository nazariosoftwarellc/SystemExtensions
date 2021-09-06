//
//  View.swift
//  ScriptAway
//
//  Created by Kyle Nazario on 2/24/21.
//

import SwiftUI

public extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
