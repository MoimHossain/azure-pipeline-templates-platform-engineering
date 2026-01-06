#!/usr/bin/env bash
set -euo pipefail

az containerapp revision set-mode --name "$ACA_CONTAINER_APP" --resource-group "$ACA_RESOURCE_GROUP" --mode multiple >/dev/null

echo "Revision mode set to 'multiple' for $ACA_CONTAINER_APP"
