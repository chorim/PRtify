//
//  PRtifyApp.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/24.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import SwiftUI
import SwiftData
import Logging

#if os(iOS)
typealias ApplicationDelegateAdaptor = UIApplicationDelegateAdaptor
#elseif os(macOS)
typealias ApplicationDelegateAdaptor = NSApplicationDelegateAdaptor
#endif

@main
struct PRtifyApp: App {
    private let logger = Logger(category: "PRtifyApp")
    
    static var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    @ApplicationDelegateAdaptor(PRtifyAppDelegate.self) var delegate
    @Environment(\.scenePhase) private var phase
    
    @ObservedObject var preferences: Preferences = .init()
    
    #if os(macOS)
    @State private var observer: NSKeyValueObservation?
    @State private var isVisible: Bool = false
    #endif
    
    var session: Session {
        delegate.session
    }

    var container: ModelContainer {
        delegate.container
    }
    
    var repeating: TimeInterval {
        preferences.refreshRates.timeInterval
    }
    
    var body: some Scene {
        #if os(macOS)
        MenuBarExtra {
            mainView
                .onAppear {
                    observer = NSApplication.shared.observe(\.keyWindow) { _, _ in
                        isVisible = NSApplication.shared.keyWindow != nil
                    }
                }
                .modelContainer(container)
        } label: {
            Image(systemName: "tray.fill")
                .task {
                    // Since macOS environment depends on menu bar, background scheduler needs calling after app launched.
                    // Default value is background after app launched.
                    await session.updateToken(with: preferences.authToken)
                    do {
                        try await scheduleAppRefresh(using: .background)
                    } catch {
                        logger.error("Failed to scheduleAppRefresh after app launched: \(error.localizedDescription)")
                    }
                }
        }
        .onChange(of: isVisible) { _, isVisible in
            logger.info("PRtify window isVisible: \(isVisible)")
            Task {
                do {
                    let phase: ScenePhase = isVisible ? .active : .background
                    try await scheduleAppRefresh(using: phase)
                } catch {
                    logger.error("Failed to scheduleAppRefresh: \(error.localizedDescription)")
                }
            }
        }
        .onChange(of: preferences.refreshRates) { _, newRefreshRates in
            logger.info("refreshRates value changed: \(newRefreshRates)")
            
            Task {
                await session.backgroundTaskSchedular.invalidate()
            }
        }
        .menuBarExtraStyle(.window)
        #else
        WindowGroup {
            mainView
        }
        .onChange(of: phase) { _, newPhase in
            logger.info("PRtify has entered an app phase: \(String(describing: newPhase))")
            
            Task {
                do {
                    try await scheduleAppRefresh(using: newPhase)
                } catch {
                    logger.error("Failed to scheduleAppRefresh: \(error.localizedDescription)")
                }
            }
        }
        .onChange(of: preferences.refreshRates) { _, newRefreshRates in
            logger.info("refreshRates value changed: \(newRefreshRates)")
            
            Task {
                await session.backgroundTaskSchedular.invalidate()
            }
        }
        .backgroundTask(.appRefresh(BackgroundTaskScheduler.backgroundRefreshBackgroundTaskIdentifier)) {
            logger.notice("Start the backgroundRefresh")
            
            defer {
                logger.notice("Finish the backgroundRefresh")
            }
            
            guard let username = await preferences.user?.login, await session.credential?.authToken != nil else {
                logger.warning("Unauthorized user. Stopped the backgroundTask: \(BackgroundTaskScheduler.backgroundRefreshBackgroundTaskIdentifier)")
                return
            }
            
            await session.backgroundTaskSchedular.backgroundRefresh(by: username, repeating: repeating)
        }
        .modelContainer(container)
        #endif
    }
    
    @ViewBuilder
    var mainView: some View {
        MainView()
            .environmentObject(delegate)
            .environmentObject(preferences)
            .environment(\.session, session)
    }
    
    private func scheduleAppRefresh(using phase: ScenePhase) async throws {
        guard let username = preferences.user?.login else {
            logger.warning("Unauthorized user. Stopped the backgroundTask: \(BackgroundTaskScheduler.backgroundRefreshBackgroundTaskIdentifier)")
            return
        }
        
        try await session.backgroundTaskSchedular.scheduleAppRefresh(
            by: username,
            using: phase,
            repeating: repeating
        )
    }
}
