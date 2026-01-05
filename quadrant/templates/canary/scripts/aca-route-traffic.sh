#!/usr/bin/env bash
az login \
  --service-principal \
  --username "$ENTRA_CLIENT_ID" \
  --password "$ENTRA_CLIENT_SECRET" \
  --tenant "$ENTRA_TENANT_ID" \
  >/dev/null
az account set --subscription "$ACA_SUBSCRIPTION_ID"

revision_name="${ACA_CONTAINER_APP}--${ACA_REVISION_SUFFIX}"
target_weight="$TARGET_WEIGHT"

echo "Routing ${target_weight}% traffic to ${revision_name}"

base_revision=$(az containerapp revision list \
  --name "$ACA_CONTAINER_APP" \
  --resource-group "$ACA_RESOURCE_GROUP" \
  --query "max_by([?name!='${revision_name}' && properties.active==true], &properties.trafficWeight).name" \
  -o tsv)

if [[ -z "$base_revision" || "$base_revision" == "None" ]]; then
  base_weight=0
else
  base_weight=$((100 - target_weight))
fi

if [[ $target_weight -ge 100 || $base_weight -le 0 ]]; then
  az containerapp revision set-weight \
    --name "$ACA_CONTAINER_APP" \
    --resource-group "$ACA_RESOURCE_GROUP" \
    --revision-weight "${revision_name}=100" \
    >/dev/null
  echo "100% traffic directed to ${revision_name}"
else
  az containerapp revision set-weight \
    --name "$ACA_CONTAINER_APP" \
    --resource-group "$ACA_RESOURCE_GROUP" \
    --revision-weight "${revision_name}=${target_weight}" \
    --revision-weight "${base_revision}=${base_weight}" \
    >/dev/null
  echo "${target_weight}% → ${revision_name}, ${base_weight}% → ${base_revision}"
fi
