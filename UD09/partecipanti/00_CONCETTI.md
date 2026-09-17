# UD09 — Concetti
## Fondamenti DevOps e introduzione ad Azure DevOps

Nelle UD precedenti abbiamo già utilizzato molte pratiche che appartengono al mondo DevOps, anche se non le avevamo ancora riunite in una visione unica.

Abbiamo usato:

```text
Git
branch
commit
Pull Request
review
merge
troubleshooting
monitoring
Docker arriverà nella UD10
IaC arriverà nelle UD12–UD13
CI/CD arriveranno nelle UD14–UD15
```

Prima di entrare in Azure DevOps dobbiamo quindi fermarci e rispondere a una domanda fondamentale:

> **Che cos'è realmente DevOps?**

Azure DevOps è un prodotto.  
**DevOps non è un prodotto.**

Se non distinguiamo questi due livelli, rischiamo di imparare una serie di schermate e pulsanti senza comprendere il processo che quei servizi stanno cercando di supportare.

La prima parte della UD09 costruisce quindi la mappa concettuale completa:

```text
DevOps
→ Agile planning
→ Version Control
→ Build
→ Automated Testing
→ Continuous Integration
→ Artifact
→ Container
→ Registry
→ Orchestration
→ Infrastructure as Code
→ Continuous Delivery
→ Continuous Deployment
→ Operate / Monitor / Feedback
→ Azure DevOps
```

Solo dopo questa mappa introdurremo concretamente:

```text
Azure DevOps Organization
Project
Azure Boards
Azure Repos
Azure Pipelines
Azure Test Plans
Azure Artifacts
Agent
Agent Pool
Service Connection
```

---

# 1. Perché nasce DevOps

Nei modelli tradizionali può esistere una separazione netta fra:

```text
sviluppo
        ↓
consegna
        ↓
operations
```

Il team di sviluppo produce una nuova versione e la passa a un altro gruppo, che deve installarla e mantenerla.

Questo può produrre problemi:

```text
"funzionava sul PC dello sviluppatore"

"non sappiamo esattamente quale versione è stata consegnata"

"l'ambiente di test è diverso dalla produzione"

"il deployment dipende da una procedura manuale"

"il team operations scopre il cambiamento soltanto al rilascio"

"un problema in produzione non torna rapidamente al team di sviluppo"
```

DevOps nasce per ridurre queste separazioni e costruire un ciclo più continuo tra:

```text
persone
processi
tecnologia
```

L'obiettivo non è fare lavorare "più velocemente" a qualsiasi costo.

L'obiettivo è rendere il flusso di modifica più:

- collaborativo;
- ripetibile;
- verificabile;
- automatizzabile;
- osservabile;
- sicuro;
- capace di ricevere feedback.

---

# 2. DevOps non è un ruolo, un tool o una pipeline

È comune incontrare frasi come:

```text
"abbiamo comprato Azure DevOps, quindi facciamo DevOps"

"abbiamo una pipeline, quindi siamo DevOps"

"il DevOps è quello che gestisce Jenkins"
```

Sono semplificazioni.

DevOps è soprattutto un insieme di **principi e pratiche organizzative e tecniche**.

Un tool può supportare quelle pratiche, ma non sostituirle.

Possiamo rappresentare DevOps come intersezione di tre dimensioni:

```text
CULTURA
collaborazione, responsabilità condivisa, feedback

PROCESSI
planning, versioning, review, test, release, operation

TECNOLOGIA
Git, pipeline, container, IaC, monitoraggio, security automation
```

Se manca una di queste dimensioni, l'automazione può diventare soltanto una sequenza più veloce di errori.

---

# 3. Il lifecycle DevOps è un ciclo, non una catena che termina

Per semplicità possiamo rappresentare il lifecycle come:

```text
PLAN
  ↓
DEVELOP
  ↓
DELIVER
  ↓
OPERATE
  ↓
MONITOR / FEEDBACK
  └───────────────→ PLAN
```

La cosa importante è l'ultima freccia.

Il monitoraggio e il feedback non rappresentano "la fine del progetto".

Producono informazioni che tornano alla pianificazione:

```text
bug
prestazioni
incident
richieste utenti
metriche di utilizzo
problemi operativi
```

e possono generare nuovo lavoro.

Questo rende il lifecycle **iterativo**.

---

# 4. Agile e DevOps non sono sinonimi

**Agile** riguarda principalmente il modo in cui un team pianifica e sviluppa valore in modo iterativo e adattivo.

**DevOps** estende la continuità del lavoro fino a:

```text
integrazione
test
delivery
deployment
operation
monitoring
feedback
```

Possiamo dire:

```text
Agile
→ aiuta a organizzare e sviluppare il lavoro in cicli brevi

DevOps
→ collega quei cicli anche alla delivery e alle operations
```

Un'organizzazione può adottare pratiche Agile senza avere una delivery realmente automatizzata.

Allo stesso modo, può avere automazioni tecniche senza una cultura collaborativa realmente Agile.

---

# 5. Sprint, backlog e iterazione

Nel lavoro Agile incontreremo termini specifici.

## Backlog

Il **backlog** è una lista ordinata di lavoro da realizzare.

Può contenere:

```text
funzionalità
bug
miglioramenti
attività tecniche
debito tecnico
```

Non è semplicemente una lista di cose da fare.

Gli elementi vengono:

- descritti;
- prioritizzati;
- stimati;
- raffinati;
- selezionati per le iterazioni successive.

