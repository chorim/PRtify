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
    
    @State private var user: User? = nil
    @State private var error: Error? = nil
    
    @State private var showingRepositoriesAddView: Bool = false
    @State private var showingProfileView: Bool = false
    
    @Query(sort: [SortDescriptor(\Repository.createdAt, order: .reverse)], animation: .smooth)
    private var repositories: [Repository]
    
    var body: some View {
        NavigationStack {
            Group {
                if authToken != nil {
                    List {
                        if repositories.isEmpty {
                            emptyView
                        } else {
                            repositoryView
                                .listRowBackground(Color.flatDarkContainerBackground)
                        }
                        
                        Section {
                            if !repositories.isEmpty {
                                refreshButton
                                    .listRowBackground(Color.flatDarkCardBackground)
                            }
                            
                            addButton
                                .listRowBackground(Color.flatDarkCardBackground)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .task(fetchProfile)
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
            if let user {
                ProfileView(user: Binding { user } set: { self.user = $0 })
            }
        }
        .onChange(of: user) { _, new in
            preferences.user = new
        }
        .alert(error: $error)
    }

    @Sendable
    func fetchProfile() async {
        guard !PRtifyApp.isPreview else {
            self.user = .mock
            return
        }
        
        do {
            self.user = try await session.fetchProfile()
        } catch {
            self.error = error
            logger.error("fetchProfile() error: \(error.localizedDescription)")
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
        logger.info("Called fetchRepositories at \(Date())")
    }
    
    // MARK: Views
    @ViewBuilder
    var emptyView: some View {
        ContentUnavailableView {
            Label("Empty repository", systemImage: "tray.fill")
        } description: {
            Text("New repository you added will be display here.")
        }
    }
    
    @ViewBuilder
    var addButton: some View {
        Button {
            self.showingRepositoriesAddView = true
        } label: {
            HStack {
                Spacer()
                Label("Add", systemImage: "plus")
                    .foregroundStyle(.white)
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var refreshButton: some View {
        Button {
            logger.debug("User tapped refresh button: \(Date())")

        } label: {
            HStack {
                Spacer()
                Label("Refresh", systemImage: "arrow.clockwise")
                    .foregroundStyle(.white)
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var repositoryView: some View {
        ForEach(repositories) { repository in
            HStack {
                Text("\(repository.url.absoluteString)")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
             
                switch repository.status {
                case .connected:
                    Image(systemName: "checkmark")
                        .renderingMode(.template)
                        .foregroundStyle(.green)
                    
                case .disconnected:
                    Image(systemName: "xmark")
                        .renderingMode(.template)
                        .foregroundStyle(.red)
                    
                case .underlying:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .background(Color.flatDarkCardBackground)
                }
            }
            .task(fetchRepositories)
        }
        .onDelete(perform: deleteRepository)
    }
}

#Preview {
    HomeView(authToken: .constant(.init(accessToken: "1", tokenType: .bearer)))
        .modelContainer(PRtifyPreviewContainer.self)
        .environmentObject(PRtifyAppDelegate())
        .environmentObject(Preferences())
}
