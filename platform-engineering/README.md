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
- **Canary** – `canary-deployment-job.yml` orchestrates `preDeploy`, `deploy`, `routeTraffic`, and `postRouteTraffic` phases with stabilization timing. The default `Orchestrated` mode emits sequential deployment jobs (one per `canaryIncrements` value plus an automatic 100% finalizer) so environment-scoped targets can still simulate real canary waves. Switch `canaryStrategyMode` to `Native` only when the environment supports Azure Pipelines' built-in canary strategy. Workload teams can override the `canaryIncrements` map (default `{ CanaryStep_0: 25, CanaryStep_1: 50 }`) and the hold duration via `canaryStabilizationSeconds` (default `900`) to change the cadence without touching orchestration logic, and they may inject custom step templates for each phase (`preDeploy`, `deploy`, `routeTraffic`, `postRouteTraffic`, `success`, `failure`) to mirror the native canary semantics. For native mode, the auxiliary `nativeCanaryIncrements` array keeps Azure's built-in strategy fed with a simple list of percentages.
- **Blue-Green** – `blue-green-deployment-job.yml` provisions a green slot and optionally swaps traffic automatically.

Extend or override build/deploy steps by pointing the container pipeline parameters at alternate templates while still benefiting from the governed orchestration.