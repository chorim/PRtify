//
//  MainView.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/28.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import SwiftUI
import AuthenticationServices

struct MainView: View, Loggable {
    @EnvironmentObject private var delegate: PRtifyAppDelegate
    @EnvironmentObject private var preferences: Preferences
    @Environment(\.session) private var session: Session
 
    @KeychainStorage("authToken") private var authToken: Session.AuthToken? = nil
    
    @State private var selection: Int = 0
    
    var body: some View {
        TabView(selection: $selection) {
            Group {
                HomeView(authToken: $authToken)
                    .environment(\.session, session)
                    .environmentObject(delegate)
                    .environmentObject(preferences)
                    .tabItem {
                        Label("Home", systemImage: "house")
                            .foregroundStyle(Color.white)
                    }
                    .tag(0)
                
                SettingView()
                    .environmentObject(delegate)
                    .environmentObject(preferences)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                            .foregroundStyle(Color.white)
                    }
                    .tag(1)
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color.flatDarkBackground, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
        }
        .onAppear(perform: updateAuthToken)
    }
    
    private func updateAuthToken() {
        guard let authToken else { return }
        logger.debug("Update the auth token")
        logger.info("The authToken: \(String(describing: authToken))")
        session.updateToken(with: authToken)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(PRtifyAppDelegate())
            .environmentObject(Preferences())
    }
}
