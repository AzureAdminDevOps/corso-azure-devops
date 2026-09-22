# UD12 — Laboratorio guidato
## Bicep, Terraform e preparazione alle pipeline finali

Questa giornata introduce l'Infrastructure as Code attraverso due strumenti differenti, ma la logica operativa rimane la stessa:

```text
descrivere
→ validare
→ prevedere il cambiamento
→ applicare
→ verificare
→ rimuovere ciò che non serve
```

Le risorse Azure create oggi sono volutamente leggere e temporanee. Il **codice IaC e gli strumenti installati**, invece, devono rimanere disponibili perché saranno riutilizzati nelle UD13–UD15.


La UD resta manuale: **non creeremo ancora una pipeline**.

Alla fine, però, verificheremo due aspetti differenti:

```text
self-hosted
→ il nostro WSL2 deve essere pronto a eseguire i tool

Microsoft-hosted
→ dobbiamo sapere che ogni Job riceverà un ambiente nuovo
   e che i tool andranno verificati nel Job
```

Questa distinzione prepara le pipeline delle UD successive senza anticiparle.

---


## Prima di iniziare: riconosci il percorso che hai appena studiato

Questo laboratorio non introduce un nuovo modello teorico. Applica esattamente il percorso di `00_CONCETTI.md`.

Per Bicep:

```text
leggo main.bicep
→ lint
→ What-If
→ deployment
→ output
→ verifica Azure CLI
```

Per Terraform:

```text
leggo i cinque file .tf
→ init
→ fmt
→ validate
→ plan
→ controllo umano
→ apply
→ output
→ verifica Azure CLI
→ state
```

Se durante il LAB un comando non è chiaro, torna alla sezione concettuale corrispondente prima di proseguire. L'obiettivo non è eseguire una sequenza a memoria, ma sapere **perché** ogni passaggio viene eseguito.

---

# 0. Preparare directory, consegne e repository

Aprire **Ubuntu/WSL2**.

Useremo:

```text
materiali distribuiti
~/workspace/corso-azure-devops/UD12/partecipanti

repository personale
~/workspace/azure-devops-lab
```

Impostiamo i percorsi:

```bash
export COURSE_UD12="$HOME/workspace/corso-azure-devops/UD12/partecipanti"
export LAB_REPO="$HOME/workspace/azure-devops-lab"
export LAB_SUBMISSION="$LAB_REPO/consegne/UD12"
```

Verificare:

```bash
test -d "$COURSE_UD12" && echo "Materiali UD12 trovati"
test -d "$LAB_REPO/.git" && echo "Repository personale trovato"
```

Prepariamo la consegna:

```bash
mkdir -p "$LAB_SUBMISSION"
```

Copiamo i modelli senza sovrascrivere eventuale lavoro già svolto:

```bash
cp -n "$COURSE_UD12/modelli/00_DOMANDE_CONCETTI.md" \
      "$LAB_SUBMISSION/00_DOMANDE_CONCETTI.md"

cp -n "$COURSE_UD12/modelli/01_LAB_GUIDATO.md" \
      "$LAB_SUBMISSION/01_LAB_GUIDATO.md"

cp -n "$COURSE_UD12/modelli/02_LAB_AUTONOMO.md" \
      "$LAB_SUBMISSION/02_LAB_AUTONOMO.md"

cp -n "$COURSE_UD12/modelli/03_VERIFICA.md" \
      "$LAB_SUBMISSION/03_VERIFICA.md"
```

Verificare:

```bash
find "$LAB_SUBMISSION" \
  -maxdepth 1 \
  -type f \
  -printf '%f\n' \
  | sort
```

Ora prepariamo le directory IaC nel repository:

```bash
mkdir -p "$LAB_REPO/infra/bicep"
mkdir -p "$LAB_REPO/infra/terraform"
```

Copiamo i file iniziali:

```bash
cp -n "$COURSE_UD12/infra/bicep/main.bicep" \
      "$LAB_REPO/infra/bicep/main.bicep"

cp -n "$COURSE_UD12/infra/terraform/"*.tf \
      "$LAB_REPO/infra/terraform/"
```

Controllare la struttura:

```bash
find "$LAB_REPO/infra" \
  -maxdepth 2 \
  -type f \
  -printf '%P\n' \
  | sort
```

Atteso:

