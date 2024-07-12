//
//  File.swift
//  
//
//  Created by Kyle Nazario on 7/12/24.
//

import SwiftUI

#if os(macOS)
public struct AboutAppButton: View {
    private static let year = Calendar.current.component(.year, from: Date())
    private static let location = "Logan, Utah"
    
    let appName: String
    
    public init(_ appName: String) {
        self.appName = appName
    }
    
    public var body: some View {
        Button("About \(appName)", action: openAboutPanel)
    }
    
    public func openAboutPanel() {
        NSApplication.shared.orderFrontStandardAboutPanel(options: [
            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(string: "Made with ❤️ in \(AboutAppButton.location)"),
            NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "© \(AboutAppButton.year) Nazario Software LLC"
        ])
    }
}
#endif
