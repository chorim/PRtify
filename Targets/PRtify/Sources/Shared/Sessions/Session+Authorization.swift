//
//  Session+Authorization.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/31.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation
import AuthenticationServices

public extension Session {
    @MainActor
    func authorize(
        grants scopes: [Scopes],
        webAuthenticationSessionHandler: @escaping (ASWebAuthenticationSession) -> Void
    ) async throws -> AuthToken {
        let authorizeURL = try await authorizeURL(grants: scopes)

        let url: URL = try await withCheckedThrowingContinuation { continuation in
            webAuthenticationSessionHandler(
                ASWebAuthenticationSession(url: authorizeURL, callbackURLScheme: "prtify") { url, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: url!)
                    }
                }
            )
        }

        guard let code = url.queryDictionary?["code"] else {
            throw SessionError.missingArguments
        }

        let authToken = try await fetchRequestForToken(code: code)

        return authToken
    }
}
