# UD12 — Concetti
## Infrastructure as Code con Bicep e Terraform
### Guida introduttiva, passo per passo, per chi parte da zero

---

## Come usare questo file

Questa UD introduce un modo di lavorare diverso da quello usato nelle giornate precedenti.

Finora abbiamo creato e amministrato risorse Azure principalmente tramite:

```text
Portale Azure
Azure CLI
PowerShell
```

Questi strumenti **rimangono importanti** e continueremo a usarli.

Da questa UD aggiungiamo però un nuovo modo di descrivere e creare l'infrastruttura:

```text
Infrastructure as Code
```

abbreviato in:

```text
IaC
```

L'obiettivo di questo file non è farti memorizzare subito Bicep o Terraform.

L'obiettivo è arrivare al laboratorio guidato sapendo spiegare, con parole tue:

```text
che cosa sto facendo
perché lo sto facendo
quale file sto leggendo
che cosa significa ogni parte importante
che cosa succederà quando eseguirò i comandi
```

Per questo procederemo lentamente.

Prima capiremo il problema.

Poi useremo **Bicep**.

Successivamente useremo **Terraform**.

Infine confronteremo i due strumenti.

---

# 1. Il problema: creare una risorsa una volta è facile, ricrearla sempre uguale è più difficile

Immaginiamo di dover creare uno Storage Account Azure con queste caratteristiche:

```text
regione: West Europe
ridondanza: Standard_LRS
tipo: StorageV2
TLS minimo: TLS 1.2
accesso pubblico ai Blob: disabilitato
```

Possiamo farlo dal Portale Azure.

Possiamo anche farlo con Azure CLI.

Entrambe le soluzioni funzionano.

Il problema nasce quando dobbiamo ripetere la stessa attività:

```text
oggi
domani
in un ambiente di test
in un ambiente di produzione
per un'altra applicazione
all'interno di una pipeline
```

Se lavoriamo soltanto manualmente dobbiamo ricordare:

```text
quali opzioni abbiamo scelto
quali proprietà abbiamo impostato
quali valori abbiamo usato
in quale ordine abbiamo eseguito le operazioni
```

Più l'infrastruttura cresce, più diventa difficile ripeterla in modo identico.

L'idea dell'Infrastructure as Code nasce per risolvere proprio questo problema.

---

# 2. Che cosa significa Infrastructure as Code

**Infrastructure as Code** significa descrivere l'infrastruttura tramite file testuali trattati come codice.

Invece di conservare soltanto una procedura scritta del tipo:

```text
1. apri il Portale
2. crea il Resource Group
3. crea lo Storage Account
4. scegli West Europe
5. scegli LRS
6. imposta TLS 1.2
7. disabilita l'accesso pubblico ai Blob
```

possiamo conservare una descrizione dell'infrastruttura in uno o più file.

Concettualmente:

```text
FILE IaC
   ↓
strumento IaC
   ↓
Azure
   ↓
RISORSE REALI
```

Il file può essere:

- letto;
- modificato;
- confrontato con `git diff`;
- versionato con Git;
- sottoposto a Pull Request;
- controllato prima del deployment;
- riutilizzato in futuro;
- eseguito manualmente;
- eseguito da una pipeline.

L'obiettivo quindi non è semplicemente:

> creare una risorsa più velocemente.

L'obiettivo è rendere l'infrastruttura:

```text
ripetibile
tracciabile
revisionabile
automatizzabile
```

---

# 3. Imperativo e dichiarativo: la differenza con un esempio semplice

Con Azure CLI abbiamo spesso lavorato in modo **imperativo**.

Imperativo significa:

> esegui queste operazioni.

Per esempio:

```text
crea un Resource Group
        ↓
crea uno Storage Account
        ↓
imposta alcune proprietà
        ↓
verifica il risultato
```

Qui descriviamo soprattutto **le azioni** da eseguire.

Con Bicep e Terraform introduciamo invece un approccio **dichiarativo**.

Dichiarativo significa:

> descrivo come voglio che sia l'infrastruttura.

Per esempio:

```text
voglio uno Storage Account
in West Europe
con ridondanza LRS
con TLS minimo 1.2
senza accesso pubblico ai Blob
```

Lo strumento IaC legge questa descrizione e determina quali operazioni devono essere eseguite per ottenere quel risultato.

Possiamo quindi ricordare:

```text
IMPERATIVO
→ descrivo principalmente le operazioni

DICHIARATIVO
→ descrivo principalmente lo stato desiderato
```

Questo non significa che Azure CLI non serva più.

Continueremo a usarla per:

- verificare le risorse;
- interrogare Azure;
- fare troubleshooting;
- preparare prerequisiti;
- controllare in modo indipendente ciò che Bicep o Terraform hanno creato.

---

# 4. Perché studiamo prima Bicep e poi Terraform

Useremo prima **Bicep** perché è progettato specificamente per Azure.

Poi useremo **Terraform**, che affronta lo stesso problema IaC ma con un'architettura differente.

La progressione sarà:

```text
capire IaC
    ↓
Bicep
    ↓
capire il modello dichiarativo su Azure
    ↓
Terraform
    ↓
capire provider e state
    ↓
confrontare i due strumenti
```

Non dobbiamo decidere adesso quale sia “migliore”.

Dobbiamo prima capire:

```text
come funzionano
cosa hanno in comune
in cosa differiscono
quando può avere senso scegliere uno o l'altro
```

---

# 5. Bicep: che cos'è, in parole semplici

Bicep è un linguaggio dichiarativo progettato per descrivere risorse Azure.

Un file Bicep ha normalmente estensione:

```text
.bicep
```

Nel nostro laboratorio useremo:

```text
infra/bicep/main.bicep
```

Il percorso concettuale è:

```text
main.bicep
    ↓
Azure Resource Manager
    ↓
Resource Provider Azure
    ↓
risorsa reale
```

Bicep non sostituisce Azure Resource Manager.

Possiamo pensare a Bicep come a un modo più leggibile e compatto per descrivere ciò che Azure Resource Manager dovrà distribuire.

---

# 6. Il file Bicep che useremo nel laboratorio

Il file reale della UD12 è:

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

Se è la prima volta che vedi Bicep, non cercare di capirlo tutto insieme.

Lo scomporremo in piccoli blocchi.

---

# 7. `param`: un valore che il file può ricevere dall'esterno

