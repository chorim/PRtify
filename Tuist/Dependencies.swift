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
            .remote(url: "https://github.com/kishikawakatsumi/KeychainAccess", requirement: .upToNextMajor(from: "4.2.0")),
            .remote(url: "https://github.com/siteline/swiftui-introspect", requirement: .upToNextMajor(from: "1.1.0")),
            .remote(url: "https://github.com/kean/Pulse", requirement: .upToNextMajor(from: "4.0.0"))
        ]
    )
)
