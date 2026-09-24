# UD13 — Concetti
## Da Terraform individuale alla prima pipeline IaC

UD12 ci ha mostrato il ciclo IaC su una singola postazione:

```text
codice
→ validate
→ plan
→ apply
→ state locale
```

Ora dobbiamo affrontare una domanda professionale diversa:

```text
che cosa cambia quando la stessa configurazione
deve essere controllata da un processo condiviso?
```

Questo è il passaggio che porta dalle attività manuali del singolo amministratore alla pipeline.

---

# 1. Perché lo state locale diventa un problema

In UD12 lo state locale era appropriato perché:

- ogni partecipante lavorava da solo;
- le risorse erano temporanee;
- non esistevano esecuzioni concorrenti.

In un team, però, uno state salvato soltanto sul computer di una persona introduce rischi:

```text
chi possiede lo state corretto?
due persone possono applicare modifiche contemporaneamente?
come si evita di sovrascrivere lo state?
come viene protetto?
```

Per questo, nei progetti collaborativi si usa normalmente uno **state remoto** con meccanismi di protezione e locking.

In UD13 non configureremo ancora il backend remoto completo: si richiede soltanto di comprenderne il motivo. La pipeline Terraform di questa UD farà quindi:

```text
fmt
init senza backend
validate
```

ma non farà `terraform apply`.

Il primo deployment IaC automatizzato rimane Bicep.

---

# 2. Dipendenze Terraform

In Terraform una dipendenza può essere implicita.

Esempio:

```hcl
resource_group_name = azurerm_resource_group.lab.name
```

Terraform capisce che la risorsa che usa quel valore dipende dal Resource Group.

Questo consente al grafo delle dipendenze di determinare l'ordine di esecuzione.

Aggiungendo una VNet e una subnet vedremo una catena come:

```text
Resource Group
    ↓
Virtual Network
    ↓
Subnet
```

La configurazione rimane dichiarativa: non stiamo scrivendo un programma che dice "prima crea A, poi B".

---

# 3. Separare file e responsabilità

Una configurazione Terraform reale viene spesso separata in più file:

```text
versions.tf
providers.tf
variables.tf
main.tf
network.tf
outputs.tf
```

Terraform legge tutti i file `.tf` della stessa directory come un'unica configurazione.

La separazione serve alle persone:

```text
network.tf
→ rete

variables.tf
→ input

outputs.tf
→ informazioni esportate
```

Non crea moduli automaticamente.

---

# 4. State remoto: concetto, non implementazione adesso

Un backend remoto permette di conservare lo state in una posizione condivisa.

Su Azure una scelta comune è Azure Storage.

Il concetto è:

```text
Terraform
   ↓
backend remoto
   ↓
state condiviso/protetto
```

Ma introdurre:

- storage dedicato;
- accessi;
- autenticazione;
- locking;
- bootstrap;
- protezione del dato;

richiede tempo e attenzione.

in questa UD13 manterremo lo state remoto a livello concettuale e Terraform in pipeline **solo per la validazione**.

---

# 5. Pipeline as Code

Azure Pipelines può essere descritta in YAML.

Un file pipeline diventa quindi un altro elemento versionabile del repository.

Esempio concettuale:

```yaml
stages:
- stage: Validate
  jobs:
  - job: IaC
    steps:
    - script: terraform validate
```

La pipeline non è un elenco di click salvato nel Portale: il flusso diventa parte del codice.

---

# 6. Stage, Job e Step

La gerarchia fondamentale è:

```text
Pipeline
└── Stage
    └── Job
        └── Step
```

## Stage

Raggruppa una fase logica, per esempio:

```text
Validate
Deploy
Test
```

## Job

È un insieme di step eseguito da un agent.

## Step

È una singola operazione:

```text
checkout
script
task
```

Quando una pipeline fallisce dobbiamo capire **a quale livello** è avvenuto il problema.

---

# 7. Agent, Pool e scelta dell'ambiente di esecuzione

