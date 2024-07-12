//
//  File.swift
//  
//
//  Created by Kyle Nazario on 7/12/24.
//

import SwiftUI

#if os(macOS)
struct AboutAppButton: View {
    private static let year = 2024
    private static let location = "Logan, Utah"
    
    let appName: String
    
    var body: some View {
        Button("About \(appName)", perform: openAboutPanel)
    }
    
    func openAboutPanel() {
        NSApplication.shared.orderFrontStandardAboutPanel(options: [
            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(string: "Made with ❤️ in \(location)"),
            NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "© \(year) Nazario Software LLC"
        ])
    }
}
#endif
