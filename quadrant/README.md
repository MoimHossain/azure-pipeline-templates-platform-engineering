# Quadrant Project
Although this folder is part of the same repository for the sake of this example, always assume that this folder resides in a separate repository (also a separate project in Azure DevOps) that is consumed by the workload team via their own Azure Pipeline YAML files.

This project contains workload-specific pipeline templates that extend the base templates defined in the platform-engineering project.

## Using the platform templates

`azure-pipelines.yml` shows how the workload team references the platform templates via the repo alias `Platform-Engineering` and only provides the workload-specific inputs:

- `productName`, `imageName`, and `deployEnvironmentName`
- Strategy choice via `containerDeploymentStrategy` (Rolling, Canary, or BlueGreen)
- Optional knobs (`blueGreenSwapMode`, `canaryTrafficPercent`, etc.) and manifest-specific parameters

The platform templates take care of checkout, build orchestration, and deployment strategy wiring so workload teams stay focused on their container artifact details.