La prima riga importante è:

```bicep
param location string = resourceGroup().location
```

Leggiamola parte per parte.

```text
param
→ sto dichiarando un parametro
```

```text
location
→ è il nome del parametro
```

```text
string
→ il valore deve essere testuale
```

Poi troviamo:

```bicep
= resourceGroup().location
```

Significa:

> se non fornisco un valore diverso, usa la stessa regione del Resource Group nel quale sto eseguendo il deployment.

Quindi `location` non è una risorsa.

È un **valore** che useremo più avanti.

Un parametro rende il file riutilizzabile.

Per esempio lo stesso template potrebbe essere usato con:

```text
westeurope
```

oppure:

```text
northeurope
```

senza riscrivere tutta la risorsa.

---

# 8. `storageName`: un parametro senza valore predefinito

Il file contiene:

```bicep
@description('Nome globalmente univoco dello Storage Account.')
@minLength(3)
@maxLength(24)
param storageName string
```

La parte principale è:

```bicep
param storageName string
```

Significa:

> il deployment ha bisogno di un valore testuale chiamato `storageName`.

Qui non abbiamo impostato un valore predefinito.

Durante il laboratorio dovremo quindi fornire il nome.

Le righe:

```bicep
@minLength(3)
@maxLength(24)
```

impongono dei vincoli sulla lunghezza.

La riga:

```bicep
@description(...)
```

aggiunge una descrizione.

Queste istruzioni che iniziano con `@` vengono chiamate **decorator**.

Per ora è sufficiente sapere che aggiungono informazioni o controlli a ciò che segue.

---

# 9. La riga più importante: dichiarare una risorsa Bicep

Ora arriviamo a:

```bicep
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
```

Questa riga contiene più informazioni.

La leggiamo lentamente.

## `resource`

```text
resource
→ sto dichiarando una risorsa Azure
```

## `storage`

```text
storage
→ è il nome simbolico che useremo dentro il file Bicep
```

È molto importante:

> `storage` non è necessariamente il nome reale dello Storage Account in Azure.

Serve a Bicep per riferirsi a questa risorsa all'interno del codice.

## `Microsoft.Storage/storageAccounts`

Questa parte identifica il tipo di risorsa Azure.

Possiamo scomporla:

```text
Microsoft.Storage
→ Resource Provider Azure

storageAccounts
→ tipo di risorsa gestita dal provider
```

## `@2023-05-01`

Questa parte indica la **versione dell'API Azure** usata per descrivere quella risorsa.

Non è:

```text
la data in cui creiamo lo Storage Account
```

e non è:

```text
la data del file Bicep
```

Possiamo pensarla come:

> la versione del contratto API che Bicep/Azure Resource Manager useranno per interpretare le proprietà di quel tipo di risorsa.

Quindi l'intera riga significa:

> dichiaro uno Storage Account Azure; nel file lo chiamerò simbolicamente `storage`; userò questa versione API per descriverlo.

---

# 10. Nome simbolico Bicep e nome reale Azure: non sono la stessa cosa

Subito dopo troviamo:

```bicep
name: storageName
```

Qui dobbiamo distinguere due concetti.

Nel codice abbiamo:

```text
storage
```

Questo è il **nome simbolico Bicep**.

Serve soltanto per riferirci alla risorsa nel file.

Poi abbiamo:

```text
storageName
```

Questo è un parametro.

Il suo valore conterrà il **nome reale dello Storage Account in Azure**.

Per esempio, durante il laboratorio potremmo avere:

```text
nome simbolico Bicep:
storage
```

e contemporaneamente:

```text
nome reale Azure:
stud12b12345678
```

Possiamo rappresentarlo così:

```text
CODICE BICEP

resource storage ...
         │
         │ nome simbolico interno
         ▼
      storage
         │
         │ name: storageName
         ▼
VALORE DEL PARAMETRO

stud12b12345678
         │
         ▼
AZURE

Storage Account reale:
stud12b12345678
```

Il nome simbolico serve al codice.

Il nome reale è quello che vedremo nel Portale Azure e con Azure CLI.

---

# 11. Le proprietà dello Storage Account Bicep

Nel blocco troviamo:

```bicep
location: location
```

La proprietà Azure `location` riceve il valore dal parametro Bicep chiamato anch'esso `location`.

Poi:

```bicep
sku: {
  name: 'Standard_LRS'
}
```

Stiamo dicendo:

> voglio uno Storage Account con ridondanza locale LRS.

Poi:

```bicep
kind: 'StorageV2'
```

indica il tipo generale di Storage Account.

Infine:

```bicep
properties: {
  allowBlobPublicAccess: false
  minimumTlsVersion: 'TLS1_2'
}
```

Qui stiamo dichiarando due proprietà di sicurezza:

```text
allowBlobPublicAccess: false
→ accesso Blob pubblico disabilitato

minimumTlsVersion: 'TLS1_2'
→ TLS minimo 1.2
```

Il punto importante è questo:

> non stiamo eseguendo quattro comandi separati.

Stiamo descrivendo in un unico blocco **come vogliamo che sia la risorsa**.

---

# 12. I tag sono parte della configurazione IaC

Il file contiene:

```bicep
tags: {
  Course: 'AZ104'
  UD: '12'
  ManagedBy: 'Bicep'
}
```

Quindi lo Storage Account verrà creato già con questi tag.

Il file descrive quindi insieme:

```text
tipo di risorsa
regione
ridondanza
proprietà di sicurezza
tag
```

Questo è uno dei vantaggi dell'IaC:

> la configurazione importante non resta dispersa in una sequenza di schermate del Portale.

Rimane nel codice versionabile.

---

# 13. Gli output Bicep

In fondo troviamo:

```bicep
output storageAccountName string = storage.name
output blobEndpoint string = storage.properties.primaryEndpoints.blob
```

Un **output** è un valore restituito dal deployment.

La prima riga significa:

> restituisci il nome reale della risorsa che nel codice abbiamo chiamato `storage`.

La seconda significa:

> restituisci l'endpoint Blob primario di quella stessa risorsa.

Notiamo qui perché il nome simbolico `storage` è utile.

Possiamo scrivere:

```bicep
storage.name
```

oppure:

```bicep
storage.properties.primaryEndpoints.blob
```

per riferirci alla risorsa dichiarata poco prima.

