# UD12 — Concetti
## Infrastructure as Code con Bicep e Terraform: guida introduttiva per chi parte da zero

Questa UD introduce un modo di lavorare diverso da quello usato finora.

Nelle giornate precedenti abbiamo creato e amministrato risorse Azure tramite:

```text
Portale Azure
Azure CLI
PowerShell
```

Questi strumenti rimangono importanti. Non li stiamo abbandonando.

Ora però vogliamo risolvere un problema nuovo:

> **come possiamo descrivere un'infrastruttura in un file, conservarla nel repository e ricrearla in modo controllato e ripetibile?**

La risposta è l'**Infrastructure as Code**, spesso abbreviata in **IaC**.

In questa UD useremo due strumenti IaC:

```text
Bicep
Terraform
```

Non serve conoscerli già. Li costruiremo un concetto alla volta, partendo dallo stesso esempio che utilizzeremo nel laboratorio guidato.

---

# 1. Il problema da risolvere: ricreare la stessa infrastruttura

Immaginiamo di dover creare uno Storage Account con queste caratteristiche:

```text
regione: West Europe
ridondanza: Standard_LRS
tipo: StorageV2
TLS minimo: TLS 1.2
accesso pubblico ai Blob: disabilitato
```

Dal Portale possiamo farlo seguendo una serie di schermate.

Con Azure CLI possiamo eseguire una serie di comandi.

Entrambe le possibilità funzionano.

Ma immaginiamo ora di dover ripetere la stessa attività:

```text
oggi
tra una settimana
in un altro ambiente
per un'altra applicazione
all'interno di una pipeline
```

Diventa utile poter conservare la descrizione dell'infrastruttura in un file.

Concettualmente vorremmo arrivare a questo:

```text
FILE DI INFRASTRUTTURA
        ↓
strumento IaC
        ↓
Azure
        ↓
RISORSE REALI
```

Questo è il problema che Bicep e Terraform ci aiutano a risolvere.

---

# 2. Che cosa significa Infrastructure as Code

**Infrastructure as Code** significa descrivere l'infrastruttura tramite file testuali trattati come codice.

Per esempio, invece di ricordare manualmente:

```text
crea un Resource Group
crea uno Storage Account
usa West Europe
usa LRS
disabilita l'accesso pubblico ai Blob
```

possiamo conservare queste informazioni in uno o più file.

I file IaC possono essere:

- letti;
- confrontati con `git diff`;
- versionati con Git;
- sottoposti a Pull Request;
- riutilizzati;
- controllati prima del deployment;
- eseguiti in futuro da una pipeline.

Il vantaggio non è quindi soltanto “creare più velocemente”.

Il vantaggio principale è rendere l'infrastruttura:

```text
ripetibile
tracciabile
revisionabile
automatizzabile
```

---

# 3. Imperativo e dichiarativo, spiegati con un esempio

Abbiamo già usato un approccio **imperativo** con Azure CLI.

Un approccio imperativo dice principalmente:

> esegui questa operazione, poi questa, poi questa.

Per esempio:

```text
crea Resource Group
        ↓
crea Storage Account
        ↓
aggiorna proprietà
        ↓
verifica risultato
```

I comandi CLI descrivono quindi delle azioni.

Un approccio **dichiarativo** parte invece da una domanda diversa:

> **come deve essere l'infrastruttura che voglio ottenere?**

Per esempio:

```text
voglio uno Storage Account
in West Europe
con LRS
con TLS 1.2
senza accesso pubblico ai Blob
```

Bicep e Terraform sono strumenti dichiarativi.

Scriviamo lo **stato desiderato** e lasciamo allo strumento il compito di determinare le operazioni necessarie.

Questo non significa che Azure CLI diventi inutile.

Nel nostro percorso continueremo a usare CLI per:

- verificare ciò che è stato creato;
- interrogare Azure;
- diagnosticare problemi;
- preparare alcuni prerequisiti;
- effettuare controlli indipendenti dal codice IaC.

---

# 4. Prima Bicep, poi Terraform: perché questo ordine

Inizieremo con **Bicep** perché è progettato specificamente per Azure e permette di vedere il modello IaC restando molto vicini alle risorse Azure già conosciute.

Poi useremo **Terraform**, che risolve lo stesso problema generale con un'architettura diversa e con un ecosistema multipiattaforma.

Il percorso sarà:

```text
stesso problema
    ↓
Bicep
    ↓
capire il modello dichiarativo
    ↓
Terraform
    ↓
capire provider e state
    ↓
confrontare i due approcci
```

Non dobbiamo decidere oggi quale strumento sia “migliore”.

Dobbiamo capire come funzionano e perché sono differenti.

---

# 5. Bicep in parole semplici

Bicep è un linguaggio dichiarativo progettato per distribuire risorse Azure.

Possiamo pensarlo così:

```text
file .bicep
    ↓
Azure Resource Manager
    ↓
Resource Provider Azure
    ↓
risorsa reale
```

Bicep non è un'alternativa ad Azure Resource Manager.

Bicep è un modo più leggibile per descrivere ciò che Azure Resource Manager deve distribuire.

Nel laboratorio useremo un file chiamato:

```text
infra/bicep/main.bicep
```

Il file reale è questo:

```bicep
@description('Regione Azure nella quale creare lo Storage Account.')
param location string = resourceGroup().location

@description('Nome globalmente univoco dello Storage Account.')
@minLength(3)
@maxLength(24)
param storageName string

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageName
  location: location

  sku: {
    name: 'Standard_LRS'
  }

  kind: 'StorageV2'

  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }

  tags: {
    Course: 'AZ104'
    UD: '12'
    ManagedBy: 'Bicep'
  }
}

output storageAccountName string = storage.name
output blobEndpoint string = storage.properties.primaryEndpoints.blob
```

