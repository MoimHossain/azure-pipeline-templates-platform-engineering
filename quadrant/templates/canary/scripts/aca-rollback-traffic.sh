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

declare -a revisions
mapfile -t revisions < <(az containerapp revision list \
  --name "$ACA_CONTAINER_APP" \
  --resource-group "$ACA_RESOURCE_GROUP" \
  --query "[?properties.active==true].{name:name,weight:properties.trafficWeight}" \
  -o tsv)

if [[ ${#revisions[@]} -eq 0 ]]; then
  echo "##vso[task.logissue type=error]No active revisions found for rollback"
  exit 1
fi

declare rollback_target=""
max_weight=-1
for entry in "${revisions[@]}"; do
  rev_name=$(echo "$entry" | awk '{print $1}')
  rev_weight=$(echo "$entry" | awk '{print $2}')
  if [[ $rev_weight -gt $max_weight ]]; then
    max_weight=$rev_weight
    rollback_target=$rev_name
  fi
done

if [[ -z "$rollback_target" ]]; then
  echo "##vso[task.logissue type=error]Unable to determine rollback revision"
  exit 1
fi

ez containerapp revision set-weight \
  --name "$ACA_CONTAINER_APP" \
  --resource-group "$ACA_RESOURCE_GROUP" \
  --revision-weight "${rollback_target}=100" \
  >/dev/null

echo "All traffic returned to ${rollback_target}"
