//
//  PRtifyApp.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/24.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import SwiftUI

#if os(iOS)
typealias ApplicationDelegateAdaptor = UIApplicationDelegateAdaptor
#elseif os(macOS)
typealias ApplicationDelegateAdaptor = NSApplicationDelegateAdaptor
#endif

@main
struct PRtifyApp: App {
    static var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    @ApplicationDelegateAdaptor(PRtifyAppDelegate.self) var delegate

    var session: Session {
        delegate.session
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(delegate)
                .environment(\.session, session)
        }
    }
}
