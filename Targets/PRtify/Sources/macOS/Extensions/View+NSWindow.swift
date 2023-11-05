//
//  View+NSWindow.swift
//  PRtify (macOS)
//
//  Created by Insu Byeon on 11/5/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI

extension View {
    @discardableResult
    public func openWindow(title: String, sender: Any?) -> NSWindow {
        let hostingController = NSHostingController(rootView: self)
        let window = NSWindow(contentViewController: hostingController)
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.contentViewController = hostingController
        window.title = title
        window.makeKeyAndOrderFront(self)
        return window
    }
}