In una pipeline futura un output può diventare l'input di una fase successiva.

---

# 14. Il file Bicep da solo non crea nulla

Scrivere:

```text
main.bicep
```

non significa avere già creato lo Storage Account.

Serve un deployment.

Nel nostro laboratorio il percorso sarà:

```text
main.bicep
    ↓
Azure CLI
    ↓
Azure Resource Manager
    ↓
Microsoft.Storage
    ↓
Storage Account reale
```

Prima creeremo il Resource Group:

```text
rg-ud12-bicep
```

Poi distribuiremo dentro quel Resource Group il file Bicep.

---

# 15. `az bicep lint`: primo controllo sul file

Prima del deployment useremo:

```bash
az bicep lint --file main.bicep
```

Il lint serve a individuare problemi nel codice Bicep prima del deployment.

Possiamo pensare:

```text
ho scritto il file
        ↓
controllo il file
        ↓
solo dopo passo al deployment
```

Un lint riuscito non garantisce che Azure accetterà necessariamente ogni operazione.

Significa però che abbiamo superato un primo controllo sul codice.

---

# 16. What-If: chiedere ad Azure che cosa cambierebbe

Poi useremo:

```bash
az deployment group what-if ...
```

`what-if` si può leggere letteralmente come:

> cosa succederebbe se applicassi questo deployment?

Azure Resource Manager analizza ciò che esiste già e ciò che il template descrive.

Nel nostro caso ci aspettiamo una previsione simile a:

```text
Create
→ Microsoft.Storage/storageAccounts
```

Il punto fondamentale è:

```text
what-if
→ mostra modifiche previste
→ non è ancora il deployment reale
```

Questa è una buona abitudine professionale:

> prima osservare ciò che dovrebbe cambiare, poi applicare.

---

# 17. Deployment Bicep: quando Azure modifica davvero l'infrastruttura

Dopo What-If useremo:

```bash
az deployment group create ...
```

Qui passiamo dalla previsione all'azione.

```text
what-if
→ cosa succederebbe

create
→ esegui realmente il deployment
```

Dopo il deployment controlleremo anche con Azure CLI:

```text
nome
regione
SKU
TLS
accesso pubblico Blob
```

Questo è importante perché non dobbiamo limitarci a leggere:

```text
Deployment succeeded
```

Dobbiamo verificare che la risorsa reale corrisponda a ciò che abbiamo dichiarato.

---

# 18. Bicep e stato delle risorse

Con Bicep non dobbiamo gestire un file locale equivalente a:

```text
terraform.tfstate
```

Il deployment Bicep lavora attraverso Azure Resource Manager.

Lo stato reale delle risorse è mantenuto in Azure.

Quindi, in modo semplificato:

```text
codice Bicep
        ↓
Azure Resource Manager
        ↓
risorse Azure
```

Non abbiamo una terza componente locale che dobbiamo amministrare come state file.

Questo diventerà una differenza importante quando passeremo a Terraform.

---

# 19. Passiamo a Terraform: il problema rimane lo stesso

Ora cambiamo strumento.

Il nostro obiettivo resta:

```text
descrivere infrastruttura
controllare le modifiche
creare risorse
verificare il risultato
```

Con Terraform creeremo:

```text
Resource Group
+
Storage Account
```

Quindi Bicep e Terraform possono risolvere lo stesso problema.

Non sono però la stessa tecnologia.

Cambiano:

```text
linguaggio
architettura
modo di collegarsi alla piattaforma
gestione dello state
ecosistema
```

---

# 20. Terraform in parole semplici

Terraform è uno strumento Infrastructure as Code dichiarativo.

A differenza di Bicep non nasce esclusivamente per Azure.

Può lavorare con molte piattaforme grazie ai **provider**.

Nel nostro caso:

```text
Terraform
    ↓
provider AzureRM
    ↓
Azure
```

I file Terraform hanno normalmente estensione:

```text
.tf
```

Nel nostro laboratorio useremo:

```text
versions.tf
providers.tf
variables.tf
main.tf
outputs.tf
```

Terraform legge insieme i file `.tf` presenti nella stessa directory.

La separazione in più file serve soprattutto a rendere il progetto più ordinato e leggibile.

---

# 21. Perché esiste un provider Terraform

Facciamoci una domanda.

Come può Terraform sapere come creare:

```text
una VM Azure
uno Storage Account Azure
una risorsa AWS
un repository GitHub
una risorsa VMware
```

Terraform Core non contiene direttamente tutta la logica di tutte le piattaforme.

Usa invece dei **provider**.

Possiamo immaginare il provider come un adattatore specializzato:

```text
Terraform Core
      ↓
provider AzureRM
      ↓
Azure
```

Il provider AzureRM conosce tipi di risorsa come:

```text
azurerm_resource_group
azurerm_storage_account
```

Quindi:

> senza il provider AzureRM, Terraform non saprebbe come gestire quelle risorse Azure.

---

# 22. `versions.tf`: quali versioni servono

Il file contiene:

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

La prima parte:

```hcl
required_version = ">= 1.6.0"
```

significa:

> questa configurazione richiede Terraform 1.6.0 o successivo.

Poi troviamo:

```hcl
source = "hashicorp/azurerm"
```

Significa:

> il provider necessario è AzureRM del namespace HashiCorp.

Infine:

```hcl
version = "~> 5.4"
```

pone un vincolo sulla famiglia di versioni del provider usata dal laboratorio.

Per un neofita la cosa importante da ricordare è:

```text
versions.tf
→ dichiara quali componenti/versioni servono
```

---

# 23. `providers.tf`: attivare/configurare AzureRM

Il file contiene:

```hcl
provider "azurerm" {
  features {}
}
```

Possiamo leggerlo così:

> in questa configurazione useremo il provider AzureRM.

Il blocco:

```hcl
features {}
```

fa parte della configurazione richiesta dal provider AzureRM nel nostro scenario.

Non stiamo scrivendo password nel file.

Le credenziali e il contesto di autenticazione arrivano dall'ambiente in cui Terraform viene eseguito.

---

# 24. Codice e credenziali devono restare separati

Il codice Terraform descrive l'infrastruttura.

Non vogliamo inserire nel repository:

```text
password
secret personali
credenziali
token
```

Nel laboratorio useremo l'autenticazione Azure già preparata e imposteremo anche:

```bash
export ARM_SUBSCRIPTION_ID=$(az account show --query id --output tsv)
```

Possiamo quindi distinguere:

```text
FILE TERRAFORM
→ descrive infrastruttura

AMBIENTE DI ESECUZIONE
→ fornisce identità e contesto Azure
```

Questa distinzione sarà ancora più importante nelle pipeline.

---

# 25. `variables.tf`: valori configurabili

Consideriamo:

```hcl
variable "location" {
  description = "Regione Azure del laboratorio."
  type        = string
  default     = "westeurope"
}
```

La leggiamo così:

```text
variable
→ dichiaro un valore configurabile

location
→ nome della variabile

string
→ il valore deve essere testo

default = "westeurope"
→ se non ne fornisco un altro, usa westeurope
```

Poi abbiamo:

```hcl
variable "resource_group_name" {
  description = "Nome del Resource Group gestito da Terraform."
  type        = string
  default     = "rg-ud12-tf"
}
```

Quindi, se non specifichiamo un valore diverso:

```text
var.resource_group_name
```

avrà come valore:

```text
rg-ud12-tf
```

Questo passaggio sarà fondamentale tra poco.

---

# 26. Prima di leggere `main.tf`: distinguiamo quattro cose diverse

Prima di guardare il codice, fermiamoci.

Terraform usa spesso più nomi che possono sembrare simili.

Dobbiamo distinguere:

```text
1. tipo di risorsa Terraform
2. nome logico Terraform
3. variabile Terraform
4. nome reale della risorsa Azure
```

Useremo un Resource Group come esempio.

Nel codice troveremo:

```hcl
resource "azurerm_resource_group" "lab" {
  name = var.resource_group_name
}
```

Qui:

```text
azurerm_resource_group
→ tipo di risorsa Terraform
```

```text
lab
→ nome logico interno usato da Terraform
```

```text
var.resource_group_name
→ variabile da cui prendiamo il nome reale
```

La variabile ha valore predefinito:

```text
rg-ud12-tf
```

Quindi:

```text
rg-ud12-tf
→ nome reale che vedremo in Azure
```

Schema:

```text
CODICE TERRAFORM

resource "azurerm_resource_group" "lab"
          │                       │
          │                       └─ nome logico interno
          └─ tipo di risorsa

                      │
                      │ name = var.resource_group_name
                      ▼

VARIABILE

var.resource_group_name
                      │
                      ▼

VALORE

rg-ud12-tf
                      │
                      ▼

AZURE

Resource Group reale:
rg-ud12-tf
```

Questa distinzione è molto importante.

---

# 27. `main.tf`: dichiarare il Resource Group, riga per riga

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

Partiamo dalla prima riga:

```hcl
resource "azurerm_resource_group" "lab" {
```

Significa:

> sto dichiarando una risorsa di tipo `azurerm_resource_group` e, all'interno di questa configurazione Terraform, la chiamerò `lab`.

`lab` serve **solo come riferimento interno Terraform**.

Non significa che in Azure il Resource Group si chiamerà `lab`.

Ora leggiamo:

```hcl
name = var.resource_group_name
```

Questa riga risponde alla domanda:

> qual è il nome reale da creare in Azure?

Terraform prende il valore dalla variabile:

```text
resource_group_name
```

che in `variables.tf` ha:

```hcl
default = "rg-ud12-tf"
```

Quindi:

```text
nome logico Terraform:
lab

nome reale Azure:
rg-ud12-tf
```

La relazione completa è:

```text
azurerm_resource_group.lab
        │
        │ riferimento interno Terraform
        ▼
name = var.resource_group_name
        │
        ▼
var.resource_group_name
        │
        ▼
"rg-ud12-tf"
        │
        ▼
Resource Group Azure reale:
rg-ud12-tf
```

Ora leggiamo:

```hcl
location = var.location
```

Anche qui Terraform non inventa il valore.

Legge:

```text
var.location
```

che, se non viene sovrascritta, vale:

```text
westeurope
```

Infine i tag:

```hcl
tags = {
  Course    = "AZ104"
  UD        = "12"
  ManagedBy = "Terraform"
}
```

saranno applicati al Resource Group reale.

---

# 28. Perché abbiamo bisogno del nome logico `lab`

A questo punto potremmo chiederci:

> se il Resource Group reale si chiama `rg-ud12-tf`, perché Terraform ha bisogno anche del nome `lab`?

Perché gli altri blocchi Terraform devono poter dire:

> voglio usare proprio quella risorsa che ho dichiarato sopra.

Terraform la identifica internamente come:

```text
azurerm_resource_group.lab
```

Questa espressione è composta da:

```text
azurerm_resource_group
→ tipo della risorsa

lab
→ nome logico assegnato nel codice
```

Più avanti potremo scrivere:

```hcl
azurerm_resource_group.lab.name
```

che significa:

> prendi la risorsa Terraform `azurerm_resource_group.lab` e leggine la proprietà `name`.

Il risultato sarà:

```text
rg-ud12-tf
```

Analogamente:

```hcl
azurerm_resource_group.lab.location
```

restituirà:

```text
westeurope
```

Questo è il vero motivo per cui `lab` esiste.

---

# 29. `main.tf`: dichiarare lo Storage Account

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

Partiamo da:

```hcl
resource "azurerm_storage_account" "lab" {
```

Significa:

```text
azurerm_storage_account
→ tipo di risorsa Terraform

lab
→ nome logico interno Terraform
```

Anche qui `lab` non sarà il nome reale dello Storage Account.

Il nome reale arriva da:

```hcl
name = var.storage_account_name
```

Durante il LAB forniremo quel valore tramite:

```bash
export TF_VAR_storage_account_name="..."
```

Quindi:

```text
azurerm_storage_account.lab
→ riferimento interno Terraform

var.storage_account_name
→ valore usato come nome reale Azure
```

---

# 30. La relazione tra Storage Account e Resource Group

Ora arriviamo alle righe:

```hcl
resource_group_name = azurerm_resource_group.lab.name
location            = azurerm_resource_group.lab.location
```

Queste righe sono fondamentali.

La prima significa:

> per il campo `resource_group_name` dello Storage Account, usa il nome del Resource Group Terraform che abbiamo dichiarato come `azurerm_resource_group.lab`.

Vediamola a pezzi:

```text
azurerm_resource_group
→ tipo della risorsa a cui ci riferiamo

.lab
→ nome logico di quella risorsa

.name
→ proprietà che vogliamo leggere
```

Quindi:

```hcl
azurerm_resource_group.lab.name
```

produce:

```text
rg-ud12-tf
```

La seconda riga:

```hcl
azurerm_resource_group.lab.location
```

produce invece:

```text
westeurope
```

Schema:

```text
azurerm_resource_group.lab
        │
        ├── .name
        │      ↓
        │   rg-ud12-tf
        │      ↓
        │   Storage Account
        │   resource_group_name
        │
        └── .location
               ↓
            westeurope
               ↓
            Storage Account
            location
```

In questo modo Terraform comprende anche una relazione fra le due risorse.

Prima deve esistere il Resource Group.

Poi può essere creato lo Storage Account dentro quel Resource Group.

Non dobbiamo scrivere manualmente:

```text
crea prima il Resource Group
poi crea lo Storage
```

Terraform deduce la dipendenza dal riferimento.

---

# 31. Le altre proprietà dello Storage Account Terraform

Nel blocco troviamo:

```hcl
account_tier = "Standard"
```

e:

```hcl
account_replication_type = "LRS"
```

Quindi stiamo chiedendo:

```text
tier
→ Standard

ridondanza
→ LRS
```

Poi:

```hcl
min_tls_version = "TLS1_2"
```

significa:

```text
TLS minimo
→ 1.2
```

e:

```hcl
allow_nested_items_to_be_public = false
```

serve a impedire l'accesso pubblico agli elementi del servizio Storage secondo la configurazione prevista dal provider.

Anche i tag fanno parte della dichiarazione Terraform.

---

# 32. La variabile `storage_account_name` e la validazione

In `variables.tf` troviamo:

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

Non serve memorizzare subito tutta la sintassi.

Serve capire lo scopo.

Prima di usare il valore, Terraform controlla che:

```text
sia lungo almeno 3 caratteri
sia lungo al massimo 24 caratteri
contenga soltanto lettere minuscole e numeri
```

Nel LAB forniremo il valore tramite:

```bash
export TF_VAR_storage_account_name="..."
```

Il prefisso:

```text
TF_VAR_
```

dice a Terraform:

> questo valore deve essere associato a una variabile della configurazione.

---

# 33. `outputs.tf`: leggere valori dalle risorse gestite

Il file contiene:

```hcl
output "resource_group_name" {
  description = "Resource Group creato da Terraform."
  value       = azurerm_resource_group.lab.name
}
```

Qui Terraform restituisce il nome reale del Resource Group.

Abbiamo già visto che:

```hcl
azurerm_resource_group.lab.name
```

significa:

```text
prendi il Resource Group logico "lab"
e leggine la proprietà "name"
```

Quindi l'output sarà:

```text
rg-ud12-tf
```

Poi:

```hcl
output "storage_account_name" {
  description = "Storage Account creato da Terraform."
  value       = azurerm_storage_account.lab.name
}
```

restituirà il nome reale dello Storage Account.

Gli output sono quindi un modo per esporre valori utili dopo l'esecuzione.

---

# 34. Il ciclo Terraform: prima vediamo l'ordine generale

Prima di eseguire comandi, osserviamo il flusso completo:

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
leggiamo il piano
   ↓
terraform apply
   ↓
terraform output
   ↓
verifica con Azure CLI
```

Ogni comando ha uno scopo diverso.

Non dobbiamo imparare questa sequenza come una formula senza significato.

Vediamola un passo alla volta.

---

# 35. `terraform init`: preparare la directory

Il comando:

```bash
terraform init
```

prepara la directory Terraform.

Fra le altre cose:

```text
legge i provider richiesti
scarica AzureRM se necessario
prepara la directory .terraform/
crea o aggiorna .terraform.lock.hcl
```

Possiamo leggerlo così:

> ho i file `.tf`; ora preparo l'ambiente locale necessario a interpretarli ed eseguirli.

`init` non crea ancora il Resource Group e non crea ancora lo Storage Account.

---

# 36. `.terraform/` e `.terraform.lock.hcl` non sono la stessa cosa

Dopo `init` vedremo elementi nuovi.

La directory:

```text
.terraform/
```

contiene file locali scaricati e preparati da Terraform.

Non è normale codice sorgente.

Il file:

```text
.terraform.lock.hcl
```

registra invece informazioni sulle versioni effettivamente selezionate dei provider.

Quindi:

```text
.terraform/
→ materiale locale di lavoro

.terraform.lock.hcl
→ lock file delle dipendenze/provider
```

Sono due cose differenti.

---

# 37. `terraform fmt`: uniformare il formato

Il comando:

```bash
terraform fmt
```

formatta i file HCL secondo lo stile standard Terraform.

Non crea risorse Azure.

Serve a rendere il codice più uniforme e leggibile.

Con:

```bash
terraform fmt -check
```

possiamo controllare se il codice è già formattato correttamente senza modificarlo.

Questo controllo è utile anche nelle pipeline CI.

---

# 38. `terraform validate`: controllare la configurazione

Il comando:

```bash
terraform validate
```

controlla che la configurazione sia sintatticamente valida e internamente coerente.

Non significa ancora:

```text
Azure ha creato le risorse
```

e non significa nemmeno:

```text
ogni operazione Azure riuscirà sicuramente
```

Significa:

> Terraform ha analizzato la configurazione e non ha trovato errori di validazione in questa fase.

---

# 39. `terraform plan`: vedere ciò che Terraform intende fare

Ora arriviamo a:

```bash
terraform plan
```

Terraform deve confrontare:

```text
configurazione desiderata
state conosciuto
informazioni lette tramite il provider
```

e determinare:

```text
cosa creare
cosa modificare
cosa eliminare
```

Nel primo LAB ci aspettiamo qualcosa simile a:

```text
Plan: 2 to add, 0 to change, 0 to destroy
```

Perché?

Perché stiamo chiedendo di creare:

```text
1 Resource Group
1 Storage Account
```

Il comportamento corretto è:

```text
plan
→ leggo
→ verifico
→ solo dopo apply
```

Non:

```text
apply subito
→ poi vediamo cosa succede
```

---

# 40. Perché salviamo il piano

Nel laboratorio useremo:

```bash
terraform plan -out=ud12.tfplan
```

In questo modo il piano viene salvato.

Poi useremo:

```bash
terraform apply ud12.tfplan
```

Quindi:

```text
genero un piano
        ↓
