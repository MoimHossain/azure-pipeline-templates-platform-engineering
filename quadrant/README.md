# Quadrant Project
Although this folder is part of the same repository for the sake of this example, always assume that this folder resides in a separate repository (also a separate project in Azure DevOps) that is consumed by the workload team via their own Azure Pipeline YAML files.

This project contains workload-specific pipeline templates that extend the base templates defined in the platform-engineering project.

## Using the platform templates

`azure-pipelines.yml` shows how the workload team references the platform templates via the repo alias `Platform-Engineering` and only provides the workload-specific inputs:

- `productName`, `imageName`, and `deployEnvironmentName`
- Strategy choice via `containerDeploymentStrategy` (Rolling, Canary, or BlueGreen)
- Optional knobs (`blueGreenSwapMode`, the `canaryIncrements` map, `canaryStabilizationSeconds`, `canaryHealthCheckStepsTemplate`, etc.) and manifest-specific parameters
- For orchestrated canary rollouts, workload-owned step templates live under `templates/canary/` and are passed through parameters like `canaryPreDeployStepsTemplate`, `canaryRouteTrafficStepsTemplate`, `canaryHealthCheckStepsTemplate`, and `canarySuccessStepsTemplate` to customize each phase while the platform template manages job orchestration.

`templates/canary/deploy.yml` lets the workload specify either Kubernetes manifest inputs or a custom `platformDeployTemplate` (plus parameters) so different container platforms can plug into the same platform-owned orchestration.

## Azure Container Apps canary

The sample canary pipeline now demonstrates how a workload team can roll out a Docker image to Azure Container Apps (`canary-api-demo` inside the `ContainerApps` resource group) using platform orchestration:

- The build stage (see `templates/build/build.yml`) publishes the .NET workload in `src/` and builds/pushes `moimhossain/canary-api:<git-sha>` to Docker Hub via the `DockerHub` service connection.
- `templates/canary/deploy.yml` leverages `templates/canary/aca-deploy.yml` to ensure a new ACA revision (suffix `canary-$(Build.BuildId)`) exists for the latest image and switches the app to multi-revision traffic mode.
- `templates/canary/route-traffic.yml` uses Azure CLI to gradually reassign traffic (20/50/80/100) between the previous revision and the new revision.
- `templates/canary/health-check.yml` queries the revision-specific FQDN with `curl https://<revision>/api/health` and fails fast if `{ "healthy": true }` is not returned.

The pipeline authenticates with Azure by running `az login --service-principal` using the predefined `ENTRA_CLIENT_ID`, `ENTRA_CLIENT_SECRET`, and `ENTRA_TENANT_ID` variables. Update `azure-pipelines-canary.yml` with your own subscription ID, resource group, container app name, and health endpoint when adapting this sample to a different workload.

The platform templates take care of checkout, build orchestration, and deployment strategy wiring so workload teams stay focused on their container artifact details. 