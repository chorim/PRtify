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
    
    var session: Session {
        delegate.session
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(delegate)
                .environmentObject(preferences)
                .environment(\.session, session)
        }
        .onChange(of: phase) { _, newPhase in
            logger.info("PRtify has entered an app phase: \(String(describing: newPhase))")
            
            Task {
                guard let username = preferences.user?.login else {
                    logger.warning("Unauthorized user. Stopped the backgroundTask: \(BackgroundTaskScheduler.backgroundRefreshBackgroundTaskIdentifier)")
                    return
                }
                try await session.backgroundTaskSchedular.scheduleAppRefresh(by: username, using: newPhase)
            }
        }
        .backgroundTask(.appRefresh(BackgroundTaskScheduler.backgroundRefreshBackgroundTaskIdentifier)) {
            logger.notice("Start the backgroundRefresh")
            
            defer {
                logger.notice("Finish the backgroundRefresh")
            }
            
            guard let username = await preferences.user?.login, await session.credential != nil else {
                logger.warning("Unauthorized user. Stopped the backgroundTask: \(BackgroundTaskScheduler.backgroundRefreshBackgroundTaskIdentifier)")
                return
            }
            
            await session.backgroundTaskSchedular.backgroundRefresh(by: username)
        }
        .modelContainer(for: Repository.self)
    }
}
