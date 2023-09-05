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

public class Session {
    public typealias HTTPParameters = [String: Any]
    public typealias HTTPHeaders = [String: String]
    
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
            "scopes": scopes.map { $0.description }.joined(separator: ",")
        ]
        
        let urlRequset = URLRequest(url: authorizeURL,
                                    httpMethod: .get,
                                    httpParameters: httpParameters)
        
        return urlRequset.url!
    }
    
    public func fetchRequestForToken(code: String) async throws -> AuthToken {
        let issueTokenURL = URL(githubAPIWithPath: "login/oauth/access_token", isRoot: true)!
        
        let httpParameters: HTTPParameters = [
            "client_id": apiKey,
            "client_secret": apiSecretKey,
            "code": code
        ]
        
        let urlRequest = URLRequest(url: issueTokenURL,
                                    httpMethod: .post,
                                    httpParameters: httpParameters)
        
        let (data, _) = try await urlSession.data(for: urlRequest)
        
        print(String(data: data, encoding: .utf8))
        let authToken = try JSONDecoder().decode(AuthToken.self, from: data)
        
        return authToken
    }
    
    // MARK: Private
    private let sessionConfiguration: SessionConfiguration
    private let urlSession: URLSession
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
