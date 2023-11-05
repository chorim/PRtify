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

struct HomeView: View, Loggable {
    @EnvironmentObject private var delegate: PRtifyAppDelegate
    @EnvironmentObject private var preferences: Preferences
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.session) private var session: Session
    
    @Binding var authToken: Session.AuthToken?
    
    @State private var error: Error? = nil
    
    @State var createdNodes: HomeNodeState = .loading
    @State var assignedNodes: HomeNodeState = .loading
    @State var requestedNodes: HomeNodeState = .loading

    @State public var showingRepositoriesAddView: Bool = false
    @State public var showingProfileView: Bool = false
    
    @Query(sort: [SortDescriptor(\Repository.createdAt, order: .reverse)], animation: .smooth)
    public var repositories: [Repository]
    
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
                        
                        // repositorySectionView
                        // controlSectionView
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
        .sheet(isPresented: $showingRepositoriesAddView) {
            RepositoriesAddView(showingRepositoriesAddView: $showingRepositoriesAddView)
        }
        .sheet(isPresented: $showingProfileView) {
            if let user = preferences.user {
                ProfileView(user: Binding { user } set: { preferences.user = $0 })
            }
        }
        #if os(iOS)
        .alert(error: $error)
        #endif
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
    
    func deleteRepository(_ indexSet: IndexSet) {
        for index in indexSet {
            let repository = repositories[index]
            modelContext.delete(repository)
        }
        
        do {
            try modelContext.save()
        } catch {
            logger.error("An error occurred while calling the save of modelContext: \(error.localizedDescription)")
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