Il Job deve sapere **dove** essere eseguito.

In UD13 scegliamo volutamente il self-hosted Agent preparato nelle UD09–UD12:

```yaml
pool:
  name: pool-ud09-wsl
```

La catena reale diventa:

```text
Azure Pipelines
        ↓
Job
        ↓
pool-ud09-wsl
        ↓
self-hosted Agent
        ↓
Ubuntu / WSL2 del partecipante
        ↓
terraform / az / Bicep
```

Questa è la **prima pipeline reale del percorso** e vogliamo rendere visibile il legame tra:

```text
tool installato nel WSL2
        ↓
capability/PATH dell'Agent
        ↓
comando eseguito dal Job
```

Per questo UD13 usa il self-hosted come prima esperienza operativa.

## Che cosa cambierebbe con Microsoft-hosted

Un Job Microsoft-hosted potrebbe invece usare, per esempio:

```yaml
pool:
  vmImage: ubuntu-latest
```

In quel caso Azure Pipelines assegnerebbe una macchina virtuale nuova al Job.

La logica della pipeline rimarrebbe simile:

```text
checkout
→ terraform
→ Bicep
→ Azure
```

ma cambierebbe l'ambiente di esecuzione.

Con il self-hosted:

```text
tool e filesystem
→ persistono sulla nostra macchina
```

Con il Microsoft-hosted:

```text
ogni Job
→ nuova VM
→ ambiente temporaneo
```

UD14 sarà il punto naturale per utilizzare anche il Microsoft-hosted, se lo stato preparato in UD09 è `READY`.

---

## Come leggere `pool-ud09-wsl` in un team reale

Nel laboratorio:

```text
pool-ud09-wsl
→ un Agent
→ WSL2 del partecipante
```

In produzione:

```text
pool-linux-build
├── build-agent-01
├── build-agent-02
└── build-agent-03
```

Il YAML:

```yaml
pool:
  name: pool-linux-build
```

identifica il gruppo di esecutori ammessi, non un singolo computer.

Azure DevOps assegna il Job a un Agent disponibile del Pool che soddisfa eventuali capability/demands.

Il WSL2 personale simula quindi **uno dei nodi del Pool**.

### Concorrenza

Ogni Agent esegue un Job alla volta.

Tre Agent consentono potenzialmente più Job contemporanei, ma il parallelismo reale dipende anche dalla capacità di Parallel Jobs dell'organizzazione.

# 8. Persistenza del self-hosted e workspace pulito

La persistenza del self-hosted è utile, ma può anche nascondere errori.

Esempio:

```text
una vecchia directory
un file generato ieri
una cache
un checkout precedente
```

potrebbero far sembrare corretta una pipeline che in realtà dipende da residui locali.

Per evitare questo comportamento, nei Job UD13 useremo:

```yaml
workspace:
  clean: all
```

Questo chiede all'Agent self-hosted di pulire l'intero `Pipeline.Workspace` prima del Job.

Continueremo anche a usare:

```yaml
- checkout: self
  clean: true
```

Le due istruzioni non sono identiche:

```text
workspace clean
→ pulisce l'area di lavoro del Job sull'Agent

checkout clean
→ pulisce la copia Git del repository prima del fetch
```

Il risultato didattico è importante:

> **la pipeline deve funzionare perché contiene tutto ciò che le serve, non perché trova per caso file rimasti sul self-hosted Agent.**

Con Microsoft-hosted questo problema è molto meno rilevante, perché ogni Job riceve già una macchina nuova.

---

# 9. Variabili dell'Agent e directory di checkout

Durante il primo Job stamperemo alcune informazioni:

```text
$(Agent.Name)
$(Agent.OS)
$(Build.SourcesDirectory)
```

Queste sono **variabili predefinite di Azure Pipelines**.

Permettono alla pipeline di conoscere informazioni dell'ambiente senza hardcodificare percorsi personali.

Non useremo quindi:

```text
~/workspace/azure-devops-lab
```