```text
bicep/main.bicep
terraform/main.tf
terraform/outputs.tf
terraform/providers.tf
terraform/variables.tf
terraform/versions.tf
```

Questi file **non sono temporanei**: saranno riutilizzati nelle giornate finali.

---

# 1. Verificare il contesto Azure

Prima di usare qualsiasi strumento IaC verifichiamo sempre chi siamo e su quale subscription stiamo operando.

```bash
az login
```

Poi:

```bash
az account show \
  --query "{Subscription:name,User:user.name}" \
  --output table
```

Non inserire Subscription ID o Tenant ID nelle consegne.

---

# 2. Controllare Bicep prima di installare o aggiornare

Bicep può essere gestito tramite Azure CLI.

Verificare:

```bash
az bicep version
```

## Se il comando restituisce una versione

Non reinstallare.

Verificare anche che il comando di lint sia disponibile:

```bash
az bicep lint \
  --file "$LAB_REPO/infra/bicep/main.bicep"
```

## Se Bicep non è installato

Installare tramite Azure CLI:

```bash
az bicep install
```

Poi:

```bash
az bicep version
```

Non è necessario installare un secondo Bicep CLI separato se quello integrato con Azure CLI funziona correttamente.

---

# 3. Leggere il file Bicep prima di eseguirlo

Aprire:

```text
infra/bicep/main.bicep
```

in VS Code.

Individuare:

```text
param location
param storageName
resource storage
output storageAccountName
output blobEndpoint
```

Prima di eseguire il template dobbiamo essere in grado di rispondere:

```text
Quale risorsa verrà creata?
Quale SKU?
Quale regione?
Quali tag?
Quali proprietà di sicurezza?
Quali output otterremo?
```

Non eseguire il deployment finché la struttura del file non è chiara.

---

# 4. Preparare il Resource Group Bicep

Bicep verrà eseguito a **resource-group scope**.

Creiamo quindi il contenitore nel quale il template opererà:

```bash
export BICEP_RG="rg-ud12-bicep"
export LAB_LOCATION="westeurope"
```

```bash
az group create \
  --name "$BICEP_RG" \
  --location "$LAB_LOCATION" \
  --tags Course=AZ104 UD=12 ManagedBy=CLI \
  --output table
```

Lo Storage Account deve avere un nome globalmente univoco.

Generiamo un nome semplice:

```bash
export BICEP_STG="stud12b$(date +%s | tail -c 9)"
```

Verificare:

```bash
echo "$BICEP_STG"
```

Il valore deve contenere soltanto lettere minuscole e numeri e restare entro 24 caratteri.

---

# 5. Lint del template

Entrare nella directory:

```bash
cd "$LAB_REPO/infra/bicep"
```

Eseguire:

```bash
az bicep lint \
  --file main.bicep
```

Se non vengono mostrati errori, possiamo passare al controllo Azure.

Un errore di lint va corretto **prima** del What-If.

---

# 6. What-If: osservare prima di applicare

Eseguiamo:

```bash
az deployment group what-if \
  --resource-group "$BICEP_RG" \
  --template-file main.bicep \
  --parameters \
      location="$LAB_LOCATION" \
      storageName="$BICEP_STG"
```

Leggere il risultato.

Dovremmo vedere una modifica coerente con:

```text
Create
→ Microsoft.Storage/storageAccounts
```

La domanda da porsi non è:

```text
"il comando è riuscito?"
```

ma:

```text
"il cambiamento previsto corrisponde a ciò che ho letto nel file?"
```

Annotare nella consegna:

- resource type;
- change type;
- nome previsto.

---

# 7. Deployment Bicep

Solo dopo aver verificato What-If:

```bash
az deployment group create \
  --name ud12-bicep-deploy \
  --resource-group "$BICEP_RG" \
  --template-file main.bicep \
  --parameters \
      location="$LAB_LOCATION" \
      storageName="$BICEP_STG" \
  --output table
```

Verificare lo Storage Account con Azure CLI:

```bash
az storage account show \
  --resource-group "$BICEP_RG" \
  --name "$BICEP_STG" \
  --query "{
    Name:name,
    Location:location,
    SKU:sku.name,
    TLS:minimumTlsVersion,
    PublicBlob:allowBlobPublicAccess
  }" \
  --output table
```

Il risultato deve essere coerente con il file Bicep.

---

# 8. Leggere gli output Bicep

Gli output del deployment possono essere letti così:

```bash
az deployment group show \
  --name ud12-bicep-deploy \
  --resource-group "$BICEP_RG" \
  --query properties.outputs \
  --output jsonc
```

Individuare:

```text
storageAccountName
blobEndpoint
```

Ora è evidente il ruolo dell'output:

```text
il deployment crea la risorsa
+
restituisce informazioni che possono essere riutilizzate
```

---

# 9. Cleanup del blocco Bicep

Il Resource Group `rg-ud12-bicep` **non serve** al blocco Terraform e non serve alle UD successive.

Possiamo quindi eliminarlo adesso.

```bash
az group delete \
  --name "$BICEP_RG" \
  --yes
```

Verificare:

```bash
az group exists \
  --name "$BICEP_RG"
```

Atteso:

```text
false
```

Notare che abbiamo eliminato:

```text
risorse Azure
```

ma abbiamo conservato:

```text
infra/bicep/main.bicep
```

Questo file verrà riutilizzato in pipeline.

---

# 10. Verificare Terraform prima di installarlo

Passiamo ora a Terraform.

Da WSL2:

```bash
terraform version
```

## Se Terraform è già presente

Se il comando mostra Terraform **1.6 o successivo**, non reinstallare e non aggiornare soltanto perché esiste una versione più nuova.

Verificare:

```bash
terraform -help >/dev/null && echo "Terraform CLI funzionante"
```

## Se Terraform è assente o precedente a 1.6

Utilizzare il repository ufficiale HashiCorp.

Prima verificare gli strumenti necessari:

```bash
command -v wget
command -v gpg
```

Se uno dei due manca:

```bash
sudo apt update
sudo apt install -y wget gpg
```

Aggiungere la chiave del repository:

```bash
wget -O - https://apt.releases.hashicorp.com/gpg \
  | sudo gpg --dearmor \
      -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

Aggiungere il repository:

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

Installare/aggiornare:

```bash
sudo apt update
sudo apt install -y terraform
```

Verificare:

```bash
terraform version
```

Questa installazione avviene nel **WSL2 locale** e quindi prepara il futuro self-hosted Agent.

Non significa che Terraform sia automaticamente disponibile anche su un Microsoft-hosted Agent.

Quando useremo il Microsoft-hosted, sarà la pipeline a verificare la versione realmente presente nel Job e, se necessario, a predisporla.

---

# 11. Leggere la configurazione Terraform

Entrare:

```bash
cd "$LAB_REPO/infra/terraform"
```

Elencare:

```bash
ls -1
```

Aprire i cinque file in VS Code.

## `versions.tf`

Definisce:

```text
versione minima Terraform
provider AzureRM
vincolo versione provider
```

## `providers.tf`

Configura il provider Azure.

## `variables.tf`

Definisce:

```text
location
resource_group_name
storage_account_name
```

## `main.tf`

Definisce:

```text
Resource Group
Storage Account
```

## `outputs.tf`

Espone valori dopo `apply`.

Prima di eseguire Terraform è importante riconoscere la relazione:

```text
Storage Account
→ usa nome e location del Resource Group
```

Questo crea una dipendenza implicita.

---

# 12. Preparare l'autenticazione Terraform

Terraform userà l'identità Azure CLI corrente.

Verificare prima:

```bash
az account show \
  --query "{Subscription:name,User:user.name}" \
  --output table
```

Il provider AzureRM richiede che il Subscription ID sia disponibile.

Impostiamolo come variabile d'ambiente:

```bash
export ARM_SUBSCRIPTION_ID=$(az account show \
  --query id \
  --output tsv)
```

Non scrivere questo valore nei file `.tf`.

Prepariamo inoltre il nome univoco dello Storage Account tramite una variabile Terraform:

```bash
export TF_VAR_storage_account_name="stud12t$(date +%s | tail -c 9)"
```

Verificare soltanto il nome Storage:

```bash
echo "$TF_VAR_storage_account_name"
```

---

# 13. `terraform init`

Eseguire:

```bash
terraform init
```

Questo comando:

- prepara `.terraform/`;
- legge `required_providers`;
- scarica AzureRM;
- crea/aggiorna `.terraform.lock.hcl`.

Verificare:

```bash
ls -la
```

Dovremmo vedere:

```text
.terraform/
.terraform.lock.hcl
```

La lock file è utile e può essere versionata.

La directory `.terraform/` invece non deve essere committata.

---

# 14. Formattazione

Eseguire:

```bash
terraform fmt
```

Poi:

```bash
terraform fmt -check
```

Il secondo comando non deve produrre differenze.

Questo sarà importante in UD13, quando lo stesso controllo verrà eseguito dalla pipeline.

---

# 15. Validazione

```bash
terraform validate
```

Atteso:

```text
Success!
```

`validate` controlla la configurazione, ma non ci dice ancora quali risorse verranno create nella subscription.

---

# 16. Plan

Eseguire:

```bash
terraform plan \
  -out=ud12.tfplan
