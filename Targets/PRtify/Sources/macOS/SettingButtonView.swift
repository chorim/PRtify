//
//  SettingButtonView.swift
//  PRtify (macOS)
//
//  Created by Insu Byeon on 11/5/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI

struct SettingButtonView: View {
    @EnvironmentObject private var delegate: PRtifyAppDelegate
    @EnvironmentObject private var preferences: Preferences
    
    @Binding var authToken: Session.AuthToken?
    
    @State private var window: NSWindow?
    
    var body: some View {
        Button {
            window = SettingView(authToken: $authToken, selection: .constant(1))
                .frame(width: 550, height: 400)
                .environmentObject(delegate)
                .environmentObject(preferences)
                .openWindow(title: "Settings", sender: self)
            
            window?.orderFrontRegardless()
        } label: {
            Text("Open Settings")
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(Color.flatDarkCardBackground)
                .buttonStyle(.plain)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .onChange(of: authToken) { _, authToken in
            guard authToken == nil else { return }
            window?.close()
        }
    }
}

#Preview {
    SettingButtonView(authToken: .constant(.init(accessToken: "1", tokenType: .bearer)))
}
