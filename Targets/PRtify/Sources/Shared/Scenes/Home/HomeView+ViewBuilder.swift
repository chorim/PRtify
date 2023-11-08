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
    var progressView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
            .background(Color.flatDarkCardBackground)
            .preferredColorScheme(.dark)
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
                    PullRequestView(node: node)
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
                    PullRequestView(node: node)
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
                    PullRequestView(node: node)
                }
                .listRowBackground(Color.flatDarkContainerBackground)
                
            case .empty:
                emptyView
            }
        }
    }
}

#if os(macOS)
extension HomeView {
    @ViewBuilder
    var quitButton: some View {
        Button {
            NSApplication.shared.terminate(nil)
        } label: {
            Text("Quit")
                .frame(maxWidth: .infinity, minHeight: 40)
                .background(Color.flatDarkCardBackground)
                .buttonStyle(.plain)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}
#endif
