# UD15 — Controlli iniziali
## Preparare ambiente, autorizzazioni e Terraform state

Questi controlli vengono completati prima di aprire `02_LAB_GUIDATO.md`.

La UD14 non viene modificata.

Se `sc-acr-ud14` esiste, lasciarla invariata.

---

# 1. Definire i riferimenti

Da WSL2:

```bash
export COURSE_UD15="$HOME/workspace/corso-azure-devops/UD15/partecipanti"
export LAB_REPO="$HOME/workspace/azure-devops-lab"
export DELIVERY_RG="rg-ud13-15-delivery"
export IDENTITY_NAME="id-ud15-acrpull"
export TFSTATE_CONTAINER="tfstate"
export TFSTATE_KEY="ud15.tfstate"
```

Recuperare la sottoscrizione:

```bash
export ARM_SUBSCRIPTION_ID=$(az account show   --query id   --output tsv)
```

Generare il nome deterministico dello Storage Account:

```bash
export TFSTATE_STORAGE="sttf15$(echo "$ARM_SUBSCRIPTION_ID"   | tr -d '-'   | cut -c1-16)"
```

Verificare:

```bash
echo "$DELIVERY_RG"
echo "$TFSTATE_STORAGE"
```

---

# 2. Verificare Resource Group e ACR

```bash
az group exists   --name "$DELIVERY_RG"
```

Atteso:

```text
true
```

Recuperare ACR:

```bash
export ACR_NAME=$(az acr list   --resource-group "$DELIVERY_RG"   --query "[0].name"   --output tsv)
```

Recuperare località e ID:

```bash
export ACR_LOCATION=$(az acr show   --name "$ACR_NAME"   --resource-group "$DELIVERY_RG"   --query location   --output tsv)

export ACR_ID=$(az acr show   --name "$ACR_NAME"   --resource-group "$DELIVERY_RG"   --query id   --output tsv)
```

Verificare:

```bash
az acr show   --name "$ACR_NAME"   --resource-group "$DELIVERY_RG"   --query "{Name:name,Location:location,Admin:adminUserEnabled,RoleAssignmentMode:roleAssignmentMode}"   --output table
```

Atteso:

```text
Admin = false
RoleAssignmentMode = LegacyRegistryPermissions
```

---

# 3. Verificare `sc-azure-ud13-15`

In Azure DevOps:

```text
Project settings
→ Service connections
→ sc-azure-ud13-15
```

La connessione deve esistere ed essere abilitata.

Verificare inoltre che il metodo di autenticazione indicato per la connessione sia:

```text
Workload Identity Federation
```

Non creare una nuova Docker Registry service connection.

Se `sc-acr-ud14` è presente, non modificarla.

---

# 4. Assegnare `AcrPush` all'identità della pipeline

Aprire:

```text
Project settings
→ Service connections
→ sc-azure-ud13-15
```

Aprire il collegamento al Service Principal associato e annotarne il nome.

Nel Portale Azure aprire:

```text
Azure Container Registry
→ ACR del corso
→ Access control (IAM)
→ Add
→ Add role assignment
```

Selezionare:

```text
Role: AcrPush
Assign access to: User, group, or service principal
Member: Service Principal associato a sc-azure-ud13-15
```

Completare l'assegnazione.

Verificare:

```bash
az role assignment list   --scope "$ACR_ID"   --role AcrPush   --query "[].{Principal:principalName,Role:roleDefinitionName}"   --output table
```

Deve comparire l'identità della pipeline.

---

# 5. Preparare lo Storage Account per lo state Terraform

Verificare se esiste:

```bash
az storage account show   --name "$TFSTATE_STORAGE"   --resource-group "$DELIVERY_RG"   --output none
```

Se il comando restituisce che la risorsa non esiste, crearla:

```bash
az storage account create   --name "$TFSTATE_STORAGE"   --resource-group "$DELIVERY_RG"   --location "$ACR_LOCATION"   --sku Standard_LRS   --kind StorageV2   --allow-blob-public-access false   --min-tls-version TLS1_2   --output none
```

Creare il container dello state tramite il Resource Provider Azure:

```bash
az storage container-rm create   --storage-account "$TFSTATE_STORAGE"   --resource-group "$DELIVERY_RG"   --name "$TFSTATE_CONTAINER"   --public-access off   --output none
```

Recuperare l'ID dello Storage Account:

```bash
export TFSTATE_STORAGE_ID=$(az storage account show   --name "$TFSTATE_STORAGE"   --resource-group "$DELIVERY_RG"   --query id   --output tsv)
```

---

# 6. Autorizzare la pipeline allo state remoto

Definire lo scope del container che ospiterà lo state:

```bash
export TFSTATE_CONTAINER_SCOPE="$TFSTATE_STORAGE_ID/blobServices/default/containers/$TFSTATE_CONTAINER"
```

Nel Portale Azure aprire:

```text
Storage Account
→ Containers
→ tfstate
→ Access control (IAM)
→ Add
→ Add role assignment
```

