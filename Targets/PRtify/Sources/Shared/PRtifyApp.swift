//
//  PRtifyApp.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/24.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import SwiftUI
import SwiftData

#if os(iOS)
typealias ApplicationDelegateAdaptor = UIApplicationDelegateAdaptor
#elseif os(macOS)
typealias ApplicationDelegateAdaptor = NSApplicationDelegateAdaptor
#endif

@main
struct PRtifyApp: App, Loggable {
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
    
    var body: some Scene {
        #if os(macOS)
        MenuBarExtra {
            mainView
                .onAppear {
                    observer = NSApplication.shared.observe(\.keyWindow) { _, _ in
                        isVisible = NSApplication.shared.keyWindow != nil
                    }
                }
        } label: {
            Image(systemName: "tray.fill")
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
        .backgroundTask(.appRefresh(BackgroundTaskScheduler.backgroundRefreshBackgroundTaskIdentifier)) {
            logger.notice("Start the backgroundRefresh")
            
            defer {
                logger.notice("Finish the backgroundRefresh")
            }
            
            guard let username = await preferences.user?.login, await session.credential?.authToken != nil else {
                logger.warning("Unauthorized user. Stopped the backgroundTask: \(BackgroundTaskScheduler.backgroundRefreshBackgroundTaskIdentifier)")
                return
            }
            
            await session.backgroundTaskSchedular.backgroundRefresh(by: username)
        }
        .modelContainer(for: Repository.self)
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
        
        try await session.backgroundTaskSchedular.scheduleAppRefresh(by: username, using: phase)
    }
}
