//
//  ExtensionStatusChecker.swift
//  Better Times
//
//  Created by Kyle Nazario on 6/25/26.
//

import SwiftUI
import SafariServices
import NZSSystemExtensions
import Combine

@available(macOS 26.2, iOS 26.2, *)
public struct NZSExtensionStatusCard: View {
    private let iconSize: CGFloat = 68
    
    let extensionName: String
    let extensionDescription: String
    let icon: String
    let iconColor: Color
    let extensionId: String
    let isBlocker: Bool
    
    public init(extensionName: String, extensionDescription: String, icon: String, iconColor: Color, extensionId: String, isBlocker: Bool = false) {
        self.extensionName = extensionName
        self.extensionDescription = extensionDescription
        self.icon = icon
        self.iconColor = iconColor
        self.extensionId = extensionId
        self.isBlocker = isBlocker
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 8) {
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: iconSize))
                    .foregroundStyle(iconColor)
                    .frame(width: iconSize, height: iconSize)
                
                Text(extensionName)
                    .multilineTextAlignment(.center)
                
                Text(extensionDescription)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
            
            NZSExtensionStatusChecker(extId: extensionId, isBlocker: isBlocker)
        }
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.secondary.opacity(0.2), lineWidth: 1)
        }
    }
}

@available(macOS 26.2, iOS 26.2, *)
public struct NZSExtensionStatusChecker: View {
    private let statusHeight: CGFloat = 44
    
    @StateObject private var controller: NZSExtensionStatusCheckerController
    
    public init(extId: String, isBlocker: Bool = false) {
        _controller = StateObject(
            wrappedValue: NZSExtensionStatusCheckerController(
                extensionId: extId,
                isBlocker: isBlocker
            )
        )
    }
    
    public var body: some View {
        extensionStatus
            .padding(.horizontal)
            .frame(maxWidth: .infinity, minHeight: statusHeight, alignment: .center)
            .foregroundStyle(statusColor)
            .background(statusColor.opacity(0.16))
    }
    
    @ViewBuilder
    private var extensionStatus: some View {
        switch controller.extensionEnabled {
        case .enabled:
            statusLabel(symbolName: "checkmark.circle.fill", text: "Active")
        case .disabled:
            Button("Enable") {
                controller.openSafariPrefs()
            }
            .buttonStyle(BorderedButtonStyle())
        default:
            ProgressView()
        }
    }
    
    private var statusColor: Color {
        switch controller.extensionEnabled {
        case .enabled:
            .green
        default:
            .gray
        }
    }
    
    private func statusLabel(symbolName: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: symbolName)
            Text(text)
        }
    }
}

@available(macOS 26.2, iOS 26.2, *)
@MainActor
fileprivate class NZSExtensionStatusCheckerController: ObservableObject {
    @Published private(set) var extensionEnabled = ExtensionState.loading
    private let extensionId: String
    private let isBlocker: Bool
    private var isChecking = false
    
    public init(extensionId: String, isBlocker: Bool) {
        self.extensionId = extensionId
        self.isBlocker = isBlocker
        DispatchQueue.main.async {
            self.reloadEnabledStateOnBecomeActive()
            self.loadExtensionEnabled()
        }
    }
    
    func loadExtensionEnabled() {
        // Startup and activation can request a check at the same time.
        guard !isChecking else { return }
        isChecking = true

        Task {
            defer { isChecking = false }

            let retryCount = 3
            for attempt in 0...retryCount {
                do {
                    extensionEnabled = try await getExtensionState()
                    return
                } catch {
                    print(error)
                    if attempt == retryCount {
                        extensionEnabled = .disabled
                        return
                    }

                    do {
                        try await Task.sleep(nanoseconds: 1_500_000_000)
                    } catch {
                        return
                    }
                }
            }
        }
    }
    
    private func getExtensionState() async throws -> ExtensionState {
        let isEnabled: Bool
        if isBlocker {
            let state = try await SFContentBlockerManager.stateOfContentBlocker(
                withIdentifier: extensionId
            )
            isEnabled = state.isEnabled
        } else {
            #if os(macOS)
            let state = try await SFSafariExtensionManager.stateOfSafariExtension(
                withIdentifier: extensionId
            )
            #else
            let state = try await SFSafariExtensionManager.stateOfExtension(
                withIdentifier: extensionId
            )
            #endif
            isEnabled = state.isEnabled
        }

        return isEnabled ? .enabled : .disabled
    }
    
    func openSafariPrefs() {
        #if os(macOS)
        Task {
            try await SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionId)
            NSApplication.shared.terminate(nil)
        }
        #else
        Task {
            try await SFSafariSettings.openExtensionsSettings(forIdentifiers: [extensionId])
        }
        #endif
    }
    
    enum ExtensionState {
        case enabled
        case disabled
        case loading
    }
    
    private func reloadEnabledStateOnBecomeActive() {
        #if os(macOS)
        let notificationName = NSApplication.didBecomeActiveNotification
        #else
        let notificationName = UIApplication.didBecomeActiveNotification
        #endif
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: .main) { _ in
            Task { @MainActor in
                self.loadExtensionEnabled()
            }
        }
    }
}
