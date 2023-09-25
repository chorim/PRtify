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
    @ApplicationDelegateAdaptor(PRtifyAppDelegate.self) var delegate

    var session: Session {
        delegate.session
    }

    var body: some Scene {
        WindowGroup {
            SignInView()
                .environmentObject(delegate)
                .environment(\.session, session)
        }
    }
}
