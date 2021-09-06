//
//  Bundle.swift
//  JavaSnipt
//
//  Created by Kyle Nazario on 4/1/21.
//

#if !os(macOS)
import UIKit

public extension Bundle {
    var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let files = primary["CFBundleIconFiles"] as? [String],
           let icon = files.last
        {
            return UIImage(named: icon)
        }

        return nil
    }
}
#endif
