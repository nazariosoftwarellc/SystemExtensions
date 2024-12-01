//
//  NZSAppList.swift
//  SystemExtensions
//
//  Created by Kyle Nazario on 12/1/24.
//

import SwiftUI
#if os(macOS)
import AppKit
typealias SystemFramework = AppKit
#else
import UIKit
typealias SystemFramework = UIKit
#endif

public final class NZSAppListViewModel: ObservableObject {
    struct NZSAppLink: Identifiable {
        let name: String
        let href: String
        let description: String
        var id: String { name }
    }
    
    @Published var appLinks: [NZSAppLink] = []
    
    public init() {
        Task {
            do {
                let appLinks = try await loadAppLinks()
                DispatchQueue.main.async {
                    self.appLinks = appLinks
                }
            } catch {
                print("Error loading app links: \(error)")
            }
        }
    }
    
    func getAppLinks() async throws {
        let appJSONURL = URL(string: "https://github.com/nazariosoftwarellc/nazariosoftwarellc.github.io/raw/refs/heads/main/assets/json/app-list.json")!
        let (data, _) = try await URLSession.shared.data(from: appJSONURL)
        let decoder = JSONDecoder()
        return try decoder.decode([NZSAppLink].self, from: data)
    }
}

public struct NZSAppList: View {
    @StateObject private var viewModel = NZSAppListViewModel()
    
    public init() {}
    
    var body: some View {
        VStack {
            Text("More great apps from Nazario Software")
                .font(.title)
                .padding(.bottom)
            List(viewModel.appLinks) { appLink in
                AppLinkItem(appLink: appLink)
            }
        }
    }
    
    struct AppLinkItem: View {
        let appLink: NZSAppListViewModel.NZSAppLink
        
        var body: some View {
            Button(action: {
                guard let url = URL(string: appLink.href) else { return }
                SystemFramework.shared.open(url)
            }) {
                Text(appLink.name)
            }
        }
    }
}
