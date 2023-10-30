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
    
    @Binding var authToken: Session.AuthToken?
    
    @State private var path = NavigationPath()
    @State private var showingNetworkDebugger: Bool = false
    
    var body: some View {
        NavigationStack {
            Group {
                List {
                    Section(header: Text("Profile")) {
                        Text("Username:")
                    }
                    
                    if authToken != nil {
                        Section {
                            Button {
                                authToken = nil
                            } label: {
                                Text("Sign Out")
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
                    }
                    #endif
                }
                .scrollContentBackground(.hidden)
            }
            .background(Color.flatDarkBackground)
            .navigationTitle("Settings")
            .introspect(.navigationStack, on: .iOS(.v16, .v17)) { 
                delegate.configureNavigationBar($0)
            }
        }
        .sheet(isPresented: $showingNetworkDebugger) {
            PulseView()
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SettingView(authToken: .constant(.init(accessToken: "1", tokenType: .bearer)))
        .environmentObject(PRtifyAppDelegate())
        .environmentObject(Preferences())
}
