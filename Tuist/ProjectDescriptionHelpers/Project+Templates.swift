import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/

extension Project {
    /// Helper function to create the Project for this ExampleApp
    public static func app(
        name: String,
        platforms: [Platform],
        additionalTargets: [String],
        additionalDependencies: [TargetDependency]
    ) -> Project {
        var targets: [Target] = []
        for platform in platforms {
            targets += makeAppTargets(
                name: name,
                platform: platform,
                dependencies: additionalTargets.map { TargetDependency.target(name: $0) } + additionalDependencies
            )
        }
        let configurations: [Configuration] = [
            .debug(name: "Debug", settings: [:], xcconfig: .relativeToRoot("Configs/Debug.xcconfig")),
            .release(name: "Release", settings: [:], xcconfig: .relativeToRoot("Configs/Release.xcconfig"))
        ]
        return Project(name: name,
                       organizationName: organizationName,
                       settings: .settings(configurations: configurations),
                       targets: targets)
    }

    // MARK: - Private
    private static let organizationName = "is.byeon"

    /// Helper function to create a framework target and an associated unit test target
    private static func makeFrameworkTargets(name: String, platform: Platform) -> [Target] {
        let sources = Target(name: name,
                             platform: platform,
                             product: .framework,
                             bundleId: "\(organizationName).\(name)",
                             infoPlist: .default,
                             sources: ["Targets/\(name)/Sources/**"],
                             resources: [],
                             dependencies: [])
        let tests = Target(name: "\(name)Tests",
                           platform: platform,
                           product: .unitTests,
                           bundleId: "\(organizationName).\(name)Tests",
                           infoPlist: .default,
                           sources: ["Targets/\(name)/Tests/**"],
                           resources: [],
                           dependencies: [.target(name: name)])
        return [sources, tests]
    }

    /// Helper function to create the application target and the unit test target.
    private static func makeAppTargets(name: String, platform: Platform, dependencies: [TargetDependency]) -> [Target] {
        let platform: Platform = platform
        let platformDisplayName: String = platform.rawValue.replacingOccurrences(of: "os", with: "OS")
        
        let targetName: String = "\(name) (\(platformDisplayName))"
        let sourceFilesList: [String] = ["Shared", platformDisplayName]
            .map { "Targets/\(name)/Sources/\($0)/**" }
        
        let testSourceFilesList = ["Shared", platformDisplayName]
            .map { "Targets/\(name)/Tests/\($0)/**" }
        
        let resourceFilesList: [ResourceFileElement] = ["Shared", platformDisplayName]
            .map { "Targets/\(name)/Resources/\($0)/**" }
            .map { ResourceFileElement.glob(pattern: .relativeToRoot($0)) }
        
        let deploymentTarget: DeploymentTarget? = {
            switch platform {
            case .iOS: return .iOS(targetVersion: "17.0", devices: .iphone, supportsMacDesignedForIOS: false)
            case .macOS: return .macOS(targetVersion: "13.4")
            default: return nil
            }
        }()
        
        guard let deploymentTarget else { fatalError("Unknown deployment target: \(platform)") }
        
        let mainTarget = Target(
            name: targetName,
            platform: platform,
            product: .app,
            productName: name,
            bundleId: "\(organizationName).\(name)",
            deploymentTarget: deploymentTarget,
            infoPlist: .file(path: .relativeToRoot("Targets/\(name)/Resources/\(platformDisplayName)/\(name).plist")),
            sources: SourceFilesList(globs: sourceFilesList),
            resources: ResourceFileElements(resources: resourceFilesList),
            scripts: [.pre(path: .relativeToRoot("scripts/lint.sh"), name: "SwiftLint")],
            dependencies: dependencies
        )

        let testTarget = Target(
            name: "\(targetName)Tests",
            platform: platform,
            product: .unitTests,
            productName: "\(name)Tests",
            bundleId: "\(organizationName).\(name)Tests",
            deploymentTarget: deploymentTarget,
            infoPlist: .default,
            sources: SourceFilesList(globs: testSourceFilesList),
            dependencies: [
                .target(name: targetName)
            ])
        
        return [mainTarget, testTarget]
    }
}
