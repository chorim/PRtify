//
//  HomeView.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/26.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI
import SwiftData
import SwiftUIIntrospect
import Logging

struct HomeView: View {
    @EnvironmentObject private var delegate: PRtifyAppDelegate
    @EnvironmentObject private var preferences: Preferences
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.session) private var session: Session
    
    @Binding var authToken: Session.AuthToken?
    
    @State private var error: Error? = nil
    
    @State var createdNodes: HomeNodeState = .loading
    @State var assignedNodes: HomeNodeState = .loading
    @State var requestedNodes: HomeNodeState = .loading

    @State public var showingProfileView: Bool = false
    
    @Query(sort: [SortDescriptor(\Node.createdAt, order: .reverse)], animation: .smooth)
    public var nodes: [Node]
    
    let logger = Logger(category: "HomeView")
    
    private var user: User? {
        preferences.user
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if authToken != nil {
                    List {
                        createdNodesView
                        assignedNodesView
                        requestedNodesView
                        
                        #if os(macOS)
                        Section {
                            SettingButtonView(authToken: $authToken)
                            
                            quitButton
                        }
                        #endif
                    }
                    .scrollContentBackground(.hidden)
                    .task {
                        await fetchProfile()
                        await fetchRepositories()
                    }
                    .refreshable {
                        Task {
                            await fetchRepositories()
                        }
                    }
                    #if os(iOS)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            if let avatarURL = user?.avatarURL {
                                AvatarView(avatarURL: avatarURL)
                                    .onTapGesture {
                                        self.showingProfileView = true
                                    }
                            }
                        }
                    }
                    #endif
                } else {
                    SignInView(authToken: $authToken)
                }
            }
            .background(Color.flatDarkBackground)
            #if os(iOS)
            .navigationTitle("Home")
            #elseif os(macOS)
            .navigationTitle("PRtify")
            #endif
        }
        #if os(iOS)
        .introspect(.navigationStack, on: .iOS(.v16, .v17)) {
            delegate.configureNavigationBar($0)
        }
        #endif
        .sheet(isPresented: $showingProfileView) {
            if let user = preferences.user {
                ProfileView(user: Binding { user } set: { preferences.user = $0 })
            }
        }
        .alert(error: $error)
    }

    @Sendable
    func fetchProfile() async {
        guard !PRtifyApp.isPreview else {
            preferences.user = .mock
            return
        }
        
        do {
            preferences.user = try await session.fetchProfile()
        } catch {
            logger.error("fetchProfile() error: \(error.localizedDescription)")
            self.error = error
        }
    }
    
    @Sendable
    func fetchRepositories() async {
        logger.info("Call fetchRepositories(all) at \(Date())")
        
        do {
            guard let username = user?.login else {
                logger.debug("Username is null. Failed to fetchRepositories.")
                return
            }
            
            let nodes = try await session.fetchPullRequests(by: username)
            try modelContext.delete(model: Node.self)
            for node in nodes {
                let graphs = node.value
                
                for graph in graphs {
                    modelContext.insert(graph)
                }
            }
            
            try modelContext.save()
            
            let createdNodes: [Node] = nodes[.created(username: username)] ?? []
            self.createdNodes = createdNodes.isEmpty ? .empty : .loaded(createdNodes)
            
            let assignedNodes: [Node] = nodes[.assigned(username: username)] ?? []
            self.assignedNodes = assignedNodes.isEmpty ? .empty : .loaded(assignedNodes)
            
            let requestedNodes: [Node] = nodes[.requested(username: username)] ?? []
            self.requestedNodes = requestedNodes.isEmpty ? .empty : .loaded(requestedNodes)
            
            logger.info("All repositories has been fetched: \(Date())")
        } catch {
            logger.error("Failed to fetchRepositories with error: \(error)")
            self.error = error
        }
    }
}

#Preview {
    HomeView(authToken: .constant(.init(accessToken: "1", tokenType: .bearer)))
        .modelContainer(PRtifyPreviewContainer.self)
        .environmentObject(PRtifyAppDelegate())
        .environmentObject(Preferences())
}
