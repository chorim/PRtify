//
//  Session.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/24.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation

public class Session {
    public static let shared = Session()
    
    public init(configuration: URLSessionConfiguration = .prfy_default) {
        self.urlSessionConfiguration = configuration
    }
    
    public func data(for request: URLRequest) async throws -> Data {
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw SessionError.invalidResponse }
        
        guard (200..<300).contains(httpResponse.statusCode) else { throw SessionError.invalidStatusCode }
        
        return data
    }
    
    public func fetchRequestForToken() async throws -> OAuthToken {
        let authorizeURL = URL(githubAPIWithPath: "login/oauth/authorize")!
        var urlRequest = URLRequest(url: authorizeURL)
        
        return OAuthToken()
    }
    
    // MARK: Private
    private let urlSessionConfiguration: URLSessionConfiguration
    private var urlSession = URLSession(configuration: .prfy_default)
    
}

public extension URLSessionConfiguration {
    static var prfy_default: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = {
            var httpAdditionalHeaders = configuration.httpAdditionalHeaders ?? [:]
            
            httpAdditionalHeaders["Accept"] = "application/vnd.github.v3+json"
            
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