All'inizio può sembrare molto. Lo leggeremo pezzo per pezzo.

---

# 6. Bicep: che cosa significa `param`

La prima parte contiene:

```bicep
param location string = resourceGroup().location
```

Leggiamola lentamente.

```text
param
→ sto dichiarando un parametro
```

```text
location
→ è il nome che abbiamo scelto per il parametro
```

```text
string
→ il valore deve essere testo
```

```text
= resourceGroup().location
→ se non forniamo un valore diverso,
  usa la regione del Resource Group del deployment
```

Un parametro permette quindi di evitare di scrivere tutti i valori in modo rigido nel file.

Questo rende il file riutilizzabile.

Lo stesso template potrebbe essere usato con:

```text
location = westeurope
```

oppure, in un altro caso:

```text
location = northeurope
```

senza riscrivere tutta la risorsa.

---

# 7. Bicep: il parametro `storageName`

Nel file troviamo:

```bicep
@description('Nome globalmente univoco dello Storage Account.')
@minLength(3)
@maxLength(24)
param storageName string
```

La riga principale è:

```bicep
param storageName string
```

Significa:

> il deployment ha bisogno di un valore testuale chiamato `storageName`.

In questo caso non abbiamo scritto un valore predefinito.

Lo forniremo durante il laboratorio.

Le righe:

```bicep
@minLength(3)
@maxLength(24)
```

aggiungono controlli sul parametro.

Il nome deve rispettare la lunghezza richiesta.

La `@description(...)` serve invece a documentare il significato del parametro.

Queste righe vengono chiamate **decorator**: aggiungono informazioni o vincoli a ciò che segue.

Per il laboratorio è sufficiente capire questo principio; non dobbiamo ancora studiare tutti i decorator disponibili.

---

# 8. Bicep: che cosa significa `resource`

La parte centrale è:

```bicep
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
```

Questa riga contiene quattro idee diverse.

## `resource`

Significa:

> sto dichiarando una risorsa Azure.

## `storage`

È il **nome simbolico** che useremo dentro il file Bicep.

Non è necessariamente il nome reale dello Storage Account in Azure.

Serve a Bicep per riferirsi a questa risorsa nel codice.

## `Microsoft.Storage/storageAccounts`

È il tipo di risorsa Azure.

Possiamo leggerlo così:

```text
Microsoft.Storage
→ Resource Provider

storageAccounts
→ tipo di risorsa gestita da quel provider
```

## `@2023-05-01`

È la versione API utilizzata per descrivere quella risorsa.

Non è la data di creazione del nostro Storage Account.

Indica la versione del contratto API Azure usato dal template per quelle proprietà.

Quindi tutta la riga significa, in parole semplici:

> dichiaro una risorsa Storage Account Azure, che nel file chiamerò simbolicamente `storage`, usando questa versione API.

---

# 9. Nome simbolico Bicep e nome reale Azure non sono la stessa cosa

Subito dopo troviamo:

```bicep
name: storageName
```

Qui è importante distinguere due nomi.

```text
storage
→ nome simbolico dentro il file Bicep
```

```text
storageName
→ parametro che contiene il nome reale da dare alla risorsa Azure
```

Nel laboratorio potremmo ottenere, per esempio:

```text
nome simbolico Bicep:
storage

nome reale Azure:
stud12b12345678
```

Il nome simbolico serve al codice.

Il nome reale è quello che vedremo nel Portale e con Azure CLI.

---

# 10. Leggere le proprietà della risorsa Bicep

Nel blocco troviamo:

```bicep
location: location
```

Il valore della proprietà Azure `location` arriva dal parametro Bicep `location`.

Poi:

```bicep
sku: {
  name: 'Standard_LRS'
}
```

Stiamo dichiarando la SKU dello Storage Account.

Nel nostro caso:

```text
Standard_LRS
→ ridondanza locale LRS
```

Poi:

```bicep
kind: 'StorageV2'
```

indica il tipo generale di Storage Account che vogliamo creare.

Infine:

```bicep
properties: {
  allowBlobPublicAccess: false
  minimumTlsVersion: 'TLS1_2'
}
```

stiamo dichiarando due proprietà di sicurezza:

```text
accesso Blob pubblico
→ disabilitato

TLS minimo
→ 1.2
```

Non stiamo eseguendo comandi separati per ogni proprietà.

Stiamo descrivendo come vogliamo che sia la risorsa.

---

# 11. Bicep: i tag fanno parte della dichiarazione

Il blocco:

```bicep
tags: {
  Course: 'AZ104'
  UD: '12'
  ManagedBy: 'Bicep'
}
```

fa sì che lo Storage Account venga creato già con quei tag.

Il file contiene quindi sia la risorsa sia parte della sua governance descrittiva.

Nel Portale vedremo gli stessi valori.

Questo è un esempio concreto del vantaggio IaC:

```text
configurazione
+
tag
+
proprietà di sicurezza
```

sono conservati nello stesso file versionabile.

---

# 12. Bicep: che cosa sono gli output

In fondo al file troviamo:

```bicep
output storageAccountName string = storage.name
output blobEndpoint string = storage.properties.primaryEndpoints.blob
```

Un **output** è un valore che il deployment restituisce dopo aver lavorato.

Il primo output dice:

> restituisci il nome dello Storage Account creato.

Il secondo dice:

> restituisci l'endpoint Blob primario della risorsa.

Perché è utile?

Immaginiamo una pipeline futura:

```text
Stage 1
crea infrastruttura
        ↓
produce endpoint
        ↓
Stage 2
usa quell'endpoint
```

Nella UD12 ci limiteremo a leggerli manualmente, ma il concetto servirà nelle giornate successive.

---

# 13. Che cosa succede quando eseguiamo un file Bicep

Il file da solo non crea nulla.

Serve un comando di deployment.

Nel laboratorio il percorso sarà:

```text
main.bicep
    ↓
Azure CLI
    ↓
Azure Resource Manager
    ↓
Microsoft.Storage Resource Provider
    ↓
Storage Account
```

Il Resource Group viene creato prima con Azure CLI perché il nostro Bicep verrà distribuito a **resource-group scope**.

Quindi avremo:

```text
rg-ud12-bicep
        ↓
deployment Bicep
        ↓
Storage Account
```

---

# 14. Prima del deployment: lint

Il primo controllo sarà:

```bash
az bicep lint --file main.bicep
```

Il lint controlla il file alla ricerca di problemi che possono essere individuati prima di contattare Azure per il deployment.

Il concetto è semplice:

```text
ho scritto il file
        ↓
prima verifico che sia ragionevole
        ↓
poi passo ai controlli sul deployment
```

Un lint riuscito non significa ancora che il deployment Azure riuscirà sicuramente.

Significa che abbiamo superato un primo controllo sul codice Bicep.

---

# 15. `what-if`: chiedere ad Azure cosa cambierebbe

Prima di creare realmente la risorsa useremo:

```bash
az deployment group what-if ...
```

Il nome è molto intuitivo se lo traduciamo:

> **what if = cosa succederebbe se...?**

Stiamo chiedendo ad Azure Resource Manager:

> se applicassi questo file Bicep a questo Resource Group, quali cambiamenti prevedi?

Nel nostro caso ci aspettiamo qualcosa simile a:

```text
Create
→ Microsoft.Storage/storageAccounts
```

Il punto didattico non è soltanto verificare che il comando finisca senza errore.

Dobbiamo confrontare:

```text
quello che abbiamo letto nel file
```

con:

```text
quello che Azure prevede di fare
```

L'operazione `what-if` non modifica le risorse. È una previsione delle modifiche che il deployment produrrebbe. Può avere limitazioni e non va considerata una garanzia assoluta del risultato finale.

---

# 16. Deployment Bicep: quando le modifiche diventano reali

Dopo aver letto il What-If useremo:

```bash
az deployment group create ...
```

A questo punto cambia la natura dell'operazione.

```text
what-if
→ osservazione preventiva

create
→ deployment reale
```

Azure Resource Manager riceve il template e coordina la distribuzione della risorsa.

Dopo il deployment non ci limiteremo a fidarci del messaggio di successo.

Useremo anche Azure CLI per verificare che:

```text
nome
regione
SKU
TLS
accesso Blob pubblico
```

corrispondano alla dichiarazione Bicep.

---

# 17. Bicep non richiede un file di state da gestire

Questa caratteristica diventerà importante quando passeremo a Terraform.

Con Bicep non dobbiamo conservare un file locale che rappresenti il collegamento fra il nostro codice e le risorse Azure gestite.

Il deployment lavora attraverso Azure Resource Manager, e lo stato effettivo delle risorse è mantenuto in Azure.

Per il partecipante questo significa che nel laboratorio Bicep avremo:

```text
codice Bicep nel repository
+
risorse reali in Azure
```

ma non un file equivalente a:

```text
terraform.tfstate
```

che vedremo tra poco con Terraform.

---

# 18. Dal Bicep a Terraform: l'obiettivo non cambia

Ora cambiamo strumento, ma non problema.

Vogliamo ancora descrivere infrastruttura in modo dichiarativo.

Con Terraform creeremo:

```text
Resource Group
+
Storage Account
```

Quindi possiamo pensare:

```text
Bicep
→ descrive risorse Azure

Terraform
→ descrive risorse Azure
```

La differenza non è semplicemente che uno usa parentesi diverse dall'altro.

Cambiano:

- linguaggio;
- architettura;
- modo di collegarsi alle piattaforme;
- gestione dello state;
- ecosistema.

---

# 19. Terraform in parole semplici

Terraform è uno strumento Infrastructure as Code dichiarativo.

Non nasce esclusivamente per Azure.

Può gestire sistemi diversi utilizzando dei **provider**.

Nel nostro caso:

```text
Terraform Core
      ↓
provider AzureRM
      ↓
Azure API
      ↓
risorse Azure
```

I file Terraform usano normalmente l'estensione:

```text
.tf
```

Il linguaggio di configurazione è HCL, HashiCorp Configuration Language.

Nel nostro laboratorio avremo cinque file:

```text
versions.tf
providers.tf
variables.tf
main.tf
outputs.tf
```

Terraform considera insieme i file `.tf` presenti nella stessa directory di lavoro. La separazione in più file serve soprattutto a mantenerli leggibili e organizzati.

---

# 20. Perché Terraform ha bisogno di un provider

Una domanda utile è:

> come può un unico programma conoscere contemporaneamente Azure, AWS, GitHub, VMware e molti altri sistemi?

Terraform separa il motore generale dai componenti che conoscono le singole piattaforme.

Questi componenti sono i **provider**.

Possiamo immaginarli come adattatori specializzati:

```text
Terraform
   ↓
Provider AzureRM
   ↓
Azure
```

Un provider aggiunge a Terraform i tipi di risorsa che può gestire per quella piattaforma.

Senza provider AzureRM Terraform non saprebbe che cosa sia, per esempio:

```text
azurerm_resource_group
azurerm_storage_account
```

