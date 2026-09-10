# Laboratorio guidato — Dall'account al Blob protetto

## 1. Verifica strumenti e repository

```bash
cd ~/workspace/azure-devops-lab
git pull --ff-only
mkdir -p consegne/UD04
ls -1 consegne/UD04/*.md
az version --output table
az account show --query "{Subscription:name,State:state}" --output table
```

Se Azure CLI manca o non è autenticata, usa le procedure di recupero di UD01. Non reinstallare uno strumento già presente e compatibile.

## 2. Prepara nomi e file innocui

```bash
LAB_SUFFIX="$(openssl rand -hex 4)"
LAB_RG="rg-cea-storage-${LAB_SUFFIX}"
LAB_STORAGE="stcea${LAB_SUFFIX}"
LAB_CONTAINER="documents"
LAB_LOCATION="italynorth"
LAB_DELETE_AFTER="$(date -u -d '+1 day' +%F)"

printf 'Documento didattico UD04 - nessun dato personale\n' > consegne/UD04/01_DOCUMENTO_LAB.txt
az storage account check-name --name "$LAB_STORAGE" --output table
```

Se il nome non è disponibile, rigenera solo il suffisso e ripeti. Il file non deve contenere informazioni personali o riservate.

## 3. Crea account e resource group da CLI

Resource group e storage account sono già stati creati una prima volta dal portale in UD02; ora trasformiamo quelle scelte in una procedura ripetibile:

```bash
az group create \
  --name "$LAB_RG" \
  --location "$LAB_LOCATION" \
  --tags course=cloud-engineer-academy unit=UD04 environment=lab deleteAfter="$LAB_DELETE_AFTER" \
  --output table

az storage account create \
  --resource-group "$LAB_RG" \
  --name "$LAB_STORAGE" \
  --location "$LAB_LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --tags course=cloud-engineer-academy unit=UD04 environment=lab deleteAfter="$LAB_DELETE_AFTER" \
  --output table
```

Verifica proprietà e endpoint senza leggere chiavi:

```bash
az storage account show \
  --resource-group "$LAB_RG" \
  --name "$LAB_STORAGE" \
  --query "{Sku:sku.name,Kind:kind,Https:enableHttpsTrafficOnly,Tls:minimumTlsVersion,PublicBlob:allowBlobPublicAccess,BlobEndpoint:primaryEndpoints.blob}" \
  --output jsonc
```

⏱

## 4. Crea il primo container e carica il primo Blob dal portale

Nel portale apri lo storage account, quindi **Data storage → Containers → + Container**. Crea `documents` con livello di accesso **Private (no anonymous access)**. Un container organizza Blob e può costituire uno scope di autorizzazione; non è una cartella del filesystem.

Apri il container, seleziona **Upload**, scegli `consegne/UD04/01_DOCUMENTO_LAB.txt` e mantieni il tier Hot. Prima di confermare verifica che il file non contenga dati riservati.

Se il portale chiede se usare account key o identità Microsoft Entra, scegli Microsoft Entra quando il ruolo dati è già disponibile. Se ricevi un errore dati, prosegui con la sezione successiva: la creazione del container può essere stata autorizzata tramite account key dal portale, mentre l'accesso Entra richiede un ruolo specifico.

⏱

## 5. Assegna il ruolo dati con scope minimo

Apri **Access control (IAM)** dello storage account e assegna al tuo account **Storage Blob Data Contributor**. La role assignment è già stata introdotta in UD03; qui cambia la role definition perché deve autorizzare il piano dati. Lo scope dell'account è sufficiente al laboratorio e non estende il ruolo all'intera sottoscrizione.

Attendi la propagazione e verifica:

```bash
az storage container list \
  --account-name "$LAB_STORAGE" \
  --auth-mode login \
  --query "[].{Container:name,PublicAccess:properties.publicAccess}" \
  --output table

az storage blob list \
  --account-name "$LAB_STORAGE" \
  --container-name "$LAB_CONTAINER" \
  --auth-mode login \
  --query "[].{Blob:name,Tier:properties.blobTier,Bytes:properties.contentLength}" \
  --output table
```

Le assegnazioni dati possono richiedere tempo per propagarsi. Se compare `AuthorizationPermissionMismatch`, controlla account, ruolo, scope e principal; ripeti dopo alcuni minuti senza assegnare ruoli più ampi.

## 6. Esegui operazioni successive da CLI

