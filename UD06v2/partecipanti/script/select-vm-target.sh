#!/usr/bin/env bash
set -euo pipefail

# UD06 - selezione autonoma di regione e size VM.
#
# Output su stdout:
#   <REGION> <VM_SIZE>
#
# I messaggi informativi vengono inviati su stderr, così la shell chiamante
# può acquisire in modo sicuro i due valori con:
#
#   read -r LAB_LOCATION LAB_VM_SIZE < <(
#     ./partecipanti/script/select-vm-target.sh
#   )

if ! command -v az >/dev/null 2>&1; then
  echo "ERRORE: Azure CLI (az) non è disponibile in questa shell." >&2
  exit 10
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERRORE: python3 non è disponibile in questa shell WSL2." >&2
  exit 11
fi

if ! az account show >/dev/null 2>&1; then
  echo "ERRORE: nessuna sessione Azure CLI attiva. Eseguire prima: az login" >&2
  exit 12
fi

REGIONS=(
  westeurope
  northeurope
  francecentral
  germanywestcentral
)

# Ordine volutamente conservativo: entrambe sono piccole B-series.
# Non viene selezionata automaticamente una size più grande/costosa.
SIZES=(
  Standard_B1s
  Standard_B1ms
)

for SIZE in "${SIZES[@]}"; do
  for REGION in "${REGIONS[@]}"; do
    echo "Verifico $SIZE in $REGION..." >&2

    if az vm list-skus \
        --location "$REGION" \
        --size "$SIZE" \
        --all \
        --output json \
      | SIZE_TO_CHECK="$SIZE" python3 -c '
import json
import os
import sys

expected = os.environ["SIZE_TO_CHECK"]
skus = json.load(sys.stdin)

available = any(
    sku.get("name") == expected
    and not sku.get("restrictions")
    for sku in skus
)

sys.exit(0 if available else 1)
'; then
      printf '%s %s\n' "$REGION" "$SIZE"
      exit 0
    fi
  done
done

echo "ERRORE: nessuna combinazione prevista regione/size è disponibile senza restrizioni." >&2
echo "Sono state verificate, nell'ordine:" >&2
echo "  size: Standard_B1s, Standard_B1ms" >&2
echo "  regioni: westeurope, northeurope, francecentral, germanywestcentral" >&2
echo "Non scegliere automaticamente una VM più grande. Interrompere la creazione della VM." >&2
exit 20
