#!/usr/bin/env bash
set -euo pipefail

required_vars=(
  ENTRA_CLIENT_ID
  ENTRA_CLIENT_SECRET
  ENTRA_TENANT_ID
  ACA_SUBSCRIPTION_ID
  ACA_RESOURCE_GROUP
  ACA_CONTAINER_APP
  ACA_REVISION_SUFFIX
  ACA_HEALTH_ENDPOINT
  INCREMENT_PERCENT
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

revision_name="${ACA_CONTAINER_APP}--${ACA_REVISION_SUFFIX}"

fqdn=$(az containerapp revision show \
  --name "$ACA_CONTAINER_APP" \
  --resource-group "$ACA_RESOURCE_GROUP" \
  --revision "$revision_name" \
  --query "properties.fqdn" \
  -o tsv)

if [[ -z "$fqdn" ]]; then
  echo "##vso[task.logissue type=error]Unable to determine FQDN for ${revision_name}"
  exit 1
fi

url="https://${fqdn}${ACA_HEALTH_ENDPOINT}"
echo "[Quadrant] Probing ${url} (traffic ${INCREMENT_PERCENT}%)"
response=$(curl -fsS "$url")
echo "Health response: $response"

export HEALTH_RESPONSE="$response"
healthy=$(python - <<'PY'
import json, os
payload = json.loads(os.environ["HEALTH_RESPONSE"])
print(str(payload.get("healthy", False)).lower())
PY
)

if [[ "$healthy" != "true" ]]; then
  echo "##vso[task.logissue type=error]Health probe reported unhealthy"
  exit 1
fi

echo "Revision ${revision_name} reported healthy"