```

Leggere attentamente il riepilogo.

Atteso:

```text
Plan: 2 to add, 0 to change, 0 to destroy
```

Le due risorse sono:

```text
Resource Group
Storage Account
```

Non eseguire `apply` se il piano mostra risorse inattese.

Annotare nella consegna:

```text
add:
change:
destroy:
```

---

# 17. Apply del piano salvato

Applichiamo esattamente il piano appena letto:

```bash
terraform apply \
  ud12.tfplan
```

Questo è diverso da eseguire un nuovo `terraform apply` senza piano salvato: stiamo applicando il piano che abbiamo appena verificato.

Al termine:

```bash
terraform output
```

Dovremmo vedere:

```text
resource_group_name
storage_account_name
storage_primary_blob_endpoint
```

---

# 18. Verifica indipendente con Azure CLI

L'IaC non sostituisce la verifica.

Controllare:

```bash
az group show \
  --name rg-ud12-tf \
  --query "{Name:name,Location:location,Tags:tags}" \
  --output jsonc
```

Poi:

```bash
az storage account show \
  --resource-group rg-ud12-tf \
  --name "$TF_VAR_storage_account_name" \
  --query "{Name:name,SKU:sku.name,Location:location}" \
  --output table
```

Il risultato Azure deve corrispondere alla configurazione Terraform.

---

# 19. Osservare lo state

Eseguire:

```bash
terraform state list
```

Atteso:

```text
azurerm_resource_group.lab
azurerm_storage_account.lab
```

Poi:

```bash
terraform show \
  -no-color \
  | head -n 60
```

Non copiare integralmente lo state nelle consegne.

La cosa importante da comprendere è:

```text
Terraform conosce quali risorse sta gestendo
```

perché mantiene state.

---

# 20. Non eseguire ancora `destroy`

Le risorse Terraform servono al LAB autonomo.

Quindi, a differenza del blocco Bicep:

```text
NON eseguire terraform destroy adesso
```

Passare a:

```text
03_LAB_AUTONOMO.md
```

mantenendo disponibili:

```text
rg-ud12-tf
Storage Account Terraform
state locale
```

Il cleanup Terraform avverrà soltanto dopo le attività autonome che richiedono queste risorse.

---

## Interpretazione del Gate 2 in un team reale

Nel laboratorio il Gate 2 verifica un singolo host:

```text
WSL2 del partecipante
```

In produzione la stessa idea diventerebbe:

```text
pool-linux-build
├── agent-01 → tool/versioni conformi
├── agent-02 → tool/versioni conformi
└── agent-03 → tool/versioni conformi
```

La pipeline sceglie il Pool, non il server personale di uno sviluppatore. Azure DevOps assegna il Job a un Agent compatibile.

# 21. Gate 2: preparare entrambi i modelli di esecuzione

Il controllo va eseguito **dopo** aver completato il LAB autonomo e il cleanup Terraform, ma prima di chiudere la UD.

La procedura completa è riportata alla fine di `04_VERIFICA.md`.

Avremo due controlli.

## Gate 2A — self-hosted

Il self-hosted Agent usa il nostro WSL2.

Dopo aver installato o verificato nuovi strumenti:

```text
Terraform
Azure CLI / Bicep
Docker
Git
Python
```

riavvieremo `run.sh`.

Non serve:

```text
nuovo PAT
nuovo pool
nuovo config.sh
```

## Gate 2B — Microsoft-hosted

Non eseguiremo ancora una pipeline Microsoft-hosted in UD12.

Verificheremo soltanto lo stato già preparato in UD09:

```text
READY
oppure
PENDING / REQUEST SUBMITTED / BILLING NOT ELIGIBLE
```

Se non è `READY`, non è un blocco per UD13.

La prima pipeline IaC userà infatti il self-hosted Agent.