lo controllo
        ↓
applico esattamente quel piano
```

Questo rende più chiaro il passaggio fra:

```text
previsione
```

e:

```text
azione reale
```

---

# 41. `terraform apply`: modificare realmente Azure

Quando eseguiamo:

```bash
terraform apply ud12.tfplan
```

Terraform passa dalla previsione all'azione.

Possiamo ricordare:

```text
plan
→ cosa intendo fare

apply
→ eseguo realmente
```

Dopo l'apply useremo:

```bash
terraform output
```

e anche Azure CLI.

Questo ci permette di verificare il risultato da due punti di vista.

---

# 42. La domanda che introduce lo State

Ora arriviamo al concetto più nuovo di Terraform.

Immaginiamo che oggi Terraform crei:

```text
Storage Account reale:
stud12t12345678
```

Nel codice però la risorsa si chiama:

```text
azurerm_storage_account.lab
```

Domani modifichiamo `main.tf`.

Come fa Terraform a ricordare che:

```text
azurerm_storage_account.lab
```

corrisponde proprio a:

```text
stud12t12345678
```

in Azure?

Terraform deve mantenere una relazione tra:

```text
oggetto dichiarato nel codice
```

e:

```text
oggetto reale che sta gestendo
```

Questa è una funzione fondamentale dello **state**.

---

# 43. State Terraform: esempio concreto

Nel nostro laboratorio useremo state locale:

```text
terraform.tfstate
```

Possiamo immaginare:

```text
CODICE TERRAFORM

azurerm_storage_account.lab
            │
            ▼

STATE

terraform.tfstate
            │
            ▼

AZURE

stud12t12345678
```

Lo state contiene informazioni che aiutano Terraform a mantenere il collegamento tra gli oggetti della configurazione e le risorse remote.

Terraform usa insieme:

```text
configurazione
state
provider
```

per determinare le modifiche da proporre.

Lo state non è quindi un semplice file di log.

---

# 44. Perché lo State va gestito con attenzione

Lo state può contenere:

```text
identificativi di risorse
proprietà
metadati
anche valori sensibili in alcuni casi
```

Quindi non dobbiamo pensare:

> è un file del progetto, quindi lo committo automaticamente.

Nella UD12 useremo state locale perché ciascun partecipante lavora individualmente.

Più avanti parleremo di **remote state**, che serve quando il lavoro diventa condiviso.

Per ora ricordiamo:

```text
file .tf
→ codice sorgente IaC
→ normalmente versionato

terraform.tfstate
→ stato operativo Terraform
→ da proteggere e gestire con attenzione
```

---

# 45. `terraform state list`: che cosa ci mostra davvero

Dopo `apply` useremo:

```bash
terraform state list
```

Ci aspettiamo:

```text
azurerm_resource_group.lab
azurerm_storage_account.lab
```

Attenzione:

questo comando **non** sta elencando tutte le risorse della Subscription Azure.

Sta mostrando:

> gli oggetti che questa configurazione Terraform sta gestendo attraverso il proprio state.

È una differenza fondamentale.

---

# 46. `terraform destroy`: elimina le risorse, non il codice

Più avanti useremo:

```bash
terraform destroy
```

Terraform calcola quali risorse gestite devono essere eliminate e, dopo conferma, le rimuove.

Ma non cancella automaticamente:

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
codice IaC ancora presente nel repository
```

Questo è esattamente ciò che vogliamo.

---

# 47. Bicep e Terraform: stessa esigenza, due percorsi

Ora possiamo confrontare i due strumenti usando lo stesso obiettivo.

Supponiamo di voler creare uno Storage Account.

## Bicep

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

Percorso:

```text
Bicep
   ↓
Azure Resource Manager
   ↓
Azure Resource Provider
   ↓
Storage Account
```

## Terraform

```hcl
resource "azurerm_storage_account" "lab" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

Percorso:

```text
Terraform
   ↓
provider AzureRM
   ↓
Azure
   ↓
Storage Account
```

L'obiettivo può essere identico.

Il meccanismo è diverso.

---

# 48. Bicep vs Terraform: confronto spiegato

| Aspetto | Bicep | Terraform |
|---|---|---|
| Ambito principale | Azure | Multipiattaforma |
| Linguaggio | Bicep | HCL |
| Collegamento ad Azure | Azure Resource Manager | Provider AzureRM |
| Anteprima modifiche | What-If | `terraform plan` |
| Applicazione modifiche | deployment ARM/Bicep | `terraform apply` |
| State locale Terraform-like | No | Sì |
| Provider | non è il modello principale | componente centrale |
| Moduli | sì | sì |
| Uso in Git/pipeline | sì | sì |

Ma questa tabella ha senso solo se abbiamo capito **perché**.

## Bicep

Bicep è molto vicino al modello Azure Resource Manager.

Quindi, se l'organizzazione lavora soprattutto su Azure, può risultare molto naturale.

## Terraform

Terraform è stato progettato per lavorare con più piattaforme tramite provider.

Quindi può essere particolarmente utile quando l'organizzazione vuole usare uno stesso approccio IaC per sistemi differenti.

---

# 49. Tre casi aziendali per capire la scelta

## Caso A — azienda quasi interamente Azure

L'azienda usa:

```text
Azure
Entra ID
Azure Resource Manager
Azure DevOps
```

Bicep può essere una scelta naturale perché è fortemente integrato nell'ecosistema Azure.

## Caso B — azienda con più piattaforme

L'azienda usa:

```text
Azure
AWS
GitHub
Cloudflare
VMware
```

Terraform può essere molto interessante perché usa provider differenti mantenendo un modello comune.

## Caso C — azienda Azure ma già standardizzata su Terraform

L'azienda usa solo o quasi solo Azure, ma ha già:

```text
moduli Terraform
pipeline Terraform
remote state
regole interne
competenze consolidate del team
```

In questo caso usare Terraform può essere perfettamente sensato.

Quindi la domanda corretta non è:

> qual è il migliore?

Ma:

> quale strumento è più adatto agli standard, alle piattaforme e alle competenze dell'organizzazione?

---

# 50. La differenza più importante: gestione dello state

## Bicep

In modo semplificato:

```text
file Bicep
   ↓
