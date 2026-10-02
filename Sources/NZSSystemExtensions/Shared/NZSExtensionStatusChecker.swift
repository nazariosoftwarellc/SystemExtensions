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
    
    public init(extensionName: String, extensionDescription: String, icon: String, iconColor: Color, extensionId: String) {
        self.extensionName = extensionName
        self.extensionDescription = extensionDescription
        self.icon = icon
        self.iconColor = iconColor
        self.extensionId = extensionId
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
            
            NZSExtensionStatusChecker(extId: extensionId)
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
    
    public init(extId: String) {
        _controller = StateObject(wrappedValue: NZSExtensionStatusCheckerController(extensionId: extId))
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
        case .errored:
            Text("Error")
        default:
            ProgressView()
        }
    }
    
    private var statusColor: Color {
        switch controller.extensionEnabled {
        case .enabled:
            .green
        case .errored:
            .red
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
    private var isChecking = false
    
    public init(extensionId: String) {
        self.extensionId = extensionId
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

            // One immediate attempt followed by up to three retries.
            let limit = 100
            for attempt in 0...limit {
                let newState = await getExtensionState()
                if case .errored = newState, attempt < limit {
                    do {
                        try await Task.sleep(nanoseconds: 1_500_000_000)
                    } catch {
                        return
                    }
                    continue
                }

                extensionEnabled = newState
                return
            }
        }
    }
    
    private func getExtensionState() async -> ExtensionState {
        var errors: [Error] = []
        var blockerState: SFContentBlockerState? = nil
        var extensionState: SFSafariExtensionState? = nil
        
//        do {
//            blockerState = try await SFContentBlockerManager.stateOfContentBlocker(withIdentifier: extensionId)
//        } catch {
//            errors.append(error)
//        }
        
        do {
            #if os(macOS)
            extensionState = try await SFSafariExtensionManager.stateOfSafariExtension(withIdentifier: extensionId)
            #else
            extensionState = try await SFSafariExtensionManager.stateOfExtension(withIdentifier: extensionId)
            #endif
        } catch {
            errors.append(error)
        }
        
        guard errors.count < 2 else { return .errored }
        let eitherEnabled = (blockerState?.isEnabled ?? false) || (extensionState?.isEnabled ?? false)
        return eitherEnabled ? .enabled : .disabled
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
        case errored
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
