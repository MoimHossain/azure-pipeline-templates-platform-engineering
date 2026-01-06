#!/usr/bin/env bash


echo "[Quadrant] Ensuring revision ${revision_name} exists for ${PRODUCT_NAME}"

existing_revision=$(az containerapp revision list --name "$ACA_CONTAINER_APP" --resource-group "$ACA_RESOURCE_GROUP" --query "[?name=='${revision_name}'].name | [0]" -o tsv)

if [[ -z "$existing_revision" ]]; then
  echo "Creating new revision ${revision_name} with image $ACA_IMAGE_NAME"
  az containerapp update --name "$ACA_CONTAINER_APP" --resource-group "$ACA_RESOURCE_GROUP" --image "$ACA_IMAGE_NAME" --revision-suffix "$ACA_REVISION_SUFFIX" >/dev/null
else
  echo "Revision ${revision_name} already exists; skipping image update"
fi

for attempt in {1..12}; do
  state=$(az containerapp revision show --name "$ACA_CONTAINER_APP" --resource-group "$ACA_RESOURCE_GROUP" --revision "$revision_name" --query "properties.provisioningState" -o tsv 2>/dev/null || true)
  if [[ "$state" == "Succeeded" ]]; then
    echo "Revision ${revision_name} is ready"
    break
  fi
  echo "Waiting for revision ${revision_name} to finish provisioning (state: ${state:-Unknown})"
  sleep 5
done

fqdn=$(az containerapp revision show --name "$ACA_CONTAINER_APP" --resource-group "$ACA_RESOURCE_GROUP" --revision "$revision_name" --query "properties.fqdn" -o tsv)

echo "New revision FQDN: ${fqdn}"