## Sprint

Uno **sprint** è un intervallo di tempo breve e definito durante il quale il team realizza un insieme selezionato di elementi.

In Scrum gli sprint sono tipicamente brevi e ripetuti.

La logica è:

```text
scegliamo lavoro gestibile
→ lo realizziamo
→ verifichiamo il risultato
→ riceviamo feedback
→ adattiamo il prossimo ciclo
```

---

# 6. Scrum: un framework Agile

**Scrum** è un framework che organizza il lavoro in sprint e definisce ruoli, eventi e artefatti.

Tre ruoli concettuali importanti sono:

```text
Product Owner
→ ordina il valore e mantiene il backlog

Scrum Master
→ facilita il processo e rimuove impedimenti

Development Team
→ realizza l'incremento
```

Nel nostro corso non stiamo trasformando la classe in un team Scrum.

Ci interessa capire perché strumenti come Azure Boards parlano di:

```text
backlog
sprint
work item
story
task
bug
```

---

# 7. Kanban: visualizzare il flusso di lavoro

**Kanban** è un approccio che rende visibile il flusso.

Una board minimale può essere:

```text
TO DO
→ IN PROGRESS
→ REVIEW
→ DONE
```

Ogni elemento di lavoro è rappresentato da una card.

L'obiettivo non è semplicemente avere colonne colorate.

Kanban aiuta a capire:

```text
quanto lavoro è in corso?
dove si accumulano elementi?
qual è il collo di bottiglia?
il team sta iniziando troppo lavoro contemporaneamente?
```

Un concetto importante è il **WIP limit**:

```text
Work In Progress limit
```

cioè limitare quanto lavoro può trovarsi contemporaneamente in uno stato.

---

# 8. Epic, Feature, User Story, Task e Bug

Nel processo **Agile** di Azure Boards incontriamo una gerarchia di Work Item.

## Epic

Un **Epic** rappresenta un'iniziativa molto ampia.

Esempio:

```text
Digitalizzare il processo di vendita
```

## Feature

Una **Feature** rappresenta una capacità significativa del prodotto.

Esempio:

```text
Gestione catalogo prodotti
```

## User Story

Una **User Story** descrive una necessità dal punto di vista dell'utente.

Esempio:

```text
Come addetto vendite
voglio visualizzare i prodotti disponibili
per poter proporre articoli disponibili al cliente
```

## Task

Una **Task** è un'attività concreta necessaria per implementare il lavoro.

Esempio:

```text
creare endpoint GET /api/products
```

## Bug

Un **Bug** descrive un difetto.

Esempio:

```text
/api/products restituisce 500 quando stock è nullo
```

Una possibile relazione è:

```text
Epic
└── Feature
    └── User Story
        ├── Task
        ├── Task
        └── Bug
```

---

# 9. Acceptance Criteria e Definition of Done

Una User Story non dovrebbe essere considerata completa solo perché:

```text
"il programmatore ha finito"
```

Gli **Acceptance Criteria** definiscono condizioni verificabili che la funzionalità deve soddisfare.

Esempio:

```text
Dato un catalogo con prodotti
quando chiamo GET /api/products
allora ricevo HTTP 200
e una lista JSON dei prodotti
```

La **Definition of Done** è invece un criterio più generale adottato dal team.

Può includere:

```text
codice versionato
review completata
test superati
documentazione aggiornata
pipeline verde
nessun problema critico noto
```

Questo collega direttamente planning e automazione.

---

# 10. Version Control

Il **Version Control** registra l'evoluzione dei file nel tempo.

Git ci permette di sapere:

```text
che cosa è cambiato?
chi ha modificato?
quando?
perché?
posso tornare a una versione precedente?
```

In UD08 abbiamo già praticato:

```text
branch
commit
push
Pull Request
review
merge
```

Adesso collochiamo quelle attività nel lifecycle DevOps.

Il Version Control non serve soltanto al codice applicativo.

Può versionare anche:

```text
Dockerfile
pipeline YAML
Bicep
Terraform
configurazioni
documentazione
```

Questo principio sarà centrale nelle UD successive.

---

# 11. Branch, Pull Request e code review

Una **branch** isola una linea di modifica.

Una **Pull Request** propone l'integrazione della branch in un'altra branch, tipicamente `main`.

La Pull Request è importante perché crea uno spazio nel quale possiamo:

```text
leggere il diff
discutere
richiedere modifiche
approvare
eseguire controlli automatici
decidere se integrare
```

La **code review** non è soltanto una ricerca di errori sintattici.

Può verificare:

- correttezza;
- leggibilità;
- sicurezza;
- coerenza architetturale;
- test;
- mantenibilità.

---

# 12. Build

Il termine **build** indica il processo che trasforma il contenuto sorgente in qualcosa che può essere eseguito, distribuito o pubblicato.

La build cambia in base alla tecnologia.

Esempi:

```text
Java
source → compilazione → JAR

.NET
source → compilazione → assembly/package

frontend
source → bundle statico

container
Dockerfile + context → container image
```

Nel nostro Catalogo Python non abbiamo una compilazione tradizionale, ma avremo comunque un processo di costruzione della container image.

---

# 13. Artifact

Un **artifact** è un risultato prodotto dal processo di build e destinato ad essere utilizzato in una fase successiva.

Esempi:

```text
JAR
ZIP
NuGet package
npm package
container image
file pubblicato da una pipeline
```

