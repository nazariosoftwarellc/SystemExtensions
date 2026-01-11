//
//  NZSAppList.swift
//  SystemExtensions
//
//  Created by Kyle Nazario on 12/1/24.
//

import SwiftUI
#if os(macOS)
import AppKit
typealias FrameworkApplication = NSWorkspace
#else
import UIKit
typealias FrameworkApplication = UIApplication
#endif

public final class NZSAppListViewModel: ObservableObject {
    struct NZSAppLink: Identifiable, Codable {
        let id: String
        let name: String
        let href: String
        let description: String
        let appStoreURL: String?
        let githubURL: String?
        let chromeStoreURL: String?
        let firefoxStoreURL: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case href
            case description
            case appStoreURL = "appStoreUrl"
            case githubURL = "githubUrl"
            case chromeStoreURL = "chromeStoreUrl"
            case firefoxStoreURL = "firefoxStoreUrl"
        }
    }
    
    @Published var appLinks: [NZSAppLink] = []
    
    public init(filteringAppNames: [String] = []) {
        Task {
            do {
                let appLinks = try await self.getAppLinks()
                DispatchQueue.main.async {
                    self.appLinks = appLinks.filter { appLink in
                        !filteringAppNames.contains(appLink.name)
                    }
                }
            } catch {
                print("Error loading app links: \(error)")
            }
        }
    }
    
    private func getAppLinks() async throws -> [NZSAppLink] {
        let appJSONURL = URL(string: "https://nazariosoftware.com/json/app-list.json")!
        let (data, _) = try await URLSession.shared.data(from: appJSONURL)
        let decoder = JSONDecoder()
        return try decoder.decode([NZSAppLink].self, from: data)
    }
}

public struct NZSAppList: View {
    @ObservedObject private var viewModel: NZSAppListViewModel
    
    public init(filteringAppNames: [String] = []) {
        self._viewModel = ObservedObject(wrappedValue: NZSAppListViewModel(filteringAppNames: filteringAppNames))
    }
    
    public var body: some View {
        VStack {
            Text("More great apps from Nazario Software:")
                .font(.body)
                .padding(.top)
            List(viewModel.appLinks) { appLink in
                AppLinkItem(appLink: appLink)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    struct AppLinkItem: View {
        let appLink: NZSAppListViewModel.NZSAppLink
        
        var body: some View {
            Button(action: {
                guard let url = URL(string: appLink.href) else { return }
                FrameworkApplication.shared.open(url)
            }) {
                HStack {
                    if let appIconURL = getAppIconURL() {
                        AsyncImage(url: appIconURL) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        .frame(width: 50, height: 50)
                    }
                    VStack(alignment: .leading) {
                        getColorHighlightedText(content: appLink.name, color: .blue)
                        getColorHighlightedText(content: appLink.description, color: .secondary)
                            .font(.caption)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        
        private func getAppIconURL() -> URL? {
            URL(string: "https://nazariosoftware.com/img/\(appLink.id)-icon.webp")
        }
        
        private func getColorHighlightedText(content: String, color: Color) -> some View {
            if #available(macOS 14.0, *) {
                Text(content)
                    .foregroundStyle(color)
            } else {
                Text(content)
                    .foregroundColor(color)
            }
        }
    }
}
