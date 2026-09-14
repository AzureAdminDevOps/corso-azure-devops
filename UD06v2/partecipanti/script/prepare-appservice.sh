#!/usr/bin/env bash
set -euo pipefail

# UD06 - prepara App Service Free F1 in modo autonomo.
#
# Prerequisiti nella shell chiamante:
#   LAB_RG
#   LAB_LOCATION
#
# Output stdout, una sola riga:
#   <APP_SERVICE_LIVE> <WEB_RUNTIME> <WEB_PLAN> <WEB_APP>
#
# Tutti i messaggi informativi vanno su stderr.

: "${LAB_RG:?ERRORE: LAB_RG non definita nella shell chiamante.}"
: "${LAB_LOCATION:?ERRORE: LAB_LOCATION non definita nella shell chiamante.}"

if ! command -v az >/dev/null 2>&1; then
  echo "ERRORE: Azure CLI non disponibile." >&2
  exit 10
fi

if ! az account show >/dev/null 2>&1; then
  echo "ERRORE: sessione Azure CLI non attiva. Eseguire az login." >&2
  exit 11
fi

echo "Cerco un runtime Linux PHP disponibile..." >&2
WEB_RUNTIME="$(
  az webapp list-runtimes --os linux --output tsv \
    | grep '^PHP:' \
    | head -n 1 \
    || true
)"

if [[ -z "$WEB_RUNTIME" ]]; then
  echo "PHP non trovato; cerco un runtime Linux Node.js..." >&2
  WEB_RUNTIME="$(
    az webapp list-runtimes --os linux --output tsv \
      | grep '^NODE:' \
      | head -n 1 \
      || true
  )"
fi

if [[ -z "$WEB_RUNTIME" ]]; then
  echo "Nessun runtime PHP/Node.js Linux disponibile dalla CLI corrente." >&2
  printf 'no NONE NONE NONE\n'
  exit 0
fi

WEB_PLAN="plan-ud06-${RANDOM}"
WEB_APP="ud06-web-$(date +%s)-${RANDOM}"

echo "Runtime selezionato: $WEB_RUNTIME" >&2
echo "Tento App Service Plan Free F1 in $LAB_LOCATION..." >&2

if ! az appservice plan create \
    --resource-group "$LAB_RG" \
    --name "$WEB_PLAN" \
    --location "$LAB_LOCATION" \
    --sku F1 \
    --is-linux \
    --output none; then
  echo "F1 non disponibile o creazione non consentita. Nessun tier a pagamento verrà creato." >&2
  printf 'no %s %s %s\n' "$WEB_RUNTIME" "$WEB_PLAN" "$WEB_APP"
  exit 0
fi

echo "Creo Web App..." >&2

if ! az webapp create \
    --resource-group "$LAB_RG" \
    --plan "$WEB_PLAN" \
    --name "$WEB_APP" \
    --runtime "$WEB_RUNTIME" \
    --output none; then
  echo "Creazione Web App non riuscita. Il laboratorio App Service proseguirà in modalità di analisi." >&2
  printf 'no %s %s %s\n' "$WEB_RUNTIME" "$WEB_PLAN" "$WEB_APP"
  exit 0
fi

printf 'yes %s %s %s\n' "$WEB_RUNTIME" "$WEB_PLAN" "$WEB_APP"