L'idea importante è:

```text
SOURCE
→ BUILD
→ ARTIFACT
→ DELIVERY
```

Non dovremmo ricostruire casualmente un artifact diverso in ogni ambiente.

Idealmente lo stesso artifact validato attraversa gli ambienti successivi.

---

# 14. Testing automation

Il testing manuale rimane utile, ma in DevOps cerchiamo di automatizzare tutti i controlli che possono essere ripetuti in modo affidabile.

Alcune categorie:

## Unit test

Verifica una piccola unità di codice in isolamento.

```text
funzione
classe
metodo
```

## Integration test

Verifica l'interazione tra più componenti.

Esempio:

```text
API
↔
database
```

## Acceptance test

Verifica se una funzionalità soddisfa i criteri attesi dal business/utente.

## Smoke test

È un controllo rapido dopo il deployment.

Domanda:

```text
il servizio è almeno raggiungibile
e le funzioni essenziali rispondono?
```

In UD15 useremo uno smoke test sull'endpoint `/health`.

---

# 15. Shift-left

**Shift-left** significa spostare controlli il più presto possibile nel ciclo di sviluppo.

Invece di scoprire un errore solo:

```text
in produzione
```

cerchiamo di intercettarlo:

```text
sul PC
→ nella PR
→ nella CI
→ nell'ambiente di test
```

Un bug rilevato prima è normalmente:

- più semplice da localizzare;
- meno costoso;
- meno rischioso.

---

# 16. Continuous Integration

**Continuous Integration**, abbreviata **CI**, è la pratica di integrare frequentemente le modifiche nella base condivisa e sottoporle automaticamente a build e test.

Un flusso semplificato:

```text
developer
  ↓
commit / Pull Request
  ↓
repository
  ↓
pipeline CI
  ↓
build
  ↓
automated tests
  ↓
artifact
```

L'idea non è:

```text
"fare una build automatica una volta al mese"
```

ma ottenere feedback frequente sulle modifiche.

Nella UD14 realizzeremo concretamente:

```text
GitHub
→ Azure Pipelines
→ test Python
→ Docker build
→ push ACR
```

---

# 17. Pipeline

Una **pipeline** descrive una sequenza automatizzata di attività.

Una pipeline può includere:

```text
checkout
build
test
security scan
package
publish
deploy
smoke test
```

Non significa necessariamente che tutte le pipeline debbano fare tutto.

Possiamo avere:

```text
pipeline CI
pipeline IaC
pipeline deployment
```

oppure una pipeline integrata con più stage.

---

# 18. Stage, Job e Step

Questi termini verranno usati molto nelle ultime UD.

## Stage

Uno **Stage** rappresenta una fase logica.

Esempio:

```text
Test
Build
Deploy
Smoke
```

## Job

Un **Job** è un insieme di step eseguito su un agent.

## Step

Uno **Step** è una singola operazione.

Esempio:

```text
esegui python3 -m unittest
```

Gerarchia:

```text
Pipeline
└── Stage
    └── Job
        ├── Step
        ├── Step
        └── Step
```

---

# 19. Continuous Delivery

In questo corso useremo **Continuous Delivery** con questo significato:

> mantenere il software in uno stato distribuibile e automatizzare il percorso di build, test, configurazione e deployment verso gli ambienti previsti.

Un esempio:

```text
CI
 ↓
artifact
 ↓
DEV
 ↓
TEST
 ↓
STAGING
 ↓
approvazione
 ↓
PRODUCTION
```

La produzione può ancora prevedere una decisione o approvazione esplicita.

Il punto centrale è che il processo tecnico di rilascio sia:

- ripetibile;
- automatizzato;
- verificato.

---

# 20. Continuous Deployment

**Continuous Deployment** va un passo oltre.

Ogni modifica che supera automaticamente tutti i gate previsti può arrivare in produzione senza un'approvazione manuale specifica per quel rilascio.

Schema:

```text
commit
→ CI
→ test
→ artifact
→ deployment automatico
→ production
```

Per evitare ambiguità nel corso useremo sempre i termini per esteso quando la distinzione è importante.

---

# 21. Container

Un **container** è un processo isolato che utilizza un'immagine come modello di filesystem e configurazione.

Termini da distinguere:

```text
Dockerfile
→ istruzioni per costruire

Image
→ artifact immutabile costruito

Container
→ istanza in esecuzione dell'image
```

In UD10 useremo Docker per costruire ed eseguire il Catalogo prodotti in container.

---

# 22. Registry

Un **container registry** è un servizio che conserva e distribuisce container image.

Schema:

```text
Docker build
    ↓
image locale
    ↓
push
    ↓
registry
    ↓
pull
    ↓
runtime
```

Nel corso useremo:

```text
Azure Container Registry
ACR
```

in UD11 e poi nella CI/CD finale.

---

# 23. Orchestrator

Quando abbiamo pochi container possiamo gestirli manualmente.

Quando diventano numerosi dobbiamo risolvere problemi come:

```text
su quale nodo eseguirli?
quante repliche?
cosa succede se un processo muore?
come facciamo rolling update?
come esponiamo i servizi?
come gestiamo scaling?
```

Un **orchestrator** automatizza questo tipo di gestione.

L'esempio più importante è **Kubernetes**.

Kubernetes introduce concetti come:

```text
scheduling
repliche
self-healing
service discovery
rolling update
scaling
```

Nel nostro percorso non faremo un laboratorio Kubernetes.

