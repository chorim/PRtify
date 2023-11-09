//
//  Dependencies.swift
//  Config
//
//  Created by Insu Byeon on 2023/09/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let dependencies = Dependencies(
    swiftPackageManager: SwiftPackageManagerDependencies(
        [
            .remote(url: "https://github.com/kishikawakatsumi/KeychainAccess", requirement: .exact("4.2.0")),
            .remote(url: "https://github.com/siteline/swiftui-introspect", requirement: .exact("1.1.0")),
            .remote(url: "https://github.com/kean/Pulse", requirement: .exact("4.0.3")),
            .remote(url: "https://github.com/apple/swift-log", requirement: .exact("1.5.3")),
            .remote(url: "https://github.com/kean/PulseLogHandler", requirement: .exact("4.0.1"))
        ]
    )
)
