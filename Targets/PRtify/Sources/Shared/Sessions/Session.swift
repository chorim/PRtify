//
//  Session.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/24.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation
import Pulse

extension Dictionary {
    public static var empty: Self { [:] }
}

extension Session {
    public typealias HTTPParameters = [String: Any]
    public typealias HTTPHeaders = [String: String]
}

public class Session: Loggable {
    public static let shared: Session = {
        URLSessionProxyDelegate.enableAutomaticRegistration()
        return Session()
    }()

    public var apiKey: String {
        sessionConfiguration.apiKey
    }

    public var apiSecretKey: String {
        sessionConfiguration.apiSecretKey
    }
    
    public lazy var backgroundTaskSchedular: BackgroundTaskScheduler = BackgroundTaskScheduler(session: self)

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

    public func authorizeURL(grants scopes: [Scopes]) throws -> URL {
        let authorizeURL = URL(githubAPIWithPath: "login/oauth/authorize", isRoot: true)!

        let httpParameters: HTTPParameters = [
            "client_id": apiKey,
            "scope": scopes.map { $0.description }.joined(separator: " ")
        ]

        let urlRequset = try URLRequest(url: authorizeURL,
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

        let urlRequest = try URLRequest(url: issueTokenURL,
                                        httpMethod: .post,
                                        httpParameters: httpParameters)

        return try await urlSession.dataTask(for: urlRequest, AuthToken.self)
    }
    
    public func updateToken(with authToken: AuthToken) {
        urlSession.credential = SessionCredential(authToken: authToken)
    }
    
    public func fetchProfile() async throws -> User {
        let url = URL(githubAPIWithPath: "user")!
        
        let urlRequest = URLRequest(url: url)
        
        return try await urlSession.dataTask(for: urlRequest, User.self)
    }
    
    public func fetchPullRequests(by loginID: String) async throws -> [QuerySearchFieldType: [Node]] {
        let fields: [QuerySearchFieldType] = [
            .created(username: loginID),
            .assigned(username: loginID),
            .requested(username: loginID)
        ]
        
        return try await withThrowingTaskGroup(of: (QuerySearchFieldType, [Node]).self) { group in
            for field in fields {
                group.addTask {
                    self.logger.debug("Waiting for response the fetchPullRequests: \(field)")
                    let graph = try await self._fetchPullRequests(field: field)
                    self.logger.debug("Received the response for TaskGroup: \(field)")
                    return (field, graph.data.search.edges.map { $0.node })
                }
            }
            
            var graphs: [QuerySearchFieldType: [Node]] = [:]
            
            for try await (field, node) in group {
                graphs[field] = node
            }
            
            return graphs
        }
    }
    
    // MARK: Private
    private let sessionConfiguration: SessionConfiguration
    private let urlSession: URLSession
}

private extension Session {
    func _fetchPullRequests(field: QuerySearchFieldType) async throws -> Graph {
        let url = URL(githubAPIWithPath: "graphql")!
        
        let httpParameters: HTTPParameters = [
            "query": QueryGenerator.build(field: field),
            "variables": []
        ]
        
        let urlRequest = try URLRequest(url: url,
                                        httpMethod: .post,
                                        httpParameters: httpParameters)
        
        return try await urlSession.dataTask(for: urlRequest, Graph.self)
    }
}

public struct SessionCredential {
    let authToken: Session.AuthToken
}

public extension URLSession {
    private struct AssociatedKey {
        fileprivate static var credentialKey: Void?
   }
    
    static let decoder: JSONDecoder = {
        $0.dateDecodingStrategy = .iso8601
        return $0
    }(JSONDecoder())

    var credential: SessionCredential? {
        get { objc_getAssociatedObject(self, &AssociatedKey.credentialKey) as? SessionCredential }
        set { objc_setAssociatedObject(self, &AssociatedKey.credentialKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func dataTask<T: Decodable>(for urlRequest: URLRequest, _ model: T.Type) async throws -> T {
        var dataTask: URLSessionDataTask?
        
        let onSuccess: (Data, URLResponse) -> Void = { data, _ in
            guard let dataTask, let dataDelegate = self.delegate as? URLSessionDataDelegate else {
                return
            }
            dataDelegate.urlSession?(self, dataTask: dataTask, didReceive: data)
            dataDelegate.urlSession?(self, task: dataTask, didCompleteWithError: nil)
        }
        let onError: (Error) -> Void = { error in
            guard let dataTask, let dataDelegate = self.delegate as? URLSessionDataDelegate else {
                return
            }
            dataDelegate.urlSession?(self, task: dataTask, didCompleteWithError: error)
        }
        let onCancel: () -> Void = {
            dataTask?.cancel()
        }
        
        var mutableURLRequest = urlRequest
        
        if let credential {
            let authorization = [
                credential.authToken.tokenType.description,
                credential.authToken.accessToken
            ].joined(separator: " ")
            
            mutableURLRequest.setValue(authorization, forHTTPHeaderField: "Authorization")
        }
        
        return try await withTaskCancellationHandler(operation: {
            try await withCheckedThrowingContinuation { continuation in
                dataTask = self.dataTask(with: mutableURLRequest) { data, response, error in
                    guard let data = data, let response = response else {
                        let error = error ?? URLError(.badServerResponse)
                        onError(error)
                        return continuation.resume(throwing: error)
                    }
                    onSuccess(data, response)
                    
                    do {
                        let model = try Self.decoder.decode(T.self, from: data)
                        return continuation.resume(returning: model)
                    } catch {
                        onError(error)
                        return continuation.resume(throwing: error)
                    }
                }
                dataTask?.resume()
            }
        }, onCancel: {
            onCancel()
        })
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