---

# 21. `versions.tf`: dichiarare Terraform e provider richiesti

Il nostro file reale contiene:

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.4"
    }
  }
}
```

Leggiamolo.

```hcl
required_version = ">= 1.6.0"
```

significa:

> questa configurazione richiede Terraform 1.6 o successivo.

Poi:

```hcl
source = "hashicorp/azurerm"
```

indica quale provider serve.

Nel nostro caso è il provider AzureRM distribuito con namespace `hashicorp`.

Infine:

```hcl
version = "~> 5.4"
```

pone un vincolo sulla famiglia di versioni del provider usata da questo laboratorio.

Il punto importante per il neofita è:

```text
versions.tf
→ dichiara quali componenti/versioni servono alla configurazione
```

---

# 22. `providers.tf`: configurare il provider Azure

Il file contiene:

```hcl
provider "azurerm" {
  features {}
}
```

Questo blocco dice a Terraform:

> usa e configura il provider AzureRM dichiarato in `versions.tf`.

Il blocco `features {}` è richiesto dalla configurazione del provider AzureRM usata nel laboratorio.

Non stiamo inserendo username o password nel file.

L'autenticazione verrà preparata dall'ambiente in cui eseguiamo Terraform.

Nel LAB useremo l'identità con cui abbiamo già effettuato `az login` e forniremo anche il Subscription ID richiesto dal nostro scenario tramite variabile d'ambiente.

---

# 23. Terraform e autenticazione: codice e credenziali devono restare separati

Il file `.tf` descrive l'infrastruttura.

Non vogliamo inserire nel repository valori personali o credenziali.

Per questo nel laboratorio prepareremo:

```bash
export ARM_SUBSCRIPTION_ID=$(az account show --query id --output tsv)
```

Possiamo rappresentare la separazione così:

```text
FILE TERRAFORM
→ descrive infrastruttura

AMBIENTE DI ESECUZIONE
→ fornisce identità e contesto Azure
```

Questo principio diventerà ancora più importante quando il codice verrà eseguito da una pipeline.

---

# 24. `variables.tf`: valori che possono cambiare

Il nostro file contiene, tra le altre, questa variabile:

```hcl
variable "location" {
  description = "Regione Azure del laboratorio."
  type        = string
  default     = "westeurope"
}
```

Possiamo leggerla così:

```text
variable
→ dichiaro un valore configurabile

location
→ nome della variabile

string
→ deve essere testo

default = westeurope
→ valore usato se non ne forniamo un altro
```

Abbiamo anche:

```hcl
variable "resource_group_name" {
  description = "Nome del Resource Group gestito da Terraform."
  type        = string
  default     = "rg-ud12-tf"
}
```

Quindi il nostro Resource Group avrà normalmente quel nome.

---

# 25. La variabile dello Storage Account e la validazione

La variabile più interessante è:

```hcl
variable "storage_account_name" {
  description = "Nome globalmente univoco dello Storage Account."
  type        = string

  validation {
    condition = (
      length(var.storage_account_name) >= 3 &&
      length(var.storage_account_name) <= 24 &&
      can(regex("^[a-z0-9]+$", var.storage_account_name))
    )

    error_message = "Il nome Storage deve contenere 3-24 caratteri, solo lettere minuscole e numeri."
  }
}
```

Non è necessario memorizzare oggi tutta la sintassi della condizione.

Dobbiamo capire lo scopo:

> prima di usare il valore, Terraform verifica che abbia una forma compatibile con le regole che abbiamo stabilito.

La validazione controlla:

```text
lunghezza minima
lunghezza massima
solo lettere minuscole e numeri
```

Nel LAB non scriveremo il nome nel file.

Lo forniremo tramite:

```bash
export TF_VAR_storage_account_name="..."
```

Terraform riconosce il prefisso:

```text
TF_VAR_
```

come un modo per fornire il valore di una variabile dichiarata nella configurazione.

---

# 26. `main.tf`: prima risorsa, il Resource Group

Il primo blocco è:

```hcl
resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Course    = "AZ104"
    UD        = "12"
    ManagedBy = "Terraform"
  }
}
```

Leggiamo la prima riga:

```hcl
resource "azurerm_resource_group" "lab"
```

```text
resource
→ sto dichiarando una risorsa

azurerm_resource_group
→ tipo di risorsa definito dal provider AzureRM

lab
→ nome logico usato da Terraform dentro questa configurazione
```

Poi:

```hcl
name = var.resource_group_name
```

significa:

> il nome reale Azure arriva dalla variabile `resource_group_name`.

Con il valore predefinito sarà:

```text
rg-ud12-tf
```

Ancora una volta:

```text
lab
→ nome logico Terraform

rg-ud12-tf
→ nome reale Azure
```

---

# 27. `main.tf`: seconda risorsa, lo Storage Account

Il secondo blocco è:

```hcl
resource "azurerm_storage_account" "lab" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = {
    Course    = "AZ104"
    UD        = "12"
    ManagedBy = "Terraform"
  }
}
```

La prima riga dichiara:

```text
azurerm_storage_account
→ tipo risorsa Terraform fornito da AzureRM

