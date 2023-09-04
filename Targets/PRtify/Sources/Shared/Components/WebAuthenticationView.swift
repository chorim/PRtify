//
//  WebAuthenticationView.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/01.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import SwiftUI
import AuthenticationServices

struct WebAuthenticationView {
    let webAuthenticationSession: ASWebAuthenticationSession
}

#if os(macOS)
extension WebAuthenticationView: NSViewRepresentable {
    class View: NSView {
        private let authenticationSession: ASWebAuthenticationSession

        init(authenticationSession: ASWebAuthenticationSession) {
            self.authenticationSession = authenticationSession

            super.init(frame: .zero)

            self.authenticationSession.presentationContextProvider = self
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func draw(_ dirtyRect: NSRect) {
            NSColor.clear.setFill()
            dirtyRect.fill()
        }

        func start() {
            guard window != nil else {
                DispatchQueue.main.async { self.start() }
                return
            }

            authenticationSession.start()
        }

        func cancel() {
            authenticationSession.cancel()
        }
    }

    func makeNSView(context: Context) -> View {
        let view = View(authenticationSession: webAuthenticationSession)

        return view
    }

    func updateNSView(_ nsView: View, context: Context) {
        nsView.start()
    }

    static func dismantleNSView(_ nsView: View, coordinator: ()) {
        nsView.cancel()
    }
}
#elseif os(iOS)
extension WebAuthenticationView: UIViewRepresentable {
    class View: UIView {
        private let authenticationSession: ASWebAuthenticationSession

        init(authenticationSession: ASWebAuthenticationSession) {
            self.authenticationSession = authenticationSession

            super.init(frame: .zero)

            self.backgroundColor = .clear
            self.authenticationSession.presentationContextProvider = self
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func start() {
            guard window != nil else {
                DispatchQueue.main.async { self.start() }
                return
            }

            authenticationSession.start()
        }

        func cancel() {
            authenticationSession.cancel()
        }
    }

    func makeUIView(context: Context) -> View {
        let view = View(authenticationSession: webAuthenticationSession)

        return view
    }

    func updateUIView(_ uiView: View, context: Context) {
        uiView.start()
    }

    static func dismantleUIView(_ uiView: View, coordinator: ()) {
        uiView.cancel()
    }
}
#endif

#if os(macOS) || os(iOS)
extension WebAuthenticationView.View: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return window!
    }
}
#endif

//
// struct WebAuthenticationView: View {
//     var body: some View {
//         Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//     }
// }
//
// struct WebAuthenticationView_Previews: PreviewProvider {
//     static var previews: some View {
//         WebAuthenticationView()
//     }
// }
