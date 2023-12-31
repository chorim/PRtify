//
//  SignInView.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/30.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import SwiftUI
import AuthenticationServices
import Logging

struct SignInView: View {
    @Environment(\.session) private var session: Session

    @State private var webAuthenticationSession: ASWebAuthenticationSession?
    @State private var error: Error?
    
    @Binding var authToken: Session.AuthToken?
    
    private let logger = Logger(category: "SignInView")
    
    var body: some View {
        ZStack {
            Color.flatDarkBackground.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                AsyncButton("Sync in with GitHub", action: signIn)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(Color.white)
                    .clipShape(RoundedRectangle(cornerSize: .init(width: 12, height: 12)))
                    .buttonStyle(.plain)
                
                if let webAuthenticationSession {
                    WebAuthenticationView(webAuthenticationSession: webAuthenticationSession)
                        .frame(width: 0, height: 0)
                }
            }
        }
        .alert(error: $error)
    }

    @MainActor
    func signIn() async {
        do {
            defer {
                self.webAuthenticationSession = nil
            }
            
            let authToken = try await session.authorize(grants: [.repo, .user]) { webAuthenticationSession in
                webAuthenticationSession.prefersEphemeralWebBrowserSession = true
            
                self.webAuthenticationSession = webAuthenticationSession
            }

            self.authToken = authToken
        } catch {
            logger.error("Sign in with GitHub error: \(error.localizedDescription)")
            self.error = error
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(authToken: .constant(nil))
            .previewLayout(.fixed(width: 320, height: 100))
    }
}
