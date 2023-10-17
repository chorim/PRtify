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
    
    @State private var createdNodes: [Node] = []
    @State private var assignedNodes: [Node] = []
    @State private var requestedNodes: [Node] = []

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
                        if !createdNodes.isEmpty {
                            Section(header: Text("Created pull requests").foregroundColor(.white)) {
                                ForEach(createdNodes) { (node: Node) in
                                    Text("\(node.title)")
                                        .foregroundColor(.white)
                                }
                                .listRowBackground(Color.flatDarkContainerBackground)
                            }
                        }
                        
                        if !assignedNodes.isEmpty {
                            Section(header: Text("Assigned pull requests").foregroundColor(.white)) {
                                ForEach(assignedNodes) { (node: Node) in
                                    Text("\(node.title)")
                                        .foregroundColor(.white)
                                }
                                .listRowBackground(Color.flatDarkContainerBackground)
                            }
                        }
                        
                        if !requestedNodes.isEmpty {
                            Section(header: Text("Requested pull requests").foregroundColor(.white)) {
                                ForEach(requestedNodes) { (node: Node) in
                                    Text("\(node.title)")
                                        .foregroundColor(.white)
                                }
                                .listRowBackground(Color.flatDarkContainerBackground)
                            }
                        }
                        
                        // repositorySectionView
                        // controlSectionView
                    }
                    .scrollContentBackground(.hidden)
                    .task(fetchProfile)
                    .task(fetchRepositories)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            if let avatarURL = user?.avatarURL {
                                AvatarView(avatarURL: Binding { avatarURL } set: { _ in })
                                    .onTapGesture {
                                        self.showingProfileView = true
                                    }
                            }
                        }
                    }
                } else {
                    SignInView(authToken: $authToken)
                }
            }
            .background(Color.flatDarkBackground)
            .navigationTitle("Home")
        }
        .introspect(.navigationStack, on: .iOS(.v16, .v17)) {
            delegate.configureNavigationBar($0)
        }
        .sheet(isPresented: $showingRepositoriesAddView) {
            RepositoriesAddView(showingRepositoriesAddView: $showingRepositoriesAddView)
        }
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
    
    func deleteRepository(_ indexSet: IndexSet) {
        for index in indexSet {
            let repository = repositories[index]
            modelContext.delete(repository)
        }
    }
    
    @Sendable
    func fetchRepositories() async {
        logger.info("Call fetchRepositories(all) at \(Date())")
        
        do {
            guard let loginID = user?.login else {
                logger.debug("User loginID is null. Failed to fetchRepositories.")
                return
            }
            
            let fields: [QuerySearchFieldType] = [
                .created(username: loginID),
                .assigned(username: loginID),
                .requested(username: loginID)
            ]
            
            let nodes = try await withThrowingTaskGroup(of: (QuerySearchFieldType, [Node]).self) { group in
                for field in fields {
                    group.addTask {
                        logger.debug("Waiting for response the fetchPullRequests: \(field)")
                        let graph = try await session.fetchPullRequests(field: field)
                        logger.debug("Received the response for TaskGroup: \(field)")
                        return (field, graph.data.search.edges.map { $0.node })
                    }
                }
                
                var graphs: [QuerySearchFieldType: [Node]] = [:]
                
                for try await (field, node) in group {
                    graphs[field] = node
                }
                
                return graphs
            }
            
            self.createdNodes = nodes[.created(username: loginID)] ?? []
            self.assignedNodes = nodes[.assigned(username: loginID)] ?? []
            self.requestedNodes = nodes[.requested(username: loginID)] ?? []
            
            logger.info("All repositories has been fetched: \(Date())")
        } catch {
            logger.error("Failed to fetchRepositories with error: \(error)")
        }
    }
}

#Preview {
    HomeView(authToken: .constant(.init(accessToken: "1", tokenType: .bearer)))
        .modelContainer(PRtifyPreviewContainer.self)
        .environmentObject(PRtifyAppDelegate())
        .environmentObject(Preferences())
}