lab
→ nome logico Terraform
```

Il nome Azure reale arriva invece da:

```hcl
name = var.storage_account_name
```

Quindi anche Terraform distingue:

```text
nome logico nel codice
```

da:

```text
nome reale della risorsa nel cloud
```

---

# 28. I riferimenti Terraform creano relazioni fra le risorse

Nel blocco Storage troviamo:

```hcl
resource_group_name = azurerm_resource_group.lab.name
location            = azurerm_resource_group.lab.location
```

Queste righe sono molto importanti.

Non abbiamo scritto semplicemente:

```text
resource_group_name = "rg-ud12-tf"
```

Stiamo dicendo:

> usa il nome della risorsa `azurerm_resource_group.lab` che Terraform sta gestendo.

E:

> usa la location della stessa risorsa.

Possiamo rappresentarlo così:

```text
azurerm_resource_group.lab
        │
        ├── .name ────────→ Storage Account resource_group_name
        │
        └── .location ────→ Storage Account location
```

Terraform può quindi dedurre una dipendenza:

```text
Resource Group
    ↓
Storage Account
```

Non dobbiamo scrivere manualmente “crea prima questo e poi quello” per questa relazione.

---

# 29. `outputs.tf`: restituire valori utili

Il file contiene:

```hcl
output "resource_group_name" {
  description = "Resource Group creato da Terraform."
  value       = azurerm_resource_group.lab.name
}
```

Poi:

```hcl
output "storage_account_name" {
  description = "Storage Account creato da Terraform."
  value       = azurerm_storage_account.lab.name
}
```

E anche l'endpoint Blob.

Il concetto è simile agli output Bicep:

```text
deployment
→ crea/gestisce risorse
→ espone informazioni utili
```

Dopo `apply` useremo:

```bash
terraform output
```

per leggerli.

---

# 30. Il ciclo Terraform prima di eseguirlo davvero

Prima del laboratorio dobbiamo conoscere l'ordine logico:

```text
file .tf
   ↓
terraform init
   ↓
terraform fmt
   ↓
terraform validate
   ↓
terraform plan
   ↓
LEGGIAMO IL PIANO
   ↓
terraform apply
   ↓
terraform output
   ↓
verifica con Azure CLI
```

Non è una formula da memorizzare senza comprenderla.

Ogni passaggio risponde a una domanda diversa.

---

# 31. `terraform init`: preparare la directory di lavoro

Quando eseguiamo:

```bash
terraform init
```

Terraform legge la configurazione e prepara la directory di lavoro.

Tra le altre cose:

- individua i provider richiesti;
- scarica il provider AzureRM se necessario;
- prepara `.terraform/`;
- crea o aggiorna `.terraform.lock.hcl`.

Possiamo pensare:

```text
ho i file .tf
        ↓
init
        ↓
Terraform prepara ciò che serve per lavorare con quei file
```

La directory:

```text
.terraform/
```

contiene materiale locale scaricato da Terraform e non va trattata come normale sorgente Git.

La lock file:

```text
.terraform.lock.hcl
```

serve invece a registrare informazioni sulle versioni effettivamente selezionate dei provider e normalmente ha senso versionarla.

---

# 32. `terraform fmt`: rendere uniforme il codice

Il comando:

```bash
terraform fmt
```

formatta i file HCL secondo lo stile standard Terraform.

Non crea risorse Azure.

Non controlla i permessi Azure.

Serve a rendere il codice coerente e leggibile.

Con:

```bash
terraform fmt -check
```

possiamo controllare se il codice è già formattato senza modificarlo.

Questo tipo di controllo è molto utile in una pipeline CI.

---

# 33. `terraform validate`: controllare la configurazione

Poi useremo:

```bash
terraform validate
```

Il comando controlla che la configurazione sia sintatticamente valida e internamente coerente.

Non significa ancora:

```text
le risorse sono state create
```

né:

```text
Azure accetterà sicuramente ogni operazione
```

Significa che Terraform ha superato un controllo sulla configurazione.

---

# 34. `terraform plan`: il passaggio da imparare a leggere

Ora arriviamo a uno dei comandi più importanti:

```bash
terraform plan
```

Terraform deve capire:

```text
che cosa dichiara il codice?
che cosa sto già gestendo?
che cosa esiste realmente?
che cosa deve cambiare?
```

Il risultato è un **piano**.

Nel nostro primo laboratorio ci aspettiamo:

```text
Plan: 2 to add, 0 to change, 0 to destroy
```

Perché?

Perché Terraform dovrà creare:

```text
1 Resource Group
1 Storage Account
```

Prima di fare `apply` dobbiamo leggerlo.

Il comportamento professionale è:

```text
plan
→ controllo umano
→ apply
```

non:

```text
apply immediato
→ vediamo cosa succede
```

---

# 35. Piano salvato: perché nel LAB usiamo `-out`

Nel laboratorio eseguiremo:

```bash
terraform plan -out=ud12.tfplan
```

Questo salva il piano in un file.

Poi eseguiremo:

```bash
terraform apply ud12.tfplan
```

Il vantaggio didattico è chiaro:

> applichiamo esattamente il piano che abbiamo appena letto.

Quindi:

```text
plan salvato
    ↓
controllo
    ↓
apply di QUEL piano
```

---

# 36. `terraform apply`: modificare realmente l'infrastruttura

Con `apply` Terraform passa dalla previsione all'azione.

Concettualmente:

```text
plan
→ cosa intendo fare

apply
→ eseguo realmente le modifiche
```

Dopo l'apply useremo:

```bash
terraform output
```

ma faremo anche una verifica indipendente con Azure CLI.

Questo è importante:

> lo strumento che crea la risorsa non deve essere l'unica fonte usata per verificare il risultato.

---

# 37. La domanda che introduce lo State

Ora arriva il concetto più nuovo di Terraform.

Immaginiamo che oggi Terraform crei questo Storage Account:

```text
stud12t12345678
```

Domani modifichiamo `main.tf`.

Come fa Terraform a sapere che:

```text
azurerm_storage_account.lab
```

nel nostro codice corrisponde proprio a:

```text
stud12t12345678
```

in Azure?

Terraform deve mantenere una relazione fra:

```text
oggetto dichiarato nel codice
```

e:

```text
oggetto reale nella piattaforma remota
```

Questa è una delle funzioni fondamentali dello **state**.

---

# 38. State Terraform spiegato con un disegno

Nel nostro laboratorio useremo state locale:

```text
terraform.tfstate
```

Possiamo immaginare:

```text
CODICE
azurerm_storage_account.lab
            │
            ▼
     terraform.tfstate
            │
            ▼