Useremo invece **Azure Container Apps**, una piattaforma gestita che ci permette di lavorare con container senza amministrare direttamente un cluster Kubernetes.

---

# 24. Infrastructure as Code

**Infrastructure as Code**, abbreviata **IaC**, significa descrivere infrastruttura e configurazioni in file versionabili.

Esempi del corso:

```text
Bicep
Terraform
```

Invece di affidarsi a:

```text
"ricordo quali click ho fatto nel portale"
```

possiamo avere:

```text
file
→ review
→ versioning
→ pipeline
→ deployment ripetibile
```

IaC verrà introdotta operativamente nelle UD12–UD13.

---

# 25. Operate, Monitoring e Feedback

DevOps non termina con il deployment.

Dobbiamo sapere:

```text
il servizio è disponibile?
è lento?
sta generando errori?
quale versione sta girando?
ci sono alert?
```

Nella UD07 abbiamo già usato:

```text
Azure Monitor
Activity Log
Metrics
Log Analytics
KQL
Alert
```

Adesso possiamo capire il loro posto nel lifecycle:

```text
DEPLOY
  ↓
OPERATE
  ↓
MONITOR
  ↓
FEEDBACK
  ↓
PLAN
```

---

# 26. DevSecOps

**DevSecOps** significa integrare la sicurezza nel lifecycle DevOps invece di trattarla come controllo finale separato.

Esempi:

```text
least privilege
secret management
dependency scanning
container image scanning
policy as code
security test
branch protection
service connection limitate
```

Nel corso abbiamo già applicato questo principio quando abbiamo evitato:

```text
PAT Full access
token nei repository
permessi amministrativi indiscriminati
```

---

# 27. Toolchain DevOps

Non esiste un unico strumento che deve necessariamente svolgere ogni funzione.

Una **toolchain** è l'insieme coordinato di strumenti usati nel lifecycle.

Esempio possibile:

```text
Planning        → Azure Boards
Source Control  → GitHub
CI/CD           → Azure Pipelines
Container       → Docker
Registry        → Azure Container Registry
IaC             → Terraform / Bicep
Runtime         → Azure Container Apps
Monitoring      → Azure Monitor
```

Questo è molto vicino alla toolchain che useremo nel percorso.

## 27.1 DevOps non coincide con Azure DevOps

Le pratiche DevOps non appartengono a un singolo produttore.

Concetti come:

```text
Version Control
Continuous Integration
automated testing
pipeline
artifact
Continuous Delivery
Continuous Deployment
Infrastructure as Code
container
monitoring
```

possono essere implementati con strumenti differenti.

Azure DevOps è **una possibile piattaforma**.

La domanda professionale corretta non è soltanto:

```text
"quale pulsante devo usare in Azure DevOps?"
```

ma prima:

```text
"quale pratica DevOps devo implementare?"
```

e poi:

```text
"quale strumento userò per implementarla?"
```

Per esempio:

```text
Continuous Integration
        │
        ├── Azure Pipelines
        ├── Jenkins
        ├── GitHub Actions
        └── GitLab CI/CD
```

## 27.2 Piattaforma di orchestrazione ed esecutore non sono la stessa cosa

I prodotti usano nomi differenti, ma spesso ritroviamo lo stesso schema:

```text
piattaforma / controller
        ↓
Job
        ↓
worker / agent / runner
        ↓
esecuzione reale dei comandi
```

Una corrispondenza utile è:

| Piattaforma | Componente che esegue materialmente i Job |
|---|---|
| Azure Pipelines | Azure Pipelines Agent |
| Jenkins | Jenkins Agent |
| GitHub Actions | Runner |
| GitLab CI/CD | GitLab Runner |

Quindi non è corretto confrontare:

```text
Azure Pipelines Agent
vs
Jenkins
```

perché appartengono a livelli diversi.

Il confronto corretto è:

```text
Azure Pipelines
vs
Jenkins
vs
GitHub Actions
vs
GitLab CI/CD
```

e, al livello degli esecutori:

```text
Azure Pipelines Agent
vs
Jenkins Agent
vs
GitHub Actions Runner
vs
GitLab Runner
```

## 27.3 Jenkins

**Jenkins** è una piattaforma di automazione open source molto diffusa in ambito CI/CD.

L'architettura distribuita distingue:

```text
Jenkins Controller
        ↓
Jenkins Agent
        ↓
build / test / deploy
```

Il Controller orchestra e schedula il lavoro.

Gli Agent forniscono gli executor che eseguono materialmente i Job e gli Step richiesti.

Jenkins è importante nel nostro quadro generale perché dimostra che:

```text
pipeline
job
agent
build
test
deployment
```

sono concetti DevOps generali e non caratteristiche esclusive di Azure DevOps.

## 27.4 GitHub Actions

**GitHub Actions** è il sistema di automazione integrato in GitHub.

Un workflow contiene Job e Step.

L'esecutore viene chiamato:

```text
Runner
```

Il Runner può essere:

```text
GitHub-hosted
```

oppure:

```text
self-hosted
```

Schema:

```text
GitHub Actions Workflow
        ↓
Job
        ↓
Runner
        ↓
Step
```

È quindi concettualmente molto vicino al modello che vedremo con Azure Pipelines.

## 27.5 GitLab CI/CD

Anche **GitLab CI/CD** utilizza Runner che ricevono ed eseguono i Job definiti nella pipeline.

Schema:

```text
GitLab CI/CD
        ↓
Job
        ↓
GitLab Runner
        ↓
build / test / deploy
```

GitLab può offrire runner gestiti oppure runner amministrati dall'organizzazione.

## 27.6 Open source, SaaS e piattaforme gestite

Nel panorama DevOps troviamo modelli differenti.

```text
Jenkins
→ open source
→ controller e agent gestiti dall'organizzazione

Azure Pipelines
→ servizio Azure DevOps
→ orchestration gestita Microsoft
→ agent Microsoft-hosted oppure self-hosted

GitHub Actions
→ servizio integrato in GitHub
→ runner GitHub-hosted oppure self-hosted

GitLab CI/CD
→ integrato nella piattaforma GitLab
→ runner gestiti oppure self-managed
```

La scelta dipende da:

```text
tecnologie già presenti
cloud adottato
competenze del team
governance
sicurezza
rete
costi
manutenzione
scalabilità
integrazione con repository e deployment target
```

## 27.7 La toolchain scelta per questo corso

Nel nostro percorso useremo principalmente:

```text
Planning        → Azure Boards, a livello concettuale
Version Control → GitHub
CI/CD           → Azure Pipelines
Execution       → Azure Pipelines Agent
Container       → Docker
Registry        → Azure Container Registry
IaC             → Bicep + Terraform
Runtime         → Azure Container Apps
Monitoring      → Azure Monitor
```

Questa è **una possibile toolchain DevOps**, non "la toolchain DevOps".

L'obiettivo è imparare sia:

```text
come usare questi strumenti
```

sia:

```text
quale problema DevOps stanno risolvendo
```

in modo da poter riconoscere gli stessi concetti anche utilizzando Jenkins, GitHub Actions, GitLab CI/CD o altri strumenti.

---

# 28. Azure DevOps: la piattaforma

Ora possiamo finalmente introdurre il prodotto.

**Azure DevOps Services** è una piattaforma Microsoft che offre servizi integrati per supportare varie fasi del lifecycle.

I servizi principali sono:

```text
Azure Boards
Azure Repos
Azure Pipelines
Azure Test Plans
Azure Artifacts
```

Azure DevOps non "è DevOps".

È una piattaforma che implementa strumenti utili per pratiche DevOps.

---

# 29. Azure Boards

**Azure Boards** supporta planning e tracking del lavoro.

Offre:

```text
Work Items
Backlogs
Boards
Sprints
Queries
Dashboards
```

Può supportare processi come:

```text
Basic
Agile
Scrum
CMMI
```

Nel Project della UD09 sceglieremo:

```text
Agile
```

Questa scelta determina i tipi di Work Item e il workflow disponibili.

Non useremo Boards come strumento operativo del corso, ma dobbiamo comprenderne il ruolo.

---

# 30. Perché scegliamo il processo Agile nel Project

Quando creeremo il Project imposteremo:

```text
Work item process: Agile
```

Non significa:

```text
"da questo momento la classe sta facendo Scrum"
```

Significa che Azure Boards predisporrà un modello di tracking coerente con terminologia Agile, tra cui:

```text
Epic
Feature
User Story
Task
Bug
Issue
```

È una configurazione del sistema di work tracking.

---

# 31. Azure Repos

**Azure Repos** offre repository Git e funzionalità come:

```text
branch
Pull Request
review
branch policy
```

Nel nostro percorso **non useremo Azure Repos**.

Abbiamo già scelto:

```text
GitHub
→ source repository autorevole
```

Duplicare lo stesso codice in due sistemi introdurrebbe:

- confusione;
- sincronizzazione inutile;
- rischio di divergenza.

Conoscere Azure Repos resta importante perché fa parte della piattaforma.

---

# 32. Azure Pipelines

**Azure Pipelines** è il servizio Azure DevOps per automatizzare:

```text
build
test
packaging
deployment
```

Supporta pipeline definite anche in YAML.

Nelle UD successive Azure Pipelines diventerà il motore di automazione principale.

UD09 però non crea ancora la CI applicativa.

Prima prepariamo:

```text
Organization
Project
connessioni
Agent Pool
Agent
```

---

# 33. Azure Test Plans

**Azure Test Plans** supporta attività di test management, in particolare test manuali ed esplorativi.

Può gestire:

```text
Test Plan
Test Suite
Test Case
esecuzioni
risultati
```

Questo è diverso dai test automatici eseguiti in una pipeline.

Possiamo avere:

```text
Azure Test Plans
→ gestione di casi di test manuali

Azure Pipelines
→ esecuzione automatica dei test
```

---

# 34. Azure Artifacts

**Azure Artifacts** è un servizio di package management.

Può ospitare feed per package come:

```text
NuGet
npm
Maven
Python
Universal Packages
```

Non va confuso con ACR.

```text
Azure Artifacts
→ package feed

Azure Container Registry
→ container image registry
```

Nel nostro percorso non useremo Azure Artifacts operativamente, ma dobbiamo sapere dove si colloca.

---

# 35. Organization

Una **Azure DevOps Organization** è il contenitore amministrativo superiore.

Può contenere:

```text
Organization
├── Project A
├── Project B
└── Project C
```

A livello Organization troviamo elementi come:

- utenti;
- billing;
- parallel jobs;
- Agent Pool condivisi;
- impostazioni di sicurezza.

---

# 36. Project

Un **Project** è uno spazio di lavoro interno all'Organization.

Contiene o collega elementi come:

```text
Boards
Repos
Pipelines
Test Plans
Artifacts
Service connections
Security
```

Per il corso creeremo:

```text
az900-az104-devops
```

con visibilità:

```text
Private
```

---

# 37. Gruppi e permission

Azure DevOps usa gruppi di sicurezza.

Ne incontreremo alcuni:

```text
Project Administrators
Contributors
Readers
Build Administrators
```

## Project Administrators

Gestione ampia del Project.

## Contributors

Utenti che contribuiscono normalmente al lavoro.

## Readers

Accesso prevalentemente in lettura.

## Build Administrators

Privilegi aggiuntivi relativi a build/pipeline.

Il principio rimane:

```text
least privilege
```

Non rendere tutti amministratori "per evitare problemi".

---

# 38. Permission: Allow, Deny, Not set

Una permission può derivare da più gruppi.

Valori tipici:

```text
Allow
Deny
Not set
```

Un `Deny` esplicito può prevalere su permessi ereditati.

Quando qualcosa non funziona, il metodo corretto non è aumentare privilegi casualmente.

Bisogna chiedersi:

```text
chi è l'utente?
in quali gruppi si trova?
quale permission è necessaria?
a quale scope?
esiste un Deny?
```

---

# 39. Pipeline, Job, Agent

Ora riprendiamo Stage, Job e Step aggiungendo l'esecuzione reale.

```text
Pipeline
→ Stage
→ Job
→ Step
```

Il **Job** deve essere eseguito da un ambiente concreto.

Quell'ambiente è l'**Agent**.

```text
Pipeline
→ Job
→ Agent
→ comando reale
```

Se uno step contiene:

```bash
python3 --version
```

il comando viene eseguito sul sistema operativo dell'agent.

## 39.1 Che cosa fa realmente l'Agent

La pipeline descrive **che cosa** deve accadere.

Azure Pipelines orchestra **quando e dove** eseguire il lavoro.

L'Agent esegue materialmente i comandi.

```text
Pipeline YAML
→ descrive il lavoro

Azure Pipelines
→ orchestra il lavoro

Agent
→ esegue il lavoro
```

L'Agent non decide autonomamente:

```text
quali test sono corretti
quando distribuire
quale ordine logico usare
quale strategia Git adottare
```

Queste decisioni sono definite nella pipeline e nella progettazione del processo.

## 39.2 Che cosa eseguirà l'Agent nel nostro percorso

Nelle prossime UD l'Agent eseguirà progressivamente operazioni che prima avremo svolto manualmente.

| UD | Ruolo dell'Agent |
|---|---|
| **UD09** | viene configurato, reso Online e preparato come esecutore; comprendiamo hosted vs self-hosted |
| **UD10** | prepariamo Docker e l'ambiente locale che il self-hosted Agent potrà usare |
| **UD11** | eseguiamo manualmente ACR e Container Apps per comprendere le attività che poi automatizzeremo |
| **UD12** | installiamo/verifichiamo Bicep e Terraform; diventano tool utilizzabili dall'Agent |
| **UD13** | l'Agent esegue validazioni IaC e i primi Job di pipeline |
| **UD14** | l'Agent esegue test, Docker build e push dell'immagine |
| **UD15** | l'Agent esegue deployment, verifiche e smoke test della pipeline integrata |

Esempi di comandi che potranno essere eseguiti da un Agent:

```bash
git --version
python3 -m unittest
docker build ...
docker push ...
terraform init
terraform validate
az deployment group create ...
curl https://...
```

Quindi il concetto essenziale è:

> **L'Agent è l'esecutore materiale dei Job della pipeline.**

## 39.3 L'Agent deve avere l'ambiente necessario

Se una pipeline richiede:

```bash
terraform validate
```

l'Agent deve poter eseguire `terraform`.

Se richiede:

```bash
docker build
```

l'Agent deve avere Docker disponibile.

Questo è uno dei motivi per cui la scelta dell'Agent è una decisione tecnica importante.

Con un self-hosted Agent:

```text
tool e configurazione
→ sono sotto il nostro controllo
```

Con un Microsoft-hosted Agent:

```text
ambiente
→ deriva dall'immagine Microsoft scelta per il Job
```

Un Job può comunque installare tool aggiuntivi se necessario.

---

# 40. Agent Pool

Gli agent vengono organizzati in **Agent Pool**.

Esempio:

```text
pool-ud09-wsl
├── agent-01
├── agent-02
└── agent-03
```

Una pipeline sceglie un pool.

Azure DevOps seleziona un agent disponibile compatibile con il job.

Il pool è quindi:

- unità organizzativa;
- confine di autorizzazione;
- insieme di esecutori.

---

## Dal laboratorio a un team reale

Nel corso useremo:

```text
pool-ud09-wsl
→ Agent installato nel WSL2 del partecipante
```

Questo è un self-hosted Agent reale dal punto di vista tecnico, ma è soprattutto una **simulazione didattica di un build host aziendale**.

Non va interpretato così:

```text
ogni sviluppatore
→ trasforma il proprio PC
→ nel server di compilazione del team
```

In un'organizzazione è più realistico:

```text
Sviluppatore A ─┐
Sviluppatore B ─┤
Sviluppatore C ─┤
...             ├── GitHub / repository
Sviluppatore N ─┘
                        ↓
                 Azure Pipelines
                        ↓
                Agent Pool aziendale
                ├── build-agent-01
                ├── build-agent-02
                └── build-agent-03
                        ↓
              build / test / deploy
```