dentro la pipeline.

Useremo il repository che Azure Pipelines ha effettuato in checkout.

---

# 10. Checkout

In una pipeline GitHub collegata ad Azure DevOps:

```yaml
- checkout: self
```

significa:

```text
recupera il repository che contiene la pipeline
```

Il repository viene collocato nell'area di lavoro dell'agent.

Per questo nei comandi pipeline useremo percorsi relativi al repository:

```text
infra/terraform
infra/bicep
app/...
```

e non:

```text
~/workspace/azure-devops-lab
```

Il percorso personale appartiene al lavoro interattivo; `$(Build.SourcesDirectory)` appartiene all'esecuzione pipeline.

---

## GitHub App: la prima connessione della pipeline al repository

UD13 è la prima UD in cui Azure Pipelines deve realmente leggere il repository GitHub.

In UD09 avevamo deliberatamente **non creato** una connessione GitHub OAuth/PAT anticipata.

Quando creeremo la pipeline e selezioneremo:

```text
GitHub
```

Azure DevOps utilizzerà come metodo preferito la **Azure Pipelines GitHub App**.

La relazione è:

```text
GitHub repository
        ↓
Azure Pipelines GitHub App
        ↓
Azure DevOps Pipeline
        ↓
checkout: self
```

La GitHub App evita di basare la CI sull'identità personale tramite OAuth o su un PAT manuale.

Quando possibile, l'accesso va limitato al repository realmente necessario.

---

# 11. Service connection

Una pipeline non dovrebbe riutilizzare automaticamente il login personale del partecipante per amministrare Azure.

Azure DevOps usa una **service connection**.

La service connection rappresenta:

```text
pipeline
→ identità autorizzata
→ scope Azure
```

Per il blocco finale useremo una Azure Resource Manager service connection con **Workload Identity Federation**.

Questo evita un client secret statico.

---

# 12. Workload Identity Federation

Con Workload Identity Federation:

```text
Azure DevOps
→ token federato
→ Microsoft Entra
→ autorizzazione Azure
```

Non dobbiamo memorizzare nella pipeline:

```text
password
client secret
PAT
```

Le nuove service connection WIF in Azure public cloud usano per impostazione corrente l'emittente Microsoft Entra.

Il precedente issuer Azure DevOps è deprecato e Microsoft ne ha annunciato il ritiro nel 2027.

Per un nuovo laboratorio non dobbiamo quindi progettare una connessione basata su secret statico o su un vecchio issuer.

È il modello preferibile quando l'ambiente e i permessi lo consentono.

---

# 13. Scope minimo

Una service connection non deve avere più privilegi del necessario.

Per il laboratorio creiamo un Resource Group dedicato:

```text
rg-ud13-15-delivery
```

e limitiamo la service connection a quel Resource Group.

Quindi:

```text
service connection
→ può operare sul RG finale del corso
→ non sull'intera subscription
```

Questo applica il principio del minimo privilegio.

---

# 14. Perché ACR non deve essere eliminato 

La pipeline IaC di UD13 creerà un ACR Basic.

Non lo elimineremo perché:

```text
UD14
→ CI
→ build immagine
→ push nello stesso ACR

UD15
→ CD
→ Container Apps
→ pull della stessa immagine
```

Il cleanup dopo UD13 romperebbe l'intera progressione.

Per le due giornate finali il Resource Group è quindi un **ambiente di delivery condiviso tra le tre UD**.

---

# 15. Pipeline di validazione IaC

La prima pipeline farà:

```text
checkout
        ↓
verifica Agent e tool
        ↓
terraform fmt -check
        ↓
terraform init -backend=false
        ↓
terraform validate
        ↓
az bicep lint
        ↓
Bicep What-If
        ↓
Bicep Deploy
```

È importante notare la scelta:

```text
Terraform viene validato
Bicep viene anche distribuito
```

Questo rispetta la progressione decisa nel percorso.

---

# 16. `init -backend=false`

