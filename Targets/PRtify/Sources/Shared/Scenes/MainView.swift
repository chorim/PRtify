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
        if authToken != nil {
            TabView {
                HomeView(authToken: $authToken)
                    .environment(\.session, session)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                
                SettingView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
            }
        } else {
            SignInView(authToken: $authToken)
                .environment(\.session, session)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