Gli sviluppatori fanno:

```text
commit
→ push
```

Azure Pipelines:

```text
accoda il Job
→ seleziona un Agent disponibile del Pool
→ esegue checkout
→ esegue gli Step
```

In Azure DevOps Services gli Agent Pool sono risorse organizzative e possono essere condivisi tra progetti, in funzione delle autorizzazioni.

### Dove può trovarsi un self-hosted Agent reale

Per esempio:

```text
VM Linux in Azure
VM Windows in Azure
VM VMware / Hyper-V on-premises
server fisico
VM in un altro cloud
```

La caratteristica decisiva non è dove si trova la macchina, ma **chi la gestisce**.

```text
self-hosted
≠ PC dello sviluppatore

self-hosted
= infrastruttura Agent gestita dall'organizzazione
```

### Agent e parallelismo

Un singolo Agent esegue:

```text
1 Job alla volta
```

Per più Job contemporanei servono:

```text
più Agent disponibili
+
sufficiente capacità di Parallel Jobs
```

Esempio:

```text
pool-linux-build

agent-01 → Job A
agent-02 → Job B
agent-03 → Job C
```

Se gli Agent compatibili sono occupati, il Job resta in coda.

Quindi:

```text
numero di Agent
≠
capacità di Parallel Jobs
```

# 41. Microsoft-hosted Agent

Un **Microsoft-hosted agent** viene predisposto e gestito da Microsoft.

Per ogni Job la pipeline riceve un ambiente appena predisposto.

Caratteristiche:

```text
ambiente temporaneo
tool preinstallati
manutenzione Microsoft
ambiente pulito per il Job
```

In YAML possiamo selezionare, per esempio, un'immagine Linux tramite:

```yaml
pool:
  vmImage: ubuntu-latest
```

`vmImage` indica l'immagine preconfigurata che Azure Pipelines deve utilizzare per creare l'ambiente hosted.

Vantaggi:

- semplicità;
- ambiente pulito e ripetibile;
- nessuna manutenzione della macchina;
- disponibilità di molti tool preinstallati.

Limite didatticamente importante:

```text
il Job successivo non deve fare affidamento
su file rimasti localmente dal Job precedente
```

perché l'ambiente hosted viene ricreato.

Per i progetti privati il free tier Microsoft-hosted, quando abilitato, mette a disposizione un job concorrente con limiti di durata e minuti mensili.

Nella UD09 verificheremo/abiliteremo questo free tier, in modo da poter usare concretamente anche il Microsoft-hosted nelle UD successive.

---

# 42. Self-hosted Agent

Un **self-hosted agent** gira su una macchina gestita da noi.

Nel corso:

```text
Ubuntu su WSL2
```

Vantaggi:

- controllo sui tool;
- ambiente persistente;
- possibilità di usare il nostro Docker/CLI/Terraform.

Responsabilità:

```text
patch
sicurezza
tool
processo agent
workspace
disponibilità
```

Questo sarà il **primo percorso operativo**: lo configuriamo subito in UD09 perché è controllabile direttamente e permette di capire fisicamente dove vengono eseguiti i Job.

Non sarà però l'unico modello del corso.

La strategia è:

```text
UD09
→ self-hosted configurato e funzionante
→ Microsoft-hosted verificato/abilitato

UD successive
→ uso consapevole di entrambi
→ confronto delle caratteristiche
```

---

## Come leggere il resto del corso

Quando nelle UD successive diremo:

```text
il self-hosted usa il nostro WSL2
```

dobbiamo tradurre mentalmente:

```text
LABORATORIO
→ WSL2 personale = macchina Agent

PRODUZIONE
→ VM/server aziendale = macchina Agent
```

Il modello Azure Pipelines resta lo stesso; cambia la topologia infrastrutturale.

# 43. Agent e Parallel Job non sono la stessa cosa

Questa distinzione è fondamentale.

**Agent**:

```text
chi esegue il job
```

**Parallel Job**:

```text
quanti job possono essere eseguiti contemporaneamente
```

Esempio:

```text
3 agent Online
+
1 parallel job
=
normalmente 1 job alla volta
```

Aggiungere agent non aumenta automaticamente la capacità di concorrenza.

---

# 44. Service Connection

Una **Service Connection** rappresenta un collegamento autenticato tra Azure DevOps e un sistema esterno.

Esempi:

```text
GitHub
Azure Resource Manager
Azure Container Registry
```

È importante distinguere:

```text
la connessione esiste
```

da:

```text
una determinata pipeline può usarla
```

Per questo evitiamo, salvo necessità, l'opzione:

```text
Grant access permission to all pipelines
```

---

# 45. GitHub rimane il repository sorgente

La nostra toolchain è deliberatamente ibrida:

```text
GitHub
→ repository
→ branch
→ Pull Request

Azure DevOps
→ Pipelines
→ Agent
→ Service Connection
```

Nelle pipeline future Microsoft raccomanda l'integrazione GitHub App.

In UD09 prepariamo il collegamento e comprendiamo i principi; non duplichiamo il repository in Azure Repos.

---

# 46. Registrazione del self-hosted Agent

Il software agent viene scaricato dalla pagina:

```text
Agent pools
→ pool-ud09-wsl
→ New agent
```

Useremo il pacchetto Linux corrente proposto dall'interfaccia.