AZURE
stud12t12345678
```

Lo state conserva le associazioni e altre informazioni necessarie a Terraform per gestire nel tempo l'infrastruttura.

Terraform usa lo state insieme alla configurazione e alle informazioni ottenute dai provider per determinare le modifiche da proporre.

Per questo lo state è parte importante del funzionamento Terraform, non un semplice log di testo.

---

# 39. Perché lo State non va trattato come un normale file sorgente

Lo state può contenere:

- identificativi di risorse;
- proprietà;
- metadati;
- in alcuni casi valori sensibili.

Quindi non dobbiamo pensare:

```text
è un file del progetto
→ lo committo automaticamente in Git
```

Nella UD12 useremo uno state locale perché ogni partecipante lavora individualmente.

Più avanti introdurremo il problema della collaborazione e del **remote state**.

Per ora è sufficiente sapere:

```text
codice .tf
→ si versiona

terraform.tfstate
→ si gestisce con attenzione
→ non è normale sorgente applicativo
```

---

# 40. `terraform state list`: vedere cosa Terraform sta gestendo

Dopo l'apply useremo:

```bash
terraform state list
```

Ci aspettiamo:

```text
azurerm_resource_group.lab
azurerm_storage_account.lab
```

Questo comando non ci sta mostrando semplicemente tutte le risorse della Subscription.

Ci sta mostrando gli oggetti che **questa configurazione Terraform sta gestendo attraverso il proprio state**.

È una differenza fondamentale.

---

# 41. `terraform destroy`: eliminare le risorse gestite, non il codice

Più avanti useremo:

```bash
terraform destroy
```

Il comando chiede a Terraform di rimuovere le risorse che quella configurazione/state gestisce e che risultano da distruggere.

Non elimina automaticamente:

```text
main.tf
variables.tf
outputs.tf
providers.tf
versions.tf
```

Quindi possiamo arrivare a:

```text
risorse Azure eliminate
+
codice IaC ancora nel repository
```

Questo è esattamente ciò che vogliamo a fine laboratorio.

---

# 42. Bicep e Terraform: stessa esigenza, due percorsi

Ora possiamo confrontarli usando lo stesso obiettivo.

Immaginiamo sempre di voler creare uno Storage Account.

## Con Bicep

```bicep
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageName
  location: location

  sku: {
    name: 'Standard_LRS'
  }

  kind: 'StorageV2'
}
```

Il percorso concettuale è:

```text
Bicep
   ↓
Azure Resource Manager
   ↓
Azure Resource Provider
   ↓
Storage Account
```

## Con Terraform

```hcl
resource "azurerm_storage_account" "lab" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

Il percorso concettuale è:

```text
Terraform Core
   ↓
AzureRM Provider
   ↓
Azure API
   ↓
Storage Account
```

L'obiettivo può essere lo stesso.

Il meccanismo e l'ecosistema sono differenti.

---

# 43. Bicep vs Terraform: confronto ragionato

| Aspetto | Bicep | Terraform |
|---|---|---|
| Ecosistema principale | Azure | Multipiattaforma tramite provider |
| Linguaggio | Bicep | HCL |
| Rapporto con Azure | Azure Resource Manager | Provider AzureRM |
| Anteprima principale | ARM What-If | `terraform plan` |
| Applicazione | deployment ARM/Bicep | `terraform apply` |
| State file Terraform-like da gestire | No | Sì |
| Provider esterni | Non è il modello principale | Elemento centrale |
| Moduli riutilizzabili | Sì | Sì |
| Integrazione Git/pipeline | Sì | Sì |
| Caso molto naturale | IaC Azure-native | Standard IaC multi-provider o organizzazioni già Terraform |

La tabella da sola però non basta.

Vediamo tre casi.

## Caso A — azienda fortemente Azure

```text
Azure
Azure Resource Manager
team Microsoft-oriented
```

Bicep può essere una scelta molto naturale perché è strettamente integrato con il modello Azure.

## Caso B — azienda con più piattaforme

```text
Azure
AWS
GitHub
Cloudflare
VMware
```

Terraform può offrire un modello comune attraverso provider differenti.

## Caso C — solo Azure, ma standard aziendale Terraform

Anche se l'azienda utilizza quasi esclusivamente Azure, potrebbe avere già:

```text
moduli Terraform
remote state
pipeline Terraform
regole interne
competenze del team
```

In quel caso Terraform può essere perfettamente sensato.

La conclusione corretta è:

> **non esiste una scelta universalmente migliore; bisogna valutare piattaforme, standard, competenze, governance e architettura operativa.**

---

# 44. Una differenza molto importante: Bicep e lo State Terraform

Questa è la differenza che vogliamo ricordare più chiaramente.

## Bicep

```text
file Bicep
   ↓
Azure Resource Manager
   ↓
Azure conserva lo stato reale delle risorse
```

Non gestiamo un file locale equivalente a `terraform.tfstate`.

## Terraform

```text
file .tf
   ↓
Terraform
   ↓
state
   ↓
provider
   ↓
risorse reali
```

