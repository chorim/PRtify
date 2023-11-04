//
//  MainView.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/28.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import SwiftUI
import AuthenticationServices
import UserNotifications

struct MainView: View, Loggable {
    @EnvironmentObject private var delegate: PRtifyAppDelegate
    @EnvironmentObject private var preferences: Preferences
    @Environment(\.session) private var session: Session
 
    @KeychainStorage("authToken") private var authToken: Session.AuthToken? = nil
    
    @State private var selection: Int = 0
    @State private var error: Error? = nil
    
    var body: some View {
        SidebarView
        .alert(error: $error)
        .task(requestAuthorizationForNotification)
        .task(updateToken)
        .onChange(of: authToken) { _, _ in
            Task {
                await updateToken()
            }
        }
    }
    
    @Sendable
    private func updateToken() async {
        guard let authToken else { return }
        logger.debug("Update the auth token")
        logger.info("The authToken: \(String(describing: authToken))")
        await session.updateToken(with: authToken)
    }
    
    @Sendable
    private func requestAuthorizationForNotification() async {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            logger.error("requestAuthorizationForNotification error: \(error.localizedDescription)")
            self.error = error
        }
    }
    
    // swiftlint:disable identifier_name
    @ViewBuilder
    var SidebarView: some View {
        #if os(iOS)
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
                
                SettingView(authToken: $authToken, selection: $selection)
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
        #elseif os(macOS)
        NavigationView {
            List {
                NavigationLink(
                    destination: HomeView(authToken: $authToken)
                        .environment(\.session, session)
                        .environmentObject(delegate)
                        .environmentObject(preferences),
                    label: {
                        Label("Home", systemImage: "house")
                            .foregroundStyle(Color.white)
                    }
                )
                
                NavigationLink(
                    destination: SettingView(authToken: $authToken, selection: $selection)
                        .environmentObject(delegate)
                        .environmentObject(preferences),
                    label: {
                        Label("Settings", systemImage: "gear")
                            .foregroundStyle(Color.white)
                    }
                )
            }
            .listStyle(.sidebar)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                } label: {
                    Image(systemName: "sidebar.leading")
                }
            }
        }
        #endif
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(PRtifyAppDelegate())
            .environmentObject(Preferences())
    }
}
