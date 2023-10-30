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
            switch newPhase {
            case .background:
                Task {
                    do {
                        try await session.backgroundTaskSchedular.scheduleAppRefresh()
                    } catch {
                        logger.error("Couldn't schedule app refresh: \(error)")
                    }
                }
                
            case .active, .inactive:
                Task {
                    await session.backgroundTaskSchedular.invalidate()
                }
                
            default:
                break
            }
        }
        .backgroundTask(.appRefresh(BackgroundTaskScheduler.backgroundRefreshBackgroundTaskIdentifier)) {
            guard let username = await preferences.user?.login else {
                logger.warning("Unauthorized user.")
                return
            }
            
            await session.backgroundTaskSchedular.backgroundRefresh(by: username)
        }
        .modelContainer(for: Repository.self)
    }
}
