//
//  NZSAppList.swift
//  SystemExtensions
//
//  Created by Kyle Nazario on 12/1/24.
//

fileprivate final class NZSAppListViewModel: ObservableObject {
    struct NZSAppLink: Identifiable {
        let name: String
        let href: String
        let description: String
        var id: String { name }
    }
    
    @Published var appLinks: [NZSAppLink] = []
    
    init() {
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
