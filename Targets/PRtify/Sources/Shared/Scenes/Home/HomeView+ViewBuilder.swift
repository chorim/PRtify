//
//  HomeView+ViewBuilder.swift
//  PRtify
//
//  Created by Insu Byeon on 10/12/23.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI

extension HomeView {
    // MARK: Views
    @ViewBuilder
    var emptyView: some View {
        ContentUnavailableView {
            Label("Empty Pull Requests", systemImage: "tray.fill")
        } description: {
            Text("New pull requests will be display here.")
        }
        .preferredColorScheme(.dark)
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

            Task {
                await fetchRepositories()
            }
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
                    progressView
                }
            }
        }
        .onDelete(perform: deleteRepository)
    }
    
    @ViewBuilder
    var progressView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
            .background(Color.flatDarkCardBackground)
            .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    var controlSectionView: some View {
        Section {
            if !repositories.isEmpty {
                refreshButton
                    .listRowBackground(Color.flatDarkCardBackground)
            }
            
            addButton
                .listRowBackground(Color.flatDarkCardBackground)
        }
    }
    
    @ViewBuilder
    var repositorySectionView: some View {
        Section(header: Text("Added repositories").foregroundColor(.white)) {
            if repositories.isEmpty {
                emptyView
            } else {
                repositoryView
                    .listRowBackground(Color.flatDarkContainerBackground)
            }
        }
    }
    
    @ViewBuilder
    var createdNodesView: some View {
        Section(header: Text("Created pull requests").foregroundColor(.white)) {
            
            switch createdNodes {
            case .loading:
                HStack {
                    Spacer()
                    progressView
                    Spacer()
                }
                
            case .loaded(let nodes):
                ForEach(nodes) { (node: Node) in
                    Text("\(node.title)")
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.flatDarkContainerBackground)
                
            case .empty:
                emptyView
            }
        }
    }
    
    @ViewBuilder
    var requestedNodesView: some View {
        Section(header: Text("Requested pull requests").foregroundColor(.white)) {
            
            switch requestedNodes {
            case .loading:
                HStack {
                    Spacer()
                    progressView
                    Spacer()
                }
                
            case .loaded(let nodes):
                ForEach(nodes) { (node: Node) in
                    Text("\(node.title)")
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.flatDarkContainerBackground)
                
            case .empty:
                emptyView
            }
        }
    }
    
    @ViewBuilder
    var assignedNodesView: some View {
        Section(header: Text("Assigned pull requests").foregroundColor(.white)) {
            
            switch assignedNodes {
            case .loading:
                HStack {
                    Spacer()
                    progressView
                    Spacer()
                }
                
            case .loaded(let nodes):
                ForEach(nodes) { (node: Node) in
                    Text("\(node.title)")
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.flatDarkContainerBackground)
                
            case .empty:
                emptyView
            }
        }
    }
}
