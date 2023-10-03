//
//  HomeView.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/26.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI
import SwiftData

struct HomeView: View, Loggable {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.session) private var session: Session
    
    @Binding var authToken: Session.AuthToken?
    
    @State private var user: User? = nil
    @State private var error: Error? = nil
    
    @State private var showingRepositoriesAddView: Bool = false
    
    @Query(sort: [SortDescriptor(\Repository.createdAt, order: .reverse)], animation: .smooth)
    private var repositories: [Repository]
    
    var body: some View {
        NavigationView {
            if authToken != nil {
                List {
                    if repositories.isEmpty {
                        emptyView
                    } else {
                        ForEach(repositories) { repository in
                            Text("\(repository.url.absoluteString)")
                                .font(.headline)
                        }
                    }
                    
                    Section {
                        addButton
                    }
                }
                .task(fetchProfile)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        avatarView
                    }
                }
                .navigationTitle("Home")
            } else {
                SignInView(authToken: $authToken)
                    .navigationTitle("Home")
            }
        }
        .sheet(isPresented: $showingRepositoriesAddView) {
            RepositoriesAddView(showingRepositoriesAddView: $showingRepositoriesAddView)
        }
        .alert(error: $error)
    }

    @Sendable
    func fetchProfile() async {
        // TODO: Handling the network connection when preview state
        guard await !PRtifyApp.isPreview else {
            self.user = .init(
                id: 0,
                url: URL(string: "https://github.com/chorim")!,
                avatarURL: URL(string: "https://avatars.githubusercontent.com/u/11539551?v=4")!,
                name: "Chorim"
            )
            return
        }
        
        do {
            self.user = try await session.fetchProfile()
        } catch {
            self.error = error
            logger.error("fetchProfile() error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Views
    @ViewBuilder
    var avatarView: some View {
        if let user {
            AsyncImage(
                url: user.avatarURL,
                content: { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 42, maxHeight: 42)
                        .clipShape(Circle())
                },
                placeholder: {
                    ProgressView()
                }
            )
        }
    }
    
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
            Label("Add", systemImage: "plus")
        }
    }
}

#Preview {
    HomeView(authToken: .constant(.init(accessToken: "1", tokenType: .bearer)))
}
