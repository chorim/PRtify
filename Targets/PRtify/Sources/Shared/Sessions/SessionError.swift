//
//  SessionError.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/08/31.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation

public enum SessionError: Error {
    case invalidResponse
    case invalidStatusCode
}
