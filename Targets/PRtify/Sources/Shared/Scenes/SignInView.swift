//
//  SignInView.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/30.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View, Loggable {
    @Environment(\.session) private var session: Session

    @AppStorage("authToken") private var authToken: Session.AuthToken? = nil

    @State private var webAuthenticationSession: ASWebAuthenticationSession?

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if authToken != nil {
                    Text("Logged in!")
                        .onAppear {
                            if let authToken {
                                logger.debug("Logged in: \(String(describing: authToken), privacy: .public)")
                            }
                        }

                    Button {
                        authToken = nil
                        logger.debug("Logged out")
                    } label: {
                        Text("Logged out")
                    }
                } else {
                    if let webAuthenticationSession {
                        WebAuthenticationView(webAuthenticationSession: webAuthenticationSession)
                    }
                }
            }
            .onAppear(perform: {
                Task {
                    do {
                        let authToken = try await session.authorize(grants: [.repo, .user]) { webAuthenticationSession in
                            webAuthenticationSession.prefersEphemeralWebBrowserSession = true

                            self.webAuthenticationSession = webAuthenticationSession
                        }

                        self.authToken = authToken
                    } catch {
                        print("Error", error, error.localizedDescription)
                    }

                }

            })
            .navigationTitle("Sign In")
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
