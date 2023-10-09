//
//  SettingView.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/26.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI
import SwiftUIIntrospect

struct SettingView: View {
    @EnvironmentObject private var delegate: PRtifyAppDelegate
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.flatDarkBackground.edgesIgnoringSafeArea([.all])
            }
            .navigationTitle("Settings")
            .introspect(.navigationStack, on: .iOS(.v16, .v17)) { 
                delegate.configureNavigationBar($0)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SettingView()
        .environmentObject(PRtifyAppDelegate())
        .environmentObject(Preferences())
}
