# platform-engineering

Although this folder is part of the same repository for the sake of this example, always assume that this folder resides in a separate repository (also a separate project in Azure DevOps) that is consumed by workload teams via referencing these templates in their own Azure Pipeline YAML files.

## Template stack

| Template | Purpose |
| --- | --- |
| `templates/governed-pipeline-base.yml` | Provides the opinionated CI/CD skeleton with build/deploy extensibility points. |
| `templates/container-workloads/container-pipeline-base.yml` | Specializes the governed base for containerized workloads (builds images, chooses deployment strategy). |
| `templates/container-workloads/container-build-steps.yml` | Default build steps injected into the governed base. |
| `templates/container-workloads/container-app-simple-deploy-steps.yml` | Default deploy steps consumed by strategy jobs. |
| `templates/container-workloads/deployment-strategies/*.yml` | Discrete deployment strategies (Rolling, Canary, Blue-Green) exposed to workload teams as simple parameter choices. |

## Deployment strategy support

The platform team owns the orchestration logic. Workload teams only choose the `containerDeploymentStrategy` parameter and, optionally, supply strategy-specific knobs (for example `blueGreenSwapMode` or `canaryTrafficPercent`). Each strategy template injects the same deploy steps to keep workload surface area minimal:

- **Rolling** – `rolling-deployment-job.yml` performs a standard `runOnce` deployment.
- **Canary** – `canary-deployment-job.yml` orchestrates `preDeploy`, `deploy`, `routeTraffic`, and `postRouteTraffic` phases with stabilization timing.
- Canary deployments now rely on Azure Pipelines' native `canary` strategy with configurable `canaryIncrements` (defaults are 25% and 50%) so platform owners define rollout cadence once and workload teams override only when needed.
- **Blue-Green** – `blue-green-deployment-job.yml` provisions a green slot and optionally swaps traffic automatically.

Extend or override build/deploy steps by pointing the container pipeline parameters at alternate templates while still benefiting from the governed orchestration.