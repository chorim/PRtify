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
    @Environment(\.session) private var session: Session
 
    @KeychainStorage("authToken") private var authToken: Session.AuthToken? = nil
    
    var body: some View {
        TabView {
            Group {
                HomeView(authToken: $authToken)
                    .environment(\.session, session)
                    .environmentObject(delegate)
                    .tabItem {
                        Group {
                            Image(systemName: "house")
                                .renderingMode(.template)
                            Text("Home")
                        }
                        .foregroundStyle(Color.white)
                    }
                
                SettingView()
                    .environmentObject(delegate)
                    .tabItem {
                        Group {
                            Image(systemName: "gear")
                                .renderingMode(.template)
                            Text("Settings")
                        }
                        .foregroundStyle(Color.white)
                    }
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color.flatDarkBackground, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
        }
        .onAppear(perform: updateAuthToken)
    }
    
    private func updateAuthToken() {
        guard let authToken else { return }
        session.updateToken(with: authToken)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(PRtifyAppDelegate())
    }
}
