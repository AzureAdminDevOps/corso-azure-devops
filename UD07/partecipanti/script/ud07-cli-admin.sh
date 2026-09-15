#!/usr/bin/env bash

RG="rg-ud07-cli-test"
LOCATION="westeurope"

EXISTS=$(az group exists --name "$RG")

if [ "$EXISTS" = "false" ]; then
  echo "Il Resource Group non esiste: lo creo."
  az group create \
    --name "$RG" \
    --location "$LOCATION" \
    --tags ManagedBy=CLI UD=07 \
    --output table
else
  echo "Il Resource Group esiste già: lo riutilizzo."
fi

echo
echo "Aggiorno i tag..."
az group update \
  --name "$RG" \
  --set tags.ManagedBy=CLI tags.UD=07 tags.State=Verified \
  --output none

echo
echo "Stato finale:"
az group show \
  --name "$RG" \
  --query "{Name:name,Location:location,State:properties.provisioningState,Tags:tags}" \
  --output table