Non fissiamo nel materiale una major version specifica: Azure DevOps evolve il software agent e la pagina `New agent` rappresenta il riferimento operativo.

La configurazione avviene con:

```bash
./config.sh
```

e l'esecuzione interattiva con:

```bash
./run.sh
```

---

# 47. PAT di registrazione

Un metodo supportato per registrare il self-hosted agent è un **Personal Access Token**, abbreviato PAT.

Nel laboratorio il PAT avrà lo scope minimo:

```text
Agent Pools (Read & manage)
```

Non:

```text
Full access
```

Il PAT serve durante la registrazione.

Non viene utilizzato per ogni job successivo.

Per questo la sequenza principale del laboratorio è:

```text
crea PAT breve
→ registra agent
→ verifica Online
→ revoca PAT
→ verifica che l'agent resti Online
```

Se una policy dell'Organization impedisce la creazione di PAT, **non allarghiamo la policy e non ricorriamo a `Full access`**. Azure DevOps supporta anche il **Device Code Flow**, selezionabile come autenticazione `AAD` durante `config.sh`.

Quindi distinguiamo:

```text
percorso didattico principale
→ PAT temporaneo e revoca

fallback se PAT vietato da policy
→ AAD / Device Code Flow
```

Entrambi i metodi servono soltanto alla registrazione dell'agent.

---

# 48. `run.sh`

`./config.sh` registra l'agent.

`./run.sh` avvia il processo che ascolta i job.

Quindi:

```text
registrato
≠
in esecuzione
```

Se `run.sh` viene terminato:

```text
Agent → Offline
```

Se viene riavviato:

```text
Agent → Online
```

Questo comportamento verrà verificato nel LAB.

---

# 49. Capabilities

Azure DevOps rileva caratteristiche dell'agent chiamate **capabilities**.

Esempi:

```text
Agent.OS
PATH
git
```

Nelle UD successive useremo anche:

```text
Docker
Azure CLI
Terraform
```

Se installiamo nuovi tool mentre il processo agent è già attivo, un riavvio può essere necessario affinché l'ambiente aggiornato venga rilevato.

---

# 50. Readiness

Non basta vedere:

```text
Online
```

La readiness finale richiede:

```text
Organization corretta
Project corretto
GitHub collegato
Agent Pool corretto
Agent Online
capability essenziali
PAT revocato
restart Offline/Online compreso
nessun segreto nel repository
```

---

# 51. Come UD09 collega tutto il percorso

La progressione complessiva adesso è leggibile:

```text
UD07
Monitoring / feedback
        ↑
        │
UD08
Git / PR / review
        ↓
UD09
DevOps lifecycle + Azure DevOps + agent
        ↓
UD10
Container / Docker
        ↓
UD11
Registry + deployment manuale
        ↓
UD12
Bicep + Terraform
        ↓
UD13
IaC + pipeline
        ↓
UD14
Continuous Integration
        ↓
UD15
Continuous Delivery
```

UD09 è quindi il punto nel quale le tecniche viste separatamente diventano un unico modello.

---

# 52. Domande di controllo

1. Perché DevOps non può essere ridotto a un prodotto?
2. Quali sono le tre dimensioni principali che abbiamo associato a DevOps?
3. Perché il lifecycle DevOps è rappresentato come un ciclo?
4. Distingui Agile e DevOps.
5. Che cos'è un backlog?
6. Che cos'è uno sprint?
7. Distingui Scrum e Kanban.
8. Distingui Epic, Feature, User Story, Task e Bug.
9. A che cosa servono gli Acceptance Criteria?
10. Perché il Version Control è importante anche per IaC e pipeline YAML?
11. Distingui build e artifact.
12. Distingui unit test, integration test e smoke test.
13. Che cosa significa shift-left?
14. Definisci Continuous Integration.
15. Distingui Stage, Job e Step.
16. Distingui Continuous Delivery e Continuous Deployment.
17. Distingui Dockerfile, image e container.
18. Che cos'è un registry?
19. Che problema risolve un orchestrator?
20. Che cos'è Infrastructure as Code?
21. Che cosa aggiunge DevSecOps al lifecycle?
22. Che cos'è una DevOps toolchain?
23. Quali sono i cinque principali servizi Azure DevOps?
24. A che cosa serve Azure Boards?
25. Perché nel corso usiamo GitHub invece di Azure Repos?
26. Distingui Azure Test Plans e test automatici in pipeline.
27. Distingui Azure Artifacts e Azure Container Registry.
28. Distingui Organization e Project.
29. Distingui Agent, Agent Pool e Parallel Job.
30. Distingui Microsoft-hosted e self-hosted Agent.
31. Che cos'è una Service Connection?
32. Perché il PAT di registrazione può essere revocato dopo che l'agent è Online?
33. Perché DevOps non coincide con Azure DevOps?
34. Qual è la differenza tra Azure Pipelines e Azure Pipelines Agent?
35. Qual è la relazione concettuale tra Azure Pipelines Agent, Jenkins Agent, GitHub Runner e GitLab Runner?
36. Quali attività svolgerà concretamente l'Agent nelle UD13–UD15?
37. Perché un Job Microsoft-hosted non dovrebbe dipendere da file lasciati dal Job precedente?
38. Perché il WSL2 personale del corso non rappresenta la topologia self-hosted tipica di un team?
39. Come può essere organizzato un Agent Pool aziendale?
40. Perché più Agent non implicano automaticamente più Job eseguibili in parallelo?