```bash
printf 'File temporaneo per lifecycle\n' > /tmp/ud04-temporaneo.txt

az storage blob upload \
  --account-name "$LAB_STORAGE" \
  --container-name "$LAB_CONTAINER" \
  --name temporary/temporaneo.txt \
  --file /tmp/ud04-temporaneo.txt \
  --auth-mode login \
  --overwrite \
  --output table

az storage blob download \
  --account-name "$LAB_STORAGE" \
  --container-name "$LAB_CONTAINER" \
  --name documento-lab.txt \
  --file /tmp/documento-lab-scaricato.txt \
  --auth-mode login \
  --overwrite \
  --output table

cmp consegne/UD04/01_DOCUMENTO_LAB.txt /tmp/documento-lab-scaricato.txt
```

`cmp` senza output e con codice zero dimostra che il file scaricato coincide con l'originale.

## 7. Confronta Shared Key senza esporla

Recupera temporaneamente una chiave in una variabile, usala per una sola lettura e rimuovila dalla memoria:

```bash
AZURE_STORAGE_KEY="$(az storage account keys list \
  --resource-group "$LAB_RG" \
  --account-name "$LAB_STORAGE" \
  --query '[0].value' \
  --output tsv)"
export AZURE_STORAGE_KEY

az storage blob list \
  --account-name "$LAB_STORAGE" \
  --container-name "$LAB_CONTAINER" \
  --auth-mode key \
  --query "[].name" \
  --output table

unset AZURE_STORAGE_KEY
```

Non usare `echo`, non attivare tracing della shell e non copiare la variabile. La chiave concede accesso ampio e non identifica individualmente l'operatore; il confronto serve a comprendere perché Entra ID è preferibile.

## 8. Genera e usa una user delegation SAS

```bash
SAS_EXPIRY="$(date -u -d '+30 minutes' +%Y-%m-%dT%H:%MZ)"
SAS_URL="$(az storage blob generate-sas \
  --account-name "$LAB_STORAGE" \
  --container-name "$LAB_CONTAINER" \
  --name documento-lab.txt \
  --permissions r \
  --expiry "$SAS_EXPIRY" \
  --auth-mode login \
  --as-user \
  --full-uri \
  --output tsv)"

curl --fail --silent --show-error "$SAS_URL" --output /tmp/documento-sas.txt
cmp consegne/UD04/01_DOCUMENTO_LAB.txt /tmp/documento-sas.txt
unset SAS_URL
```

La SAS consente solo lettura del singolo Blob e scade dopo 30 minuti. Non inserirla in evidenze, file o cronologia aggiuntiva. Registra soltanto permesso, scope, durata ed esito.

## 9. Crea la prima regola lifecycle dal portale

Apri **Data management → Lifecycle management → Add a rule**. Crea `delete-temporary` abilitata, applicabile ai block blob con prefisso `documents/temporary/`, e configura l'eliminazione dopo un giorno dall'ultima modifica.

Il prefisso comprende container e percorso. Un filtro errato potrebbe coinvolgere dati non previsti. La policy non si esegue immediatamente; il laboratorio verifica la configurazione, non attende l'eliminazione.

```bash
az storage account management-policy show \
  --account-name "$LAB_STORAGE" \
  --resource-group "$LAB_RG" \
  --query "policy.rules[].{Name:name,Enabled:enabled,Prefixes:definition.filters.prefixMatch,DeleteAfter:definition.actions.baseBlob.delete.daysAfterModificationGreaterThan}" \
  --output jsonc
```

⏱

## 10. Cleanup finale

Esegui questa sezione dopo laboratorio autonomo e verifica. Rimuovi dal portale la role assignment **Storage Blob Data Contributor** creata per il laboratorio. Eventuali SAS scadranno, ma nessun token deve rimanere nei file.

```bash
rm -f /tmp/documento-lab-scaricato.txt /tmp/documento-sas.txt
unset AZURE_STORAGE_KEY SAS_URL
az group delete --name "$LAB_RG" --yes --no-wait
az group wait --name "$LAB_RG" --deleted
az group exists --name "$LAB_RG"
```

L'ultimo comando deve restituire `false`. Completa le consegne e registra soltanto i file previsti:

```bash
git status --short
git add consegne/UD04/00_DOMANDE_CONCETTI.md \
        consegne/UD04/01_LAB_GUIDATO.md \
        consegne/UD04/01_DOCUMENTO_LAB.txt \
        consegne/UD04/02_LAB_AUTONOMO.md \
        consegne/UD04/03_VERIFICA.md
git commit -m "Completa laboratorio Azure Storage"
git push
```

⏱