Terraform ha bisogno dello state per mantenere il binding fra gli oggetti dichiarati e gli oggetti remoti gestiti.

Quindi:

```text
Bicep
→ nessun Terraform-style state file da amministrare

Terraform
→ gestione dello state è una responsabilità importante
```

Questo avrà conseguenze quando lavoreremo in team.

---

# 45. What-If e Plan: somiglianza utile, ma non sono la stessa tecnologia

Per un neofita può essere utile collegarli:

```text
Bicep / ARM
what-if
→ quali modifiche prevede Azure?
```

```text
Terraform
plan
→ quali modifiche prevede Terraform?
```

Entrambi ci insegnano una buona abitudine:

> **osservare il cambiamento previsto prima di applicarlo.**

Ma non dobbiamo considerarli lo stesso meccanismo interno.

What-If appartiene al modello Azure Resource Manager.

Plan appartiene al modello Terraform e usa configurazione, state e provider.

---

# 46. Infrastructure as Code e Git

I file IaC diventano ancora più utili quando vengono versionati.

Dopo questa UD il repository personale conterrà:

```text
infra/
├── bicep/
│   └── main.bicep
└── terraform/
    ├── versions.tf
    ├── providers.tf
    ├── variables.tf
    ├── main.tf
    └── outputs.tf
```

Da questo momento una modifica infrastrutturale può seguire un percorso simile al codice applicativo:

```text
branch
   ↓
modifica IaC
   ↓
git diff
   ↓
commit
   ↓
Pull Request / review
   ↓
pipeline
```

Questo collega direttamente Git, IaC e DevOps.

---

# 47. Dal terminale alla pipeline: chi eseguirà questi comandi?

Oggi eseguiremo manualmente:

```text
az bicep lint
az deployment group what-if
az deployment group create
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Nelle UD successive alcuni degli stessi comandi saranno eseguiti da Azure Pipelines.

La domanda diventa:

> su quale macchina vengono eseguiti realmente?

La risposta è:

```text
Pipeline
   ↓
Job
   ↓
Agent
   ↓
programmi presenti sull'Agent
```

Il file YAML non “contiene Terraform”.

L'Agent deve poter eseguire realmente il programma richiesto.

---

# 48. Self-hosted Agent: che cosa rappresenta il nostro WSL2

Nel laboratorio il self-hosted Agent è installato nel WSL2 del partecipante.

Quindi:

```text
pool-ud09-wsl
       ↓
Agent
       ↓
WSL2 personale
```

Questa è una soluzione didattica.

In un'azienda il modello sarebbe più spesso:

```text
pool-linux-build
├── build-agent-01
├── build-agent-02
└── build-agent-03
```

Quindi la regola da ricordare è:

```text
self-hosted
≠ PC dello sviluppatore

self-hosted
= infrastruttura Agent gestita dall'organizzazione
```

Quando oggi installiamo Terraform nel WSL2, stiamo simulando la preparazione della toolchain di un vero build host aziendale.

---

# 49. Perché i tool del self-hosted restano disponibili

Il self-hosted usa una macchina persistente.

Se installiamo:

```text
Terraform
Azure CLI
Bicep
Docker
Python
```

quei programmi restano sulla macchina finché non vengono rimossi o l'ambiente non viene ricreato.

Questo è comodo.

Ma significa anche che l'organizzazione deve governare:

```text
versioni
aggiornamenti
PATH
dipendenze
sicurezza
```

Se installiamo nuovo software mentre l'Agent è già in esecuzione, può essere necessario riavviare l'Agent affinché rilevi nuovamente l'ambiente e le capability.

Non significa che dobbiamo creare un nuovo Pool o un nuovo Agent da zero.

---

# 50. Microsoft-hosted Agent: il modello è diverso

Con un Microsoft-hosted Agent useremo, per esempio:

```yaml
pool:
  vmImage: ubuntu-latest
```

Azure Pipelines assegna al Job una macchina preparata da Microsoft.

Il concetto fondamentale è:

```text
Job A
→ macchina temporanea

