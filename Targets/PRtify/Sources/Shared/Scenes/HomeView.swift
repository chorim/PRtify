//
//  HomeView.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/26.
//  Copyright © 2023 is.byeon. All rights reserved.
//

import SwiftUI

struct HomeView: View, Loggable {
    @Environment(\.session) private var session: Session
    @Binding var authToken: Session.AuthToken?
    
    @State var user: User? = nil
    @State var error: Error? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("Hello, Home!")
                        
                    Button {
                        authToken = nil
                        logger.info("Sign out")
                    } label: {
                        Text("Sign Out")
                    }
                }
            }
            .alert(error: $error)
            .task(getProfile)
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    avatarView
                }
            }
        }
    }
    
    @Sendable
    func getProfile() async {
        // TODO: Handling the network connection when preview state
        guard await !PRtifyApp.isPreview else { return }
        
        do {
            self.user = try await session.getProfile()
        } catch {
            self.error = error
            logger.error("getProfile() error: \(error.localizedDescription)")
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
}

#Preview {
    HomeView(authToken: .constant(nil))
}
