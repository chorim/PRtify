//
//  SessionConfiguration.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/28.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation

public struct SessionConfiguration {
    public static let `default`: SessionConfiguration = {
        let infoDictionary = Bundle.main.infoDictionary

        guard
            let apiKey = infoDictionary?["GITHUB_API_KEY"] as? String,
            let apiSecretKey = infoDictionary?["GITHUB_API_SECRET"] as? String
        else { fatalError("Unavailable Github API Credentials") }

        return SessionConfiguration(apiKey: apiKey, apiSecretKey: apiSecretKey)
    }()

    public let apiKey: String
    public let apiSecretKey: String
    public let sessionConfiguration: URLSessionConfiguration

    init(
        apiKey: String,
        apiSecretKey: String,
        sessionConfiguration: URLSessionConfiguration = .prfy_default
    ) {
        self.apiKey = apiKey
        self.apiSecretKey = apiSecretKey
        self.sessionConfiguration = sessionConfiguration
    }
}