Azure Resource Manager
   ↓
risorse Azure
```

Non dobbiamo amministrare un file locale equivalente a `terraform.tfstate`.

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
risorse remote
```

Terraform mantiene lo state per collegare gli oggetti dichiarati alle risorse reali gestite.

Per questo lo state introduce una responsabilità operativa in più.

---

# 51. What-If e Plan: simili nello scopo, diversi nel meccanismo

Per un neofita è utile collegarli.

```text
Bicep / ARM
What-If
→ quali modifiche prevede Azure Resource Manager?
```

```text
Terraform
plan
→ quali modifiche prevede Terraform?
```

Entrambi rafforzano la stessa buona abitudine:

> controllare il cambiamento previsto prima di applicarlo.

Ma non sono lo stesso meccanismo.

What-If appartiene ad Azure Resource Manager.

Plan appartiene al modello Terraform e lavora con configurazione, state e provider.

---

# 52. IaC e Git: perché il codice deve restare nel repository

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

Questi file non sono materiale usa-e-getta.

Sono parte del repository del partecipante.

Le modifiche future potranno seguire un processo simile a quello del codice applicativo:

```text
branch
   ↓
modifica IaC
   ↓
git diff
   ↓
commit
   ↓
Pull Request
   ↓
pipeline
```

Questo collega:

```text
Git
+
Infrastructure as Code
+
DevOps
```

---

# 53. Importante: cosa conserviamo alla fine della UD12

Alla fine della giornata **non dobbiamo confondere le risorse Azure temporanee con i file IaC**.

Le risorse di laboratorio possono essere eliminate quando non servono più.

Il codice invece deve rimanere nel repository personale.

Quindi conserveremo:

```text
~/workspace/azure-devops-lab/infra/bicep/
~/workspace/azure-devops-lab/infra/terraform/
```

Nelle UD successive queste directory **non verranno ricreate da zero**.

Saranno invece estese con nuovi file e nuove configurazioni.

Per esempio:

```text
UD12
infra/terraform/
├── versions.tf
├── providers.tf
├── variables.tf
├── main.tf
└── outputs.tf

UD13
infra/terraform/
├── versions.tf
├── providers.tf
├── variables.tf
├── main.tf
├── outputs.tf
└── network.tf
```

Quindi:

```text
risorse Azure temporanee
→ possono essere eliminate

codice IaC nel repository
→ deve essere conservato
→ verrà riutilizzato
```

---

# 54. Dal terminale alla pipeline: chi eseguirà questi comandi in futuro?

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

Nelle UD successive alcuni di questi comandi verranno eseguiti da Azure Pipelines.

Ma una pipeline non esegue i comandi “nel vuoto”.

Il percorso è:

```text
Pipeline
   ↓
Job
   ↓
Agent
   ↓
programma installato sull'Agent
```

Quindi:

```text
Terraform deve essere disponibile sull'Agent
Azure CLI deve essere disponibile sull'Agent
Bicep deve essere disponibile sull'Agent
```

---

# 55. Self-hosted Agent: il nostro WSL2 è un laboratorio, non il modello aziendale finale

Nel corso il self-hosted Agent è installato nel WSL2 del partecipante.

Quindi:

```text
pool-ud09-wsl
       ↓
Agent
       ↓
WSL2 personale
```

Questo è il nostro modello didattico.

In azienda avremmo più probabilmente:

```text
pool-linux-build
├── build-agent-01
├── build-agent-02
└── build-agent-03
```

La regola importante è:

```text
self-hosted
≠ PC personale dello sviluppatore
```

ma:

```text
self-hosted
= infrastruttura Agent gestita dall'organizzazione
```

Installare Terraform nel nostro WSL2 significa quindi simulare la preparazione della toolchain di un vero build host aziendale.

---

# 56. Self-hosted e persistenza dei tool

Un self-hosted Agent usa una macchina persistente.

Se installiamo:

```text
Terraform
Azure CLI
Bicep
Docker
Python
```

questi strumenti rimangono sulla macchina finché non vengono rimossi o l'ambiente non viene ricreato.

Questo è comodo, ma comporta responsabilità:

```text
versioni
aggiornamenti
PATH
dipendenze
sicurezza
```

Per questo, in azienda, la toolchain del build server deve essere governata.

---

# 57. Microsoft-hosted Agent: ogni Job parte da un ambiente nuovo

Con un Microsoft-hosted Agent potremo avere:

```yaml
pool:
  vmImage: ubuntu-latest
```

In questo modello Azure Pipelines assegna al Job una macchina preparata da Microsoft.

La macchina è temporanea.

Quindi, semplificando:

```text
Job A
→ macchina temporanea A

Job B
→ nuova macchina temporanea B
```

Non possiamo fare affidamento su file o installazioni lasciati da un Job precedente.

Per questo una pipeline deve verificare o preparare gli strumenti che le servono.

---

# 58. Gate 2: che cosa vogliamo verificare a fine UD12

A fine UD12 vogliamo essere pronti per le pipeline successive.

Sul self-hosted dobbiamo verificare che siano realmente disponibili:

```text
Azure CLI
Bicep
Terraform
```

insieme agli strumenti preparati nelle UD precedenti.

Il Gate 2 quindi non è un nuovo argomento.

È un controllo di readiness:

> il nostro ambiente è pronto per eseguire in futuro questi strumenti dentro una pipeline?

---

# 59. Cleanup: codice e infrastruttura hanno lifecycle differenti

Durante la UD creeremo risorse Azure temporanee.

Queste potranno essere eliminate quando tutte le attività che le usano saranno terminate.

Il codice IaC invece rimane.

Quindi:

```text
RISORSE AZURE LAB
→ lifecycle temporaneo

CODICE IaC
→ lifecycle più lungo
→ resta nel repository
→ viene riutilizzato nelle UD successive
```

Questa distinzione è uno dei concetti più importanti dell'Infrastructure as Code.

---

# 60. Mappa diretta: concetto studiato → attività del LAB

