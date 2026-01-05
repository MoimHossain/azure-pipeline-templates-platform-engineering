#!/usr/bin/env bash
set -euo pipefail

required_vars=(
  ENTRA_CLIENT_ID
  ENTRA_CLIENT_SECRET
  ENTRA_TENANT_ID
  ACA_SUBSCRIPTION_ID
  ACA_RESOURCE_GROUP
  ACA_CONTAINER_APP
)

for var in "${required_vars[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "##vso[task.logissue type=error]Missing environment variable: $var"
    exit 1
  fi
done

az login \
  --service-principal \
  --username "$ENTRA_CLIENT_ID" \
  --password "$ENTRA_CLIENT_SECRET" \
  --tenant "$ENTRA_TENANT_ID" \
  >/dev/null
az account set --subscription "$ACA_SUBSCRIPTION_ID"

az containerapp revision set-mode \
  --name "$ACA_CONTAINER_APP" \
  --resource-group "$ACA_RESOURCE_GROUP" \
  --mode multiple \
  >/dev/null

echo "Revision mode set to 'multiple' for $ACA_CONTAINER_APP"
