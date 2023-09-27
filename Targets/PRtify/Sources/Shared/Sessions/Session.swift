//
//  Session.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/24.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation

extension Dictionary {
    public static var empty: Self { [:] }
}

extension Session {
    public typealias HTTPParameters = [String: Any]
    public typealias HTTPHeaders = [String: String]
}

public class Session: Loggable {
    public static let shared = Session()

    public var apiKey: String {
        sessionConfiguration.apiKey
    }

    public var apiSecretKey: String {
        sessionConfiguration.apiSecretKey
    }

    public init(configuration: SessionConfiguration = .default) {
        self.sessionConfiguration = configuration
        self.urlSession = URLSession(configuration: configuration.sessionConfiguration)
    }

    public func data(for request: URLRequest) async throws -> Data {
        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SessionError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw SessionError.invalidStatusCode
        }

        return data
    }

    public func authorizeURL(grants scopes: [Scopes]) -> URL {
        let authorizeURL = URL(githubAPIWithPath: "login/oauth/authorize", isRoot: true)!

        let httpParameters: HTTPParameters = [
            "client_id": apiKey,
            "scope": scopes.map { $0.description }.joined(separator: " ")
        ]

        let urlRequset = URLRequest(url: authorizeURL,
                                    httpMethod: .get,
                                    httpParameters: httpParameters)

        return urlRequset.url!
    }

    public func fetchRequestForToken(code: String) async throws -> AuthToken {
        let issueTokenURL = URL(githubAPIWithPath: "login/oauth/access_token", isRoot: true)!

        logger.debug("issueTokenURL: \(issueTokenURL)")

        let httpParameters: HTTPParameters = [
            "client_id": apiKey,
            "client_secret": apiSecretKey,
            "code": code
        ]

        let urlRequest = URLRequest(url: issueTokenURL,
                                    httpMethod: .post,
                                    httpParameters: httpParameters)

        return try await urlSession.data(for: urlRequest, AuthToken.self)
    }
    
    public func updateToken(with authToken: AuthToken) {
        urlSession.credential = SessionCredential(authToken: authToken)
    }
    
    public func getProfile() async throws -> User {
        let url = URL(githubAPIWithPath: "user")!
        
        let urlRequest = URLRequest(url: url)
        
        return try await urlSession.data(for: urlRequest, User.self)
    }

    // MARK: Private
    private let sessionConfiguration: SessionConfiguration
    private let urlSession: URLSession
}

public struct SessionCredential {
    let authToken: Session.AuthToken
}

public extension URLSession {
    private struct AssociatedKey {
        fileprivate static var credentialKey: Void?
   }
    
    static let decoder: JSONDecoder = .init()

    var credential: SessionCredential? {
        get { objc_getAssociatedObject(self, &AssociatedKey.credentialKey) as? SessionCredential }
        set { objc_setAssociatedObject(self, &AssociatedKey.credentialKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func data<T: Decodable>(for urlRequest: URLRequest, _ model: T.Type) async throws -> T {
        var mutableURLRequest = urlRequest
        
        if let credential {
            let authorization = [
                credential.authToken.tokenType.description,
                credential.authToken.accessToken
            ].joined(separator: " ")
            
            mutableURLRequest.setValue(authorization, forHTTPHeaderField: "Authorization")
        }
        
        let (data, _) = try await self.data(for: mutableURLRequest)
        return try Self.decoder.decode(T.self, from: data)
    }
}

public extension URLSessionConfiguration {
    static var prfy_default: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = {
            var httpAdditionalHeaders = configuration.httpAdditionalHeaders ?? [:]

            httpAdditionalHeaders["Accept"] = "application/json"

            let preferredLanguages = Set(Locale.preferredLanguages.flatMap { [$0, $0.components(separatedBy: "-")[0]] } + ["*"])
            httpAdditionalHeaders["Accept-Language"] = preferredLanguages.joined(separator: ", ")

            let preferredEncoding = Set(["gzip", "deflate", "br"])
            httpAdditionalHeaders["Accept-Encoding"] = preferredEncoding.joined(separator: ", ")

            return httpAdditionalHeaders
        }()

        configuration.timeoutIntervalForRequest = 10

        return configuration
    }
}
