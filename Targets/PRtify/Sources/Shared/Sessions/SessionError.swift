//
//  SessionError.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/31.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation

public enum SessionError: Error {
    case missingArguments
    case invalidResponse
    case invalidStatusCode(Int)
}

extension SessionError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingArguments:
            return "Missing the arguments from server."
        case .invalidResponse:
            return "Invalid the response from server."
        case .invalidStatusCode(let code):
            return "Invalid the status code from server. code: \(code)"
        }
    }
}
