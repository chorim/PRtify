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
    
    public init(configuration: URLSessionConfiguration = .prfy_default) {
        self.urlSessionConfiguration = configuration
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

        let httpParameters: HTTPParameters = ["client_id": "15c305090f7833520cf8",
                                              "scopes": scopes.map { $0.description }.joined(separator: ",")]
        
        let urlRequset = URLRequest(url: authorizeURL,
                                    httpMethod: .get,
                                    httpParameters: httpParameters)
        return urlRequset.url!
        
        //prtify://oauth?code=7fbd917f8570bb612acc
    }
    
    // public func fetchRequestForToken() async throws -> OAuthToken {
    //     var urlRequest = URLRequest(url: authorizeURL)
    //     
    //     return OAuthToken()
    // }
    
    // MARK: Private
    private let urlSessionConfiguration: URLSessionConfiguration
    private var urlSession = URLSession(configuration: .prfy_default)
    
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
