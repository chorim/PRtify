//
//  URLRequest+Extensions.swift
//  PRtify
//
//  Created by Insu Byeon on 2023/09/01.
//  Copyright © 2023 tuist.io. All rights reserved.
//

import Foundation

extension URLRequest {
    static let encoder: JSONEncoder = .init()
    
    public init(url: URL,
                httpMethod: Session.HTTPMethod,
                httpParameters: Session.HTTPParameters,
                httpHeaders: Session.HTTPHeaders = [:]) throws {
        var mutableURL = url

        let encoding = URLEncoding()

        if httpMethod == .get {
            mutableURL = url.appendingQueryParameters(httpParameters, encoding: encoding)
        }

        self.init(url: mutableURL)

        self.httpMethod = "\(httpMethod)"

        var mutableHttpHeaders = httpHeaders
        mutableHttpHeaders.merge(httpHeaders) { _, new in new }
        mutableHttpHeaders.forEach { addValue($0.value, forHTTPHeaderField: $0.key) }

        if httpMethod == .post || httpMethod == .put {
            // self.httpBody = encoding.query(httpParameters).data(using: .utf8)
            httpBody = try JSONSerialization.data(withJSONObject: httpParameters, options: .prettyPrinted)
        }
    }
}
