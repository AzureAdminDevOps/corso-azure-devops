# UD13 — LAB guidato
## Terraform operativo e prima pipeline IaC

UD13 è compressa in circa **300 minuti effettivi** perché nella stessa giornata deve iniziare UD14.

Per questo evitiamo ripetizioni già coperte in UD12 e lavoriamo su un unico filo:

```text
Terraform
→ pipeline
→ service connection
→ ACR persistente
→ passaggio a CI
```


Questa sarà la **prima pipeline reale del percorso**.

La eseguiremo intenzionalmente sul self-hosted Agent:

```text
pool-ud09-wsl
```

per vedere concretamente che i comandi della pipeline vengono eseguiti sul WSL2 preparato nelle UD precedenti.

Il Microsoft-hosted non viene ancora usato operativamente in UD13: lo confronteremo e lo utilizzeremo nella CI di UD14 se disponibile.

---

# 0. Preparare la consegna

Da WSL2:

```bash
export COURSE_UD13="$HOME/workspace/corso-azure-devops/UD13/partecipanti"
export LAB_REPO="$HOME/workspace/azure-devops-lab"
export LAB_SUBMISSION="$LAB_REPO/consegne/UD13"
```

```bash
mkdir -p "$LAB_SUBMISSION"
```

Copiare i modelli:

```bash
cp -n "$COURSE_UD13/modelli/00_DOMANDE_CONCETTI.md" \
      "$LAB_SUBMISSION/00_DOMANDE_CONCETTI.md"

cp -n "$COURSE_UD13/modelli/01_LAB_GUIDATO.md" \
      "$LAB_SUBMISSION/01_LAB_GUIDATO.md"

cp -n "$COURSE_UD13/modelli/02_LAB_AUTONOMO.md" \
      "$LAB_SUBMISSION/02_LAB_AUTONOMO.md"

cp -n "$COURSE_UD13/modelli/03_VERIFICA.md" \
      "$LAB_SUBMISSION/03_VERIFICA.md"
```

Verificare:

```bash
find "$LAB_SUBMISSION" -maxdepth 1 -type f -printf '%f\n' | sort
```

---

## Prima pipeline: traduzione laboratorio → produzione

Quando nei log vedremo:

```text
Agent.Name
Agent.OS
Build.SourcesDirectory
```

nel corso riconosceremo il nostro WSL2.

In un team reale gli stessi campi identificherebbero uno dei build host condivisi del Pool:

```text
pool-linux-build
→ build-agent-02
```

La pipeline deve funzionare su **qualsiasi Agent compatibile del Pool**, non dipendere dalla home di uno specifico sviluppatore.


# 1. Verificare che UD12 sia realmente pronta

```bash
cd "$LAB_REPO"
```

```bash
test -f infra/terraform/main.tf && echo "Terraform UD12 presente"
test -f infra/bicep/main.bicep && echo "Bicep UD12 presente"
terraform version
az bicep version
```

Verificare anche i tool che la prima pipeline dovrà realmente eseguire:

```bash
terraform version
az version
az bicep version
git --version
```

Poi verificare l'Agent dal Portale Azure DevOps:

```text
Project settings
→ Agent pools
→ pool-ud09-wsl
→ Agents
```

Deve risultare:

```text
Online
```

Se è `Offline`, avviare in un terminale WSL2 dedicato:

```bash
cd "$HOME/azdo-agent"
./run.sh
```

Atteso:

```text
Listening for Jobs
```

Usare un secondo terminale per il resto del LAB.

Non rieseguire `config.sh` e non creare un nuovo PAT: l'Agent è già registrato.

Annotare inoltre lo stato Microsoft-hosted proveniente da UD12:

```text
READY
PENDING
REQUEST SUBMITTED
BILLING NOT ELIGIBLE
```

Questo stato **non blocca UD13**.

---

# 2. Estendere Terraform con rete e dipendenze

Torniamo nel repository:

```bash
cd "$LAB_REPO"
```

Copiamo il file della rete:

```bash
cp -n "$COURSE_UD13/infra/terraform/network.tf" \
      "$LAB_REPO/infra/terraform/network.tf"
```

Leggere `network.tf`.

La relazione è:

```text
Resource Group
   ↓
VNet
   ↓
Subnet
```

Terraform ricava la dipendenza dai riferimenti.

---

# 3. Preparare il contesto Terraform

```bash
cd "$LAB_REPO/infra/terraform"
```

```bash
az account show \
  --query "{Subscription:name,User:user.name}" \
  --output table
```

```bash
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
```

Il nome Storage di UD12 non esiste più perché il destroy è stato eseguito.

Creiamo quindi un nuovo valore valido:

```bash
export TF_VAR_storage_account_name="stud13$(date +%s | tail -c 10)"
```

---

# 4. Plan della configurazione estesa

```bash
terraform init
terraform fmt
terraform validate
```

Poi:

```bash
terraform plan -out=ud13.tfplan
```

Il piano deve comprendere:

```text
Resource Group
Storage Account
VNet
Subnet
```

Leggere il riepilogo prima di procedere.

---

# 5. Apply e verifica essenziale

```bash
terraform apply ud13.tfplan
```

Verificare:

```bash
az network vnet show \
  --resource-group rg-ud12-tf \
  --name vnet-ud13 \
  --query "{Name:name,Address:addressSpace.addressPrefixes}" \
  --output jsonc
```

Poi:

```bash
az network vnet subnet show \
--resource-group rg-ud12-tf \
--vnet-name vnet-ud13 \
--name snet-app \
--query "{Name:name,Prefix:addressPrefixes[0]}" \
--output table
```

---

# 6. Distruggere l'infrastruttura Terraform temporanea

Queste risorse non servono a UD14 o UD15.

Prima:

```bash
terraform plan -destroy
```

Controllare che il piano riguardi soltanto le risorse Terraform del laboratorio.

Poi:

```bash
terraform destroy
```

Confermare solo dopo aver letto il piano.

Verificare:

```bash
az group exists --name rg-ud12-tf
```

Atteso:

```text
false
```

Il codice Terraform rimane nel repository.

---

# 7. Preparare l'ambiente Azure che dovrà sopravvivere fino a UD15

Da questo punto introduciamo una risorsa **persistente per le ultime tre UD**.

```bash
export DELIVERY_RG="rg-ud13-15-delivery"
export DELIVERY_LOCATION="westeurope"
```

Creare il Resource Group:

```bash
az group create \
  --name "$DELIVERY_RG" \
  --location "$DELIVERY_LOCATION" \
  --tags Course=AZ104 Purpose=FinalDelivery \
  --output table
```

Questo Resource Group **non deve essere eliminato** al termine di UD13.

---

# 8. Creare la Azure Resource Manager service connection

Prima di entrare in Azure DevOps, ricordiamo un prerequisito del percorso automatico scelto.

La creazione automatica di una App Registration WIF richiede normalmente che l'account abbia privilegi adeguati sulla sottoscrizione; nel nostro scenario personale il controllo da effettuare è che l'account disponga del ruolo **Owner** richiesto dal flusso automatico.

Dal Portale Azure:

```text
Subscriptions
→ sottoscrizione del corso
→ Access control (IAM)
→ View my access
```

Verificare il proprio accesso.

Poi aprire Azure DevOps:

```text
Project settings
→ Service connections
→ New service connection
→ Azure Resource Manager
```

Selezionare:

```text
App registration (automatic)
Credential:
Workload identity federation
```

Scope:

```text
Subscription:
la subscription del corso

Resource group:
rg-ud13-15-delivery
```

Nome:

```text
sc-azure-ud13-15
```

Non selezionare:

```text
Grant access permission to all pipelines
```

Salvare.

La service connection è deliberatamente limitata al Resource Group finale.

## Se la creazione automatica non è autorizzata

Non creare client secret improvvisati, non usare un PAT come credenziale Azure e non allargare privilegi a tentativi.

Annotare:

```text
BLOCKED_BY_SERVICE_CONNECTION
```

Il partecipante può comunque completare:

```text
codice IaC
YAML
validazione Terraform
lint Bicep
```

La fase `Deploy` della pipeline richiede però una service connection WIF valida.

Per **non rompere la continuità verso UD14**, se il blocco dipende realmente da autorizzazioni esterne e non può essere risolto, dopo aver preparato `delivery.bicep` eseguire localmente:

```bash
az bicep lint \
  --file "$LAB_REPO/infra/bicep/delivery.bicep"

az deployment group what-if \
  --resource-group "$DELIVERY_RG" \
  --template-file "$LAB_REPO/infra/bicep/delivery.bicep" \
  --parameters location="$DELIVERY_LOCATION"

az deployment group create \
  --name "ud13-delivery-fallback" \
  --resource-group "$DELIVERY_RG" \
  --template-file "$LAB_REPO/infra/bicep/delivery.bicep" \
  --parameters location="$DELIVERY_LOCATION" \
  --output table
```

Questo fallback mantiene disponibile l'ACR necessario a UD14, ma **non va presentato come equivalente a una pipeline riuscita**.

Nella consegna scrivere:

```text
Pipeline Deploy: BLOCKED_BY_SERVICE_CONNECTION
ACR continuity: created by local fallback
```

---

# 9. Preparare il Bicep della delivery

Copiare:

```bash
cp "$COURSE_UD13/infra/bicep/delivery.bicep" \
   "$LAB_REPO/infra/bicep/delivery.bicep"
```

Leggere il file.

Il nome ACR viene generato con:

```bicep
uniqueString(resourceGroup().id)
```

Questo evita di inserire nel YAML un nome globale scelto manualmente.

Il registry usa:

```text
SKU Basic
admin user disabilitato
```

---

# 10. Preparare il file pipeline

Creare una directory logica se non esiste:

```bash
mkdir -p "$LAB_REPO/pipelines"
```