In una pipeline di sola validazione non ci serve inizializzare uno state remoto.

Usiamo:

```bash
terraform init -backend=false
```

per:

- inizializzare i provider;
- rendere possibile `validate`;
- non configurare un backend.

Questo non trasforma Terraform in uno strumento stateless: stiamo semplicemente limitando ciò che la pipeline deve fare oggi.

---

# 17. Trigger

Una pipeline può avviarsi:

- manualmente;
- a ogni push;
- su branch specifiche;
- in base ad altre pipeline.

La pipeline IaC iniziale userà:

```yaml
trigger: none
```

perché vogliamo prima comprenderla ed eseguirla manualmente.

In UD14 la CI verrà invece collegata a `main`.

---

# 18. Diagnosi di pipeline

Quando una pipeline fallisce non dobbiamo cambiare casualmente configurazioni.

Ordine iniziale:

```text
la pipeline è partita?
        ↓
il job ha trovato un agent?
        ↓
checkout riuscito?
        ↓
path corretto?
        ↓
tool disponibile?
        ↓
service connection autorizzata?
        ↓
permessi Azure sufficienti?
```

Questo evita di confondere:

```text
errore YAML
errore agent
errore file
errore autenticazione
errore Azure
```

---

## ACR: modalità di autorizzazione fissata esplicitamente

L'ACR persistente usato da UD13–UD15 viene creato con:

```bicep
roleAssignmentMode: 'LegacyRegistryPermissions'
```

Azure Container Registry supporta anche il modello RBAC+ABAC per i repository. In quel modello i ruoli legacy come `AcrPull` e `AcrPush` non vengono usati nello stesso modo.

Per il percorso didattico UD13–UD15 fissiamo quindi esplicitamente il modello RBAC classico, così le attività successive non dipendono da un valore predefinito del servizio che può evolvere.

Questa è una scelta didattica controllata, non un giudizio sul modello ABAC.

---

# 19. Cleanup selettivo in UD13

Elimineremo le risorse Terraform temporanee.

Non elimineremo:

```text
rg-ud13-15-delivery
ACR
service connection
pipeline
agent
```

Questa volta il mancato cleanup non è una dimenticanza: è una **dipendenza progettata**.

Il cleanup completo di questi elementi avverrà solo in UD15.

---

# 20. Domande di controllo

1. Perché lo state locale è accettabile in UD12 ma problematico in un team?
2. A che cosa serve un backend remoto?
3. Distingui stage, job e step.
4. Che cosa significa `checkout: self`?
5. Perché una pipeline self-hosted non deve assumere di trovarsi in `~/workspace/...`?
6. A che cosa serve una service connection?
7. Perché preferire Workload Identity Federation a un client secret?
8. Perché limitiamo la service connection a un Resource Group?
9. Perché Terraform viene validato ma non applicato dalla pipeline UD13?
10. Perché l'ACR creato in UD13 non deve essere eliminato?
11. A che cosa serve `trigger: none`?
12. Qual è un ordine razionale per diagnosticare una pipeline che non parte correttamente?
13. Perché l'ACR UD13–UD15 fissa esplicitamente `LegacyRegistryPermissions`?
13. Perché UD13 usa deliberatamente il self-hosted Agent come prima pipeline?
14. A che cosa serve `workspace: clean: all` su un self-hosted Agent?
15. Distingui `workspace: clean: all` e `checkout: self, clean: true`.
16. Perché la pipeline non deve usare percorsi come `~/workspace/azure-devops-lab`?
17. Che cosa cambierebbe passando da `pool-ud09-wsl` a `vmImage: ubuntu-latest`?
18. Perché la prima pipeline GitHub usa la Azure Pipelines GitHub App invece di creare un PAT manuale?

19. In produzione, che cosa rappresenterebbe `pool-ud09-wsl` rispetto a un vero Agent Pool aziendale?
20. Perché un Pool con tre Agent non garantisce da solo tre Job paralleli?
