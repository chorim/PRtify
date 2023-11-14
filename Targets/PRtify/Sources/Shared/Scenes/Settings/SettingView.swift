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
    @EnvironmentObject private var preferences: Preferences
    
    @Binding var authToken: Session.AuthToken?
    @Binding var selection: Int
    
    @State private var path = NavigationPath()
    @State private var showingNetworkDebugger: Bool = false
    @State private var showingWebView: Bool = false
    
    private var user: User? {
        preferences.user
    }
    
    private var selectedRefreshRates: Binding<BackgroundTaskScheduler.RefreshRate> {
        Binding {
            return preferences.refreshRates
        } set: { newValue in
            preferences.refreshRates = newValue
        }
    }
    
    @ViewBuilder
    var linkProfileButton: some View {
        #if os(iOS)
        Button {
            showingWebView = true
        } label: {
            Text("Open My Profile")
        }
        #elseif os(macOS)
        if let user = user {
            Link(destination: user.htmlURL) {
                Text("Open My Profile")
            }
        }
        #endif
    }
    
    @ViewBuilder
    var refreshRateFooterText: some View {
        #if os(iOS)
        Text("Background refresh may not work smoothly on iOS/iPadOS device")
            .foregroundStyle(.red)
        #else
        Text("Higher refresh rates may result in higher battery consumption.")
        #endif
    }
    
    var body: some View {
        NavigationStack {
            Group {
                List {
                    if let user = user, authToken != nil {
                        Section(header: Text("Profile")) {
                            HStack(spacing: 10) {
                                AvatarView(avatarURL: user.avatarURL)
                                    .avatarViewStyle(.small)
                                
                                Text("\(user.name ?? "") (@\(user.login))")
                            }
                            linkProfileButton
                        }
                        
                        Section(
                            header: Text("Refresh rates"),
                            footer: refreshRateFooterText
                        ) {
                            Picker("Refresh rates", selection: selectedRefreshRates) {
                                ForEach(BackgroundTaskScheduler.RefreshRate.allCases, id: \.self) { (refreshRate: BackgroundTaskScheduler.RefreshRate) in
                                    Text(refreshRate.name)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        Section {
                            Button {
                                authToken = nil
                            } label: {
                                Text("Sync out")
                                    .foregroundStyle(.red)
                            }
                        }
                    } else {
                        Section(header: Text("Profile")) {
                            Button {
                                selection = 0
                            } label: {
                                Text("Sync in")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    
                    #if DEBUG
                    Section(header: Text("DEV")) {
                        Button {
                            showingNetworkDebugger = true
                        } label: {
                            Text("Open Network Debugger")
                        }

                        Text("Build version: ")
                        Text("Access Token: \(String(describing: authToken?.accessToken))")
                    }
                    #endif
                }
                .scrollContentBackground(.hidden)
            }
            .background(Color.flatDarkBackground)
            .navigationTitle("Settings")
            #if os(iOS)
            .introspect(.navigationStack, on: .iOS(.v16, .v17)) {
                delegate.configureNavigationBar($0)
            }
            #endif
        }
        .sheet(isPresented: $showingNetworkDebugger) {
            PulseView()
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showingWebView) {
            if let htmlURL = user?.htmlURL {
                SafariWebView(url: htmlURL)
                    .ignoresSafeArea()
            }
        }
        #endif
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SettingView(authToken: .constant(.init(accessToken: "1", tokenType: .bearer)), selection: .constant(1))
        .environmentObject(PRtifyAppDelegate())
        .environmentObject(Preferences())
}
