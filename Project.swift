import ProjectDescription
import ProjectDescriptionHelpers
import PRtifyPlugin

// MARK: - Project

// Creates our project using a helper function defined in ProjectDescriptionHelpers
let project = Project.app(name: "PRtify",
                          platform: .iOS,
                          additionalTargets: [])
