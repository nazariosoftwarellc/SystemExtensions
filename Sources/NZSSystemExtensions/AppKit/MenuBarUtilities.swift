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
        Button("About \(appName)", action: AboutAppButton.openAboutPanel)
    }
    
    public static func openAboutPanel() {
        NSApplication.shared.orderFrontStandardAboutPanel(options: [
            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(string: "Made with ❤️ in \(AboutAppButton.location)"),
            NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "© \(AboutAppButton.year) Nazario Software LLC"
        ])
    }
}

public struct NZSMoreAppsButton: View {
    public static let title = "More Nazario Software Apps"
    
    let filteringAppNames: [String]
    
    public var body: some View {
        Button("\(NZSMoreAppsButton.title)...") {
            NZSMoreAppsButton.openMoreAppsPanel(filteringAppNames: filteringAppNames)
        }
    }
    
    public static func openMoreAppsPanel(filteringAppNames: [String]) {
        let controller = NSHostingController(
            rootView: NZSAppList(filteringAppNames: filteringAppNames)
                .frame(width: 350, height: 250)
        )
        let window = NSWindow(contentViewController: controller)
        window.title = title
        window.center()
        window.makeKeyAndOrderFront(nil)
    }
}
#endif
