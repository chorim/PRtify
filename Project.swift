import ProjectDescription
import ProjectDescriptionHelpers
import PRtifyPlugin

// MARK: - Project

// Creates our project using a helper function defined in ProjectDescriptionHelpers
let project = Project.app(name: "PRtify",
                          platforms: [.iOS, .macOS/*, .watchOS*/],
                          additionalTargets: [],
                          additionalDependencies: [
                            .external(name: "KeychainAccess"),
                            .external(name: "SwiftUIIntrospect"),
                            .external(name: "Pulse"),
                            .external(name: "PulseUI")
                          ])
