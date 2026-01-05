#!/usr/bin/env bash
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