Job B
→ nuova macchina temporanea
```

Non dobbiamo fare affidamento su file o installazioni lasciati da un Job precedente.

Quindi la pipeline deve verificare l'ambiente di cui ha bisogno.

Per esempio:

```bash
az version
az bicep version
terraform version
python3 --version
docker --version
```

Se una specifica versione è necessaria, la pipeline deve renderlo esplicito invece di affidarsi a un'ipotesi implicita sull'immagine hosted.

---

# 51. Gate 2: perché lo facciamo a fine UD12

A fine UD12 vogliamo verificare che il percorso sia pronto per le pipeline successive.

Il Gate 2 ha due significati diversi.

## Self-hosted

Vogliamo verificare che il nostro build host didattico possieda davvero:

```text
Azure CLI
Bicep
Terraform
```

insieme agli altri strumenti preparati nelle UD precedenti.

## Microsoft-hosted

Non stiamo installando oggi software in modo permanente su un runner Microsoft.

Vogliamo invece aver compreso che:

```text
ogni Job hosted parte da un ambiente nuovo
```

e che le future pipeline dovranno controllare i tool disponibili.

---

# 52. Cleanup: risorse temporanee e codice hanno lifecycle differenti

Durante la UD creeremo risorse Azure temporanee.

Ma il codice IaC non è temporaneo.

La distinzione è:

```text
RISORSE LAB
→ possono essere eliminate quando non servono più
```

```text
CODICE IaC
→ deve rimanere nel repository
→ verrà riutilizzato nelle UD successive
```

Per Bicep elimineremo il Resource Group del blocco guidato quando non serve più.

Per Terraform non faremo subito `destroy` nel LAB guidato perché le risorse servono ancora al LAB autonomo.

Il cleanup Terraform avverrà soltanto quando tutte le attività che dipendono da quelle risorse saranno terminate.

---

# 53. Mappa diretta: quello che hai studiato → quello che farai nel LAB

Questa tabella serve come ponte verso `02_LAB_GUIDATO.md`.

| Concetto studiato | Attività nel LAB |
|---|---|
| parametri Bicep | fornirai `location` e `storageName` |
| `resource` Bicep | leggerai lo Storage Account dichiarato |
| lint | eseguirai `az bicep lint` |
| What-If | controllerai il `Create` previsto |
| deployment | eseguirai `az deployment group create` |
| output Bicep | leggerai nome ed endpoint Blob |
| provider Terraform | `terraform init` scaricherà AzureRM |
| variables | userai `TF_VAR_storage_account_name` |
| riferimenti fra risorse | Storage userà nome/location del Resource Group |
| fmt | controllerai la formattazione |
| validate | controllerai la configurazione |
| plan | leggerai `2 to add` prima di applicare |
| apply | creerai realmente RG + Storage |
| output Terraform | leggerai i valori creati |
| state | userai `terraform state list` |
| Agent readiness | eseguirai il Gate 2 a fine UD |

Se questa tabella è chiara, il laboratorio non dovrebbe apparire come un argomento nuovo.

---

# 54. Prima di passare al LAB: prova a raccontare il flusso con parole tue

Per Bicep dovresti riuscire a dire:

> Ho un file che descrive uno Storage Account Azure. Prima controllo il file con lint, poi chiedo ad Azure con What-If quali modifiche prevede. Se il risultato è quello atteso, eseguo il deployment reale e verifico la risorsa anche con Azure CLI.

Per Terraform dovresti riuscire a dire:

> Ho una configurazione composta da file `.tf`. Terraform usa il provider AzureRM per lavorare con Azure. Prima inizializzo la directory, formatto e valido la configurazione, poi genero un plan. Se il piano contiene solo le modifiche attese, eseguo apply. Terraform mantiene uno state che collega gli oggetti dichiarati alle risorse reali gestite.

Se questi due paragrafi hanno senso, sei pronto per il laboratorio guidato.

---

# 55. Domande di controllo

1. Quale problema risolve l'Infrastructure as Code rispetto a una configurazione esclusivamente manuale?
2. Spiega con parole semplici la differenza tra approccio imperativo e dichiarativo.
3. Bicep sostituisce Azure Resource Manager? Spiega il rapporto fra i due.
4. Che cosa significa `param location string` in Bicep?
5. A cosa servono `@minLength` e `@maxLength` nel nostro file?
6. Nella riga `resource storage 'Microsoft.Storage/storageAccounts@2023-05-01'`, che cosa significano `storage`, `Microsoft.Storage/storageAccounts` e `2023-05-01`?
7. Qual è la differenza fra nome simbolico Bicep e nome reale della risorsa Azure?
8. Quali proprietà di sicurezza vengono impostate sullo Storage Account Bicep della UD12?
9. Che cosa sono gli output Bicep e perché possono essere utili?
10. Che cosa controlla `az bicep lint`?
11. Che cosa chiede ad Azure l'operazione What-If?
12. What-If modifica realmente le risorse?
13. Qual è la differenza concettuale tra What-If e deployment `create`?
14. Perché Bicep non richiede un file locale equivalente a `terraform.tfstate`?
15. Che cos'è Terraform e perché non è specifico soltanto di Azure?
16. Che cos'è un provider Terraform?
17. Nel nostro laboratorio, che ruolo ha il provider AzureRM?
18. Che cosa dichiara `versions.tf`?
19. A cosa serve `providers.tf`?
20. Perché non inseriamo Subscription ID e credenziali direttamente nei file `.tf`?
21. Che cosa sono le variabili Terraform?
22. A cosa serve la validation di `storage_account_name`?
23. Nella riga `resource "azurerm_resource_group" "lab"`, che cosa significano il tipo e il nome logico?
24. Perché `azurerm_storage_account.lab` dipende dal Resource Group nel nostro `main.tf`?
25. A cosa servono gli output Terraform?
26. Spiega con parole tue `init`, `fmt`, `validate`, `plan` e `apply`.
27. Perché nel laboratorio salviamo il piano in `ud12.tfplan`?
28. Che cos'è lo state Terraform e quale problema risolve?
29. Perché `terraform state list` non equivale a elencare tutte le risorse della Subscription Azure?
30. Perché `terraform.tfstate` non deve essere trattato come un normale file sorgente?
31. `terraform destroy` elimina anche i file `.tf`? Spiega.
32. Qual è la differenza principale nel percorso tecnico Bicep→Azure rispetto a Terraform→Azure?
33. Confronta What-If e `terraform plan` senza dire che sono la stessa cosa.
34. In quali contesti Bicep può essere una scelta naturale?
35. In quali contesti Terraform può essere una scelta naturale?
36. Perché non ha senso dire semplicemente che Bicep è “migliore” o “peggiore” di Terraform?
37. Perché i file IaC devono essere versionati in Git?
38. Su quale componente vengono realmente eseguiti i comandi Terraform/Bicep quando entrano in una pipeline?
39. Che cosa rappresenta il WSL2 del partecipante nel nostro modello self-hosted didattico?
40. Qual è la differenza fra persistenza del self-hosted e ambiente nuovo del Microsoft-hosted Agent?
41. Perché installare Terraform sul WSL2 oggi è utile per le UD successive?
42. Perché il cleanup delle risorse non implica il cleanup del codice IaC?