Selezionare:

```text
Role: Storage Blob Data Contributor
Assign access to: User, group, or service principal
Member: Service Principal associato a sc-azure-ud13-15
```

Completare l'assegnazione.

Verificare:

```bash
az role assignment list   --scope "$TFSTATE_CONTAINER_SCOPE"   --role "Storage Blob Data Contributor"   --query "[].{Principal:principalName,Role:roleDefinitionName}"   --output table
```

La pipeline userà questa autorizzazione per leggere, scrivere e bloccare lo state Terraform senza ricevere accesso dati agli altri container dello Storage Account.

---

# 7. Preparare la managed identity della Container App

Verificare se l'identità esiste:

```bash
az identity show   --name "$IDENTITY_NAME"   --resource-group "$DELIVERY_RG"   --output none
```

Se non esiste, crearla:

```bash
az identity create   --name "$IDENTITY_NAME"   --resource-group "$DELIVERY_RG"   --location "$ACR_LOCATION"   --output none
```

Recuperare principal ID e resource ID:

```bash
export IDENTITY_PRINCIPAL_ID=$(az identity show   --name "$IDENTITY_NAME"   --resource-group "$DELIVERY_RG"   --query principalId   --output tsv)

export IDENTITY_ID=$(az identity show   --name "$IDENTITY_NAME"   --resource-group "$DELIVERY_RG"   --query id   --output tsv)
```

---

# 8. Assegnare `AcrPull` alla managed identity

Verificare prima le assegnazioni esistenti:

```bash
az role assignment list   --assignee-object-id "$IDENTITY_PRINCIPAL_ID"   --scope "$ACR_ID"   --query "[].roleDefinitionName"   --output table
```

Se `AcrPull` non compare, eseguire:

```bash
az role assignment create   --assignee-object-id "$IDENTITY_PRINCIPAL_ID"   --assignee-principal-type ServicePrincipal   --role AcrPull   --scope "$ACR_ID"   --output table
```

Verificare nuovamente:

```bash
az role assignment list   --assignee-object-id "$IDENTITY_PRINCIPAL_ID"   --scope "$ACR_ID"   --query "[].{Role:roleDefinitionName,Scope:scope}"   --output table
```

Atteso:

```text
Role = AcrPull
```

---

# 9. Verificare l'Agent e gli strumenti

In Azure DevOps:

```text
Project settings
→ Agent pools
→ pool-ud09-wsl
→ Agents
```

L'Agent deve risultare:

```text
Online
```

Se è `Offline`:

```bash
cd "$HOME/azdo-agent"
./run.sh
```

Nel secondo terminale verificare:

```bash
terraform version
az version
python3 --version
docker --version
docker info >/dev/null
curl --version
```

Tutti i comandi devono terminare senza errore.

---

# 10. Preparare Azure Container Apps

Verificare che i comandi Container Apps siano disponibili:

```bash
az containerapp --help >/dev/null
```

Se il comando non è disponibile nell'Azure CLI installata, aggiungere o aggiornare l'estensione:

```bash
az extension add   --name containerapp   --upgrade
```

Registrare il Resource Provider:

```bash
az provider register   --namespace Microsoft.App
```

Verificare:

```bash
az provider show   --namespace Microsoft.App   --query registrationState   --output tsv
```

Atteso:

```text
Registered
```

Se compare:

```text
Registering
```

attendere e ripetere soltanto il comando di verifica.

---

# 11. Verificare i file provenienti dalla UD14

Nel repository di laboratorio devono esistere:

```text
app/catalog-backend-ci/Dockerfile
app/catalog-backend-ci/server.py
app/catalog-backend-ci/tests/test_backend.py
```

Verificare:

```bash
cd "$LAB_REPO"

test -f app/catalog-backend-ci/Dockerfile   && echo "Dockerfile presente"

test -f app/catalog-backend-ci/server.py   && echo "server.py presente"

test -f app/catalog-backend-ci/tests/test_backend.py   && echo "test_backend.py presente"
```

---

# 12. Stato richiesto prima del laboratorio

Prima di aprire `02_LAB_GUIDATO.md` devono risultare disponibili:

```text
Resource Group rg-ud13-15-delivery
ACR
Admin user ACR = false
LegacyRegistryPermissions
sc-azure-ud13-15
AcrPush per l'identità della pipeline
Storage Account dello state
container tfstate
Storage Blob Data Contributor sul container tfstate per l'identità della pipeline
id-ud15-acrpull
AcrPull per la managed identity
pool-ud09-wsl Online
Terraform
Azure CLI
Python
Docker
curl
Microsoft.App Registered
app/catalog-backend-ci
```

Se un ruolo è stato appena assegnato e una prima operazione restituisce un errore di autorizzazione, verificare che l'assegnazione esista e attendere la propagazione prima di modificare i privilegi.

Quando tutti i controlli sono conclusi, aprire:

```text
02_LAB_GUIDATO.md
```