Copiare:

```bash
cp "$COURSE_UD13/pipeline/azure-pipelines-iac.yml" \
   "$LAB_REPO/pipelines/azure-pipelines-iac.yml"
```

Leggere il file prima del commit.

Individuare:

```text
trigger
pool
variables
stage Validate
stage Deploy
job
workspace clean
checkout
Agent.Name / Agent.OS
Terraform
Bicep
AzureCLI@2
service connection
```

Osservare in particolare:

```yaml
workspace:
  clean: all
```

Questa impostazione è importante proprio perché il self-hosted Agent conserva normalmente il proprio filesystem.

Poi osservare:

```yaml
pool:
  name: pool-ud09-wsl
```

e confrontarlo **senza modificarlo oggi** con:

```yaml
pool:
  vmImage: ubuntu-latest
```

Il secondo sarebbe il modello Microsoft-hosted che useremo successivamente.

---

# 11. Versionare i file

```bash
cd "$LAB_REPO"
git status
```

Aggiungere:

```bash
git add \
  infra/terraform/network.tf \
  infra/bicep/delivery.bicep \
  pipelines/azure-pipelines-iac.yml
```

Controllare:

```bash
git diff --cached
```

Commit:

```bash
git commit -m "feat: add IaC validation pipeline baseline"
git push
```

---

# 12. Creare la prima pipeline Azure DevOps e autorizzare GitHub

Questa è la prima volta nel percorso in cui Azure Pipelines deve effettuare realmente il checkout del repository GitHub.

Da Azure DevOps:

```text
Pipelines
→ New pipeline
→ GitHub
```

## Se viene richiesta l'autorizzazione GitHub

Usare la **Azure Pipelines GitHub App**.

È il metodo che abbiamo preparato concettualmente in UD09 e che Microsoft raccomanda per le pipeline CI GitHub.

Se GitHub chiede a quali repository concedere accesso, limitare l'accesso al repository personale del corso quando l'interfaccia lo consente.

Non creare per questa procedura:

```text
GitHub PAT manuale
OAuth personale manuale
secondo repository in Azure Repos
```

Dopo l'autorizzazione selezionare:

```text
repository personale
→ Existing Azure Pipelines YAML file
```

Percorso:

```text
/pipelines/azure-pipelines-iac.yml
```

Salvare.

La pipeline usa:

```text
trigger: none
```

quindi l'esecuzione resta manuale.

A questo punto abbiamo due connessioni con scopi diversi:

```text
GitHub App
→ Azure Pipelines legge il repository

sc-azure-ud13-15
→ AzureCLI@2 opera sul Resource Group Azure
```

Non confonderle.

---

# 13. Prima esecuzione

Avviare:

```text
Run pipeline
```

Alla prima esecuzione Azure DevOps può chiedere di autorizzare:

```text
sc-azure-ud13-15
```

Autorizzare **questa pipeline**, non tutte indiscriminatamente.

Seguire i log.

Stage `Validate` deve mostrare prima:

```text
Agent.Name
Agent.OS
Build.SourcesDirectory
terraform version
az version
az bicep version
```

e poi:

```text
terraform fmt -check
terraform init -backend=false
terraform validate
az bicep lint
```

Questo è il momento in cui verifichiamo concretamente che il Job stia usando il self-hosted Agent e non il terminale interattivo del partecipante.

Stage `Deploy` deve eseguire:

```text
Bicep What-If
Bicep deployment
```

Notare che `ValidateIaC` e `DeployIaC` sono due Job distinti.

Non devono passarsi file locali "per caso": entrambi fanno un proprio checkout pulito.

Questa disciplina rende la pipeline più portabile anche verso un ambiente Microsoft-hosted.

---

# 14. Verificare ACR senza affidarsi soltanto al verde della pipeline

Da WSL2:

```bash
az acr list \
  --resource-group "$DELIVERY_RG" \
  --query "[].{Name:name,SKU:sku.name,Admin:adminUserEnabled}" \
  --output table
```

Atteso:

```text
SKU = Basic
Admin = false
```

Verificare anche la modalità di autorizzazione:

```bash
ACR_NAME=$(az acr list \
  --resource-group "$DELIVERY_RG" \
  --query "[0].name" \
  --output tsv)

az acr show \
  --name "$ACR_NAME" \
  --resource-group "$DELIVERY_RG" \
  --query roleAssignmentMode \
  --output tsv
```

Per questa catena deve risultare il modello equivalente a:

```text
LegacyRegistryPermissions
```

Recuperare il login server:

```bash
az acr list \
  --resource-group "$DELIVERY_RG" \
  --query "[0].loginServer" \
  --output tsv
```

Registrare nome e login server nella consegna.

---

# 15. Non fare cleanup

A questo punto UD13 ha raggiunto il suo obiettivo.

**Non eliminare**:

```text
rg-ud13-15-delivery
ACR
sc-azure-ud13-15
pipeline IaC
agent
```

Serviranno tra pochi minuti in UD14.