| Concetto | Cosa farai nel LAB |
|---|---|
| parametro Bicep | fornirai `storageName` e userai `location` |
| `resource` Bicep | leggerai lo Storage Account dichiarato |
| API version Bicep | riconoscerai `@2023-05-01` |
| lint | eseguirai `az bicep lint` |
| What-If | controllerai le modifiche previste |
| deployment | eseguirai `az deployment group create` |
| output Bicep | leggerai nome ed endpoint |
| provider Terraform | `terraform init` preparerà AzureRM |
| variabili | userai `TF_VAR_storage_account_name` |
| nome logico Terraform | riconoscerai `azurerm_resource_group.lab` |
| nome reale Azure | vedrai `rg-ud12-tf` nel Portale/CLI |
| riferimenti fra risorse | lo Storage userà `.name` e `.location` del RG |
| fmt | controllerai la formattazione |
| validate | controllerai la configurazione |
| plan | leggerai le modifiche prima di applicarle |
| apply | creerai realmente RG e Storage |
| output Terraform | leggerai i valori prodotti |
| state | userai `terraform state list` |
| Agent readiness | eseguirai il Gate 2 |

---

# 61. Prima del LAB: prova a raccontare Bicep con parole tue

Una risposta corretta potrebbe essere:

> Ho un file Bicep che descrive uno Storage Account Azure. Il file contiene parametri, una risorsa e degli output. Prima controllo il file con `az bicep lint`. Poi uso What-If per vedere quali modifiche Azure prevede. Se il risultato è corretto, eseguo il deployment reale. Infine verifico con Azure CLI che la risorsa creata corrisponda alla dichiarazione.

Se questa frase ti è chiara, la parte Bicep del laboratorio non dovrebbe sembrarti un argomento nuovo.

---

# 62. Prima del LAB: prova a raccontare Terraform con parole tue

Una risposta corretta potrebbe essere:

> Ho una configurazione Terraform composta da più file `.tf`. Terraform utilizza il provider AzureRM per gestire risorse Azure. Le variabili contengono valori configurabili. In `main.tf` dichiaro un Resource Group e uno Storage Account. I nomi logici come `lab` servono a Terraform per riferirsi internamente alle risorse, mentre i nomi reali Azure arrivano da variabili o proprietà. Prima eseguo `init`, poi `fmt` e `validate`. Con `plan` vedo cosa Terraform intende fare e solo dopo uso `apply`. Terraform mantiene inoltre uno state per collegare gli oggetti dichiarati alle risorse reali gestite.

Se questa frase ha senso, sei pronto per il laboratorio Terraform.

---

# 63. Domande di controllo

1. Quale problema risolve l'Infrastructure as Code rispetto a una configurazione esclusivamente manuale?
2. Spiega con parole semplici la differenza tra approccio imperativo e dichiarativo.
3. Perché continuiamo a usare Azure CLI anche se introduciamo IaC?
4. Che cos'è Bicep?
5. Bicep sostituisce Azure Resource Manager?
6. Che cosa significa `param location string`?
7. A cosa serve un parametro?
8. A cosa servono `@minLength` e `@maxLength`?
9. Nella riga `resource storage 'Microsoft.Storage/storageAccounts@2023-05-01'`, che cosa significa `storage`?
10. Che cosa significa `Microsoft.Storage/storageAccounts`?
11. Che cosa significa `@2023-05-01`?
12. È la data di creazione dello Storage Account?
13. Qual è la differenza tra nome simbolico Bicep e nome reale Azure?
14. A cosa servono gli output Bicep?
15. Che cosa fa `az bicep lint`?
16. Che cosa fa What-If?
17. What-If crea realmente le risorse?
18. Qual è la differenza tra What-If e deployment `create`?
19. Perché Bicep non richiede un file equivalente a `terraform.tfstate`?
20. Che cos'è Terraform?
21. Perché Terraform usa provider?
22. Che ruolo ha AzureRM?
23. Che cosa contiene `versions.tf`?
24. A cosa serve `providers.tf`?
25. Perché credenziali e codice IaC devono restare separati?
26. Che cosa contiene `variables.tf`?
27. Che differenza c'è tra `azurerm_resource_group`, `lab`, `var.resource_group_name` e `rg-ud12-tf`?
28. Nella riga `resource "azurerm_resource_group" "lab"`, che cos'è `lab`?
29. Il Resource Group reale si chiamerà `lab`?
30. Da dove arriva il nome reale `rg-ud12-tf`?
31. Che cosa significa `azurerm_resource_group.lab.name`?
32. Perché lo Storage Account usa `azurerm_resource_group.lab.name`?
33. Che cosa significa `azurerm_resource_group.lab.location`?
34. Perché Terraform può dedurre la dipendenza fra Resource Group e Storage Account?
35. A cosa serve la validazione di `storage_account_name`?
36. A cosa servono gli output Terraform?
37. Che cosa fa `terraform init`?
38. Che differenza c'è tra `.terraform/` e `.terraform.lock.hcl`?
39. Che cosa fa `terraform fmt`?
40. Che cosa fa `terraform validate`?
41. Che cosa fa `terraform plan`?
42. Perché il piano va letto prima dell'apply?
43. Perché nel LAB salviamo il piano in `ud12.tfplan`?
44. Che cosa fa `terraform apply`?
45. Che cos'è lo state Terraform?
46. Quale relazione mantiene lo state?
47. Perché `terraform.tfstate` non va trattato come normale codice sorgente?
48. Che cosa mostra `terraform state list`?
49. `terraform state list` mostra tutte le risorse della Subscription?
50. `terraform destroy` elimina anche i file `.tf`?
51. Qual è la differenza principale nel percorso Bicep→Azure rispetto a Terraform→Azure?
52. In che cosa What-If e Plan sono simili?
53. Perché non sono lo stesso meccanismo?
54. In quale tipo di organizzazione Bicep può essere particolarmente naturale?
55. In quale tipo di organizzazione Terraform può essere particolarmente naturale?
56. Perché non ha senso dire in assoluto che uno dei due è sempre migliore?
57. Perché i file IaC devono rimanere nel repository?
58. Le directory `infra/bicep/` e `infra/terraform/` verranno ricreate da zero in UD13?
59. Perché installare Terraform nel WSL2 è utile per le UD successive?
60. Su quale componente vengono realmente eseguiti i comandi di una pipeline?
61. Che cosa rappresenta il WSL2 del partecipante nel modello self-hosted?
62. Qual è la differenza principale fra persistenza self-hosted e ambiente Microsoft-hosted?
63. Perché eliminare le risorse Azure non significa eliminare il codice IaC?
