# UD09 — Laboratorio guidato
## Dalla mappa DevOps alla preparazione concreta di Azure DevOps

Nella prima parte della giornata abbiamo costruito il lifecycle completo:

```text
Plan
→ Develop
→ Integrate
→ Test
→ Deliver
→ Deploy
→ Operate
→ Monitor
→ Feedback
```

Abbiamo anche distinto gli strumenti dalle pratiche.

Ora entriamo nel prodotto **Azure DevOps** e osserviamo come alcuni dei concetti appena studiati vengono rappresentati nella piattaforma.

Non costruiremo ancora una pipeline applicativa.

Lo scopo del LAB è preparare il sistema che le pipeline delle UD successive utilizzeranno:

```text
Azure DevOps Organization
        ↓
Private Project
        ↓
Process Agile
        ↓
GitHub integration readiness
        ↓
Agent Pool
        ↓
WSL2 Linux Agent
        ↓
Online e pronto
```

Durante il LAB continueremo a collegare ogni oggetto operativo al concetto corrispondente.

Esempio:

```text
Agile planning
→ Azure Boards

Version Control
→ GitHub nel nostro corso
  (Azure Repos sarebbe l'alternativa Azure DevOps)

CI/CD
→ Azure Pipelines

Execution
→ Agent / Agent Pool
```

---

# 0. Preparare directory e consegne

Aprire **Ubuntu/WSL2**.

Manteniamo separati tre elementi:

```text
materiali del corso
repository personale Git
software del self-hosted agent
```

La struttura prevista è:

```text
~/workspace/
├── corso-azure-devops/
│   └── UD09/partecipanti/
└── azure-devops-lab/
    └── consegne/UD09/

~/azdo-agent/
```

Notare che `~/azdo-agent/` è fuori dal repository personale.

Impostare:

```bash
export COURSE_UD09="$HOME/workspace/corso-azure-devops/UD09/partecipanti"
export LAB_REPO="$HOME/workspace/azure-devops-lab"
export LAB_SUBMISSION="$LAB_REPO/consegne/UD09"
```

Verificare:

```bash
test -d "$COURSE_UD09" && echo "Materiali UD09 trovati"
test -d "$LAB_REPO/.git" && echo "Repository personale trovato"
```

Creare le consegne:

```bash
mkdir -p "$LAB_SUBMISSION"
```

Copiare i modelli:

```bash
cp -n "$COURSE_UD09/modelli/00_DOMANDE_CONCETTI.md" "$LAB_SUBMISSION/00_DOMANDE_CONCETTI.md"
cp -n "$COURSE_UD09/modelli/01_LAB_GUIDATO.md"      "$LAB_SUBMISSION/01_LAB_GUIDATO.md"
cp -n "$COURSE_UD09/modelli/02_LAB_AUTONOMO.md"    "$LAB_SUBMISSION/02_LAB_AUTONOMO.md"
cp -n "$COURSE_UD09/modelli/03_VERIFICA.md"        "$LAB_SUBMISSION/03_VERIFICA.md"
```

Controllare:

```bash
find "$LAB_SUBMISSION" -maxdepth 1 -type f -printf '%f\n' | sort
```

---

# 1. Verificare Azure, GitHub e WSL2 prima di aprire Azure DevOps

Cominciamo dalle dipendenze che useremo durante la giornata.

Azure:

```bash
az login
az account show --query "{Subscription:name,User:user.name}" --output table
```

GitHub:

```bash
gh auth status
```

Se `gh auth status` indica che l'account non è autenticato, eseguire:

```bash
gh auth login --hostname github.com --git-protocol https --web
gh auth setup-git
```

Poi verificare nuovamente:

```bash
gh auth status
```

Repository:

```bash
cd "$LAB_REPO"
gh repo view --json nameWithOwner,url
git remote -v
git fetch
```

`git fetch` è il controllo conclusivo: verifica che Git, HTTPS, GitHub CLI e repository remoto funzionino realmente insieme senza modificare la working tree.

WSL2/Linux:

```bash
uname -a
uname -m
git --version
curl --version
```

`uname -m` ci servirà più avanti per scegliere il pacchetto agent corretto:

```text
x86_64  → Linux x64
aarch64 → Linux ARM64
```

---

# 2. Creare o riutilizzare una Azure DevOps Organization

Aprire nel browser:

```text
https://dev.azure.com/
```

Accedere con l'identità utilizzata per il corso.

Se non esiste già una Organization personale adatta, scegliere:

```text
New organization
```

> **Prerequisito corrente:** per creare una nuova Azure DevOps Organization è necessaria una **sottoscrizione Azure attiva**.

La schermata di creazione richiede quindi:

```text
Organization name
Hosting geography
Azure subscription for billing
```

Usare un nome riconoscibile, per esempio:

```text
azdo-<username>-<numero>
```

Se il nome è già occupato, modificare soltanto il suffisso numerico.

Quando l'interfaccia propone la geografia, scegliere `Europe` se disponibile e coerente con l'account.

Nel campo relativo alla sottoscrizione selezionare **la propria sottoscrizione Azure del corso**.

Questa associazione non significa che il laboratorio debba acquistare servizi: collega l'Organization a una sottoscrizione valida e abilita correttamente il modello di billing/free tier previsto da Azure DevOps.

Se si riutilizza una Organization già esistente, verificare:

```text
Organization settings
→ Billing
```

e controllare che l'Organization sia collegata a una sottoscrizione Azure valida.

Annotare nella consegna soltanto:

```text
Organization name
Subscription linked: yes/no
```

Non copiare Subscription ID o Tenant ID.

L'URL avrà forma:

```text
https://dev.azure.com/<ORG_NAME>
```

---

# 3. Creare un Project privato e comprendere la scelta `Agile`

Dentro l'Organization scegliere:

```text
New project
```

Impostare:

```text
Project name: az900-az104-devops
Visibility:   Private
Version control: Git
Work item process: Agile
```

Prima di premere `Create`, soffermiamoci sulle ultime due voci.

## Version control: Git

Azure DevOps ci chiede quale modello di version control associare al Project.

Scegliamo:

```text
Git
```

ma questo **non significa che sposteremo il repository in Azure Repos**.

Il repository del corso rimane:

```text
GitHub
```

Stiamo semplicemente creando un Project coerente con il modello Git moderno.

## Work item process: Agile

Questa voce riguarda Azure Boards.

Scegliendo:

```text
Agile
```

Azure DevOps prepara un modello di Work Item che include concetti come:

```text
Epic
Feature
User Story
Task
Bug
Issue
```

Non significa che la classe stia adottando formalmente Scrum.

Significa che il sistema di planning e tracking del Project userà la terminologia e i workflow del processo Agile.

Creare il Project.

---

## 3.1 Comprendere il significato del processo `Agile` senza usare Azure Boards

La scelta:

```text
Work item process: Agile
```

serve a capire che Azure DevOps possiede anche funzioni di pianificazione e tracciamento del lavoro. In questa Academy, però, **Azure Boards non viene utilizzato operativamente**.

Non creare quindi backlog, sprint o Work Item. I termini `backlog`, `sprint`, `Epic`, `Feature`, `User Story`, `Task` e `Bug` restano concetti DevOps/Agile spiegati nella parte teorica e servono a leggere correttamente il lessico professionale.

La toolchain operativa del corso resta:

```text
GitHub         → repository e Pull Request
Azure Pipelines → automazione CI/CD
Agent          → esecuzione dei Job
```

---

## 3.2 Osservare i servizi disponibili nel Project

Nel menu è sufficiente riconoscere che Azure DevOps è una suite che comprende servizi diversi. Non aprire né configurare `Boards`, `Repos`, `Test Plans` o `Artifacts`: nel percorso saranno utilizzati operativamente GitHub e Azure Pipelines.

I nomi degli altri servizi vengono citati soltanto per avere una visione d'insieme della piattaforma.

La domanda da saper rispondere è:

```text
quale pratica DevOps supporta ciascun servizio?
```

Per il corso:

```text
Boards       → conoscenza concettuale
Repos        → non usato; repository = GitHub
Pipelines    → usato dalle UD successive
Test Plans   → conoscenza concettuale
Artifacts    → conoscenza concettuale
```

---

# 4. Leggere i gruppi di sicurezza senza modificarli a caso

Aprire:

```text
Project settings
→ Permissions
```

Individuare:

```text
Project Administrators
Contributors
Readers
Build Administrators
```

Per ciascuno, compilare nella consegna una frase che ne descriva lo scopo.

Non aggiungere utenti e non cambiare permessi soltanto per "provare". In questa fase vogliamo capire la struttura di sicurezza, non alterarla.

---

# 5. Verificare quale repository GitHub collegheremo

Da WSL, nella root del repository personale:

```bash
cd "$LAB_REPO"
gh repo view --json nameWithOwner,url
```

Annotare nella consegna:

```text
owner/repository
```

Quello sarà il repository sorgente delle future pipeline.

---

# 6. Preparare l'integrazione GitHub senza creare una connessione obsoleta

Azure Pipelines avrà bisogno di accedere al repository GitHub quando creeremo la prima pipeline.

Oggi **non creiamo ancora una service connection GitHub OAuth o PAT**.

La ragione è importante: per le pipeline CI Microsoft raccomanda l'integrazione tramite **Azure Pipelines GitHub App**. La connessione viene normalmente stabilita quando si crea la prima pipeline GitHub e si seleziona il repository.

Quindi in UD09 verifichiamo soltanto che il repository sia pronto.

Da WSL2:

```bash
cd "$LAB_REPO"

gh repo view \
  --json nameWithOwner,url,isPrivate
```

Verificare:

```text
repository corretto
accesso con il proprio account
repository privato
```

Poi, nel browser GitHub, verificare di avere sul proprio repository i permessi necessari per autorizzare l'integrazione che useremo nelle UD finali.

La sequenza prevista più avanti sarà:

```text
Azure DevOps
→ New pipeline
→ GitHub
→ Azure Pipelines GitHub App
→ repository del corso
```

Non creare oggi:

```text
GitHub PAT per Azure Pipelines
connessione OAuth GitHub manuale
duplicazione del repository in Azure Repos
```

In questo modo evitiamo di predisporre una connessione personale OAuth che poi non useremmo nelle pipeline finali.

Nella consegna annotare:

```text
GitHub repository:
Repository private: yes/no
GitHub auth verified: yes/no
Preferred future integration: Azure Pipelines GitHub App
```

---

# 7. Preparare entrambi i modelli: self-hosted subito, Microsoft-hosted per le UD successive

Abbiamo appena distinto:

```text
Agent
→ esegue il Job

Parallel Job
→ determina quanti Job possono essere eseguiti contemporaneamente
```

Ora prepariamo **entrambi** i modelli che useremo nel corso.

La strategia della UD09 è:

```text
self-hosted
→ configurarlo oggi
→ usarlo immediatamente come baseline certa

Microsoft-hosted
→ abilitarlo/verificarlo oggi
→ utilizzarlo nelle UD successive quando disponibile
```

Aprire:

```text
Organization settings
→ Pipelines
→ Parallel jobs
```

Osservare separatamente:

```text
Microsoft-hosted
Self-hosted
```

## 7.1 Self-hosted

Per i progetti privati Azure DevOps offre un livello gratuito self-hosted con un Job concorrente.

Questo è sufficiente per il nostro laboratorio.

Il self-hosted non richiede di acquistare una macchina cloud: useremo:

```text
Ubuntu / WSL2 del partecipante
```

e lo configureremo nei passaggi successivi.

## 7.2 Microsoft-hosted

Per i progetti privati Azure DevOps prevede anche un free tier Microsoft-hosted.

La documentazione Microsoft corrente indica che il modo principale per abilitarlo è collegare l'Organization a una **sottoscrizione Azure valida** tramite Billing.

Verificare:

```text
Organization settings
→ Billing
```

Se l'Organization è stata appena creata con una sottoscrizione idonea, il collegamento può essere già presente.

Poi tornare a:

```text
Organization settings
→ Pipelines
→ Parallel jobs
```

e verificare il valore Microsoft-hosted.

Quando il free tier è attivo, per un Project privato dispone normalmente di:

```text
1 Job concorrente
massimo 60 minuti per singolo Job
1.800 minuti al mese
```

Non acquistare parallel job aggiuntivi.

## 7.3 Se il Microsoft-hosted non viene abilitato

Il laboratorio **non deve fermarsi**.

Le sottoscrizioni e le policy disponibili possono differire.

In particolare, alcune offerte Azure Free Trial possono non essere accettate dal sistema di billing Azure DevOps.

Se la sottoscrizione non compare, non viene accettata o il Microsoft-hosted resta non disponibile, annotare nel file di consegna uno dei seguenti stati:

```text
MICROSOFT_HOSTED_READY
```

oppure:

```text
MICROSOFT_HOSTED_PENDING
```

oppure:

```text
MICROSOFT_HOSTED_BILLING_NOT_ELIGIBLE
```

Se l'interfaccia Azure DevOps mostra esplicitamente una procedura ufficiale per richiedere/abilitare il free grant, seguirla e annotare:

```text
MICROSOFT_HOSTED_REQUEST_SUBMITTED
```

Non inserire dati sensibili nella consegna.

In tutti questi casi il corso prosegue con il self-hosted Agent.

L'obiettivo della UD09 è quindi:

```text
self-hosted
→ sicuramente configurato e verificato

Microsoft-hosted
→ abilitato oppure stato documentato
→ pronto ad essere utilizzato appena disponibile
```

Nella consegna riportare:

```text
Self-hosted parallelism:
Microsoft-hosted status:
Billing subscription linked: yes/no
Hosted action: ready / pending / request submitted / billing not eligible
```

---

# Prima di creare il Pool: che cosa stiamo simulando

Nel laboratorio configureremo:

```text
pool-ud09-wsl
        ↓
Agent nel WSL2 personale
```

Serve a rendere visibile il meccanismo e a evitare di predisporre una VM dedicata per ogni partecipante.

Il corrispondente scenario reale sarebbe più simile a:

```text
team di sviluppatori
        ↓
repository
        ↓
Azure Pipelines
        ↓
pool-linux-build
        ├── build-agent-01
        ├── build-agent-02
        └── build-agent-03
```

Durante il laboratorio tradurre mentalmente:

```text
WSL2 personale
→ build host aziendale

pool-ud09-wsl
→ Agent Pool aziendale

partecipante
→ sviluppatore del team
```

Non stiamo insegnando che il notebook dello sviluppatore debba essere il server di compilazione di produzione.

# 8. Creare un Agent Pool self-hosted

Da questo momento configuriamo il primo esecutore reale **del laboratorio**.

Ricordiamo il flusso:

```text
Azure Pipelines
        ↓
Job
        ↓
pool-ud09-wsl
        ↓
self-hosted Agent
        ↓
Ubuntu / WSL2
        ↓
comandi reali
```

Nelle UD successive questo Agent potrà eseguire, quando richiesto dalla pipeline:

```text
Git
Python
Docker
Azure CLI
Bicep
Terraform
curl
```

Non stiamo quindi installando un componente "accessorio": stiamo predisponendo il sistema che eseguirà materialmente i Job.

Aprire **dal Project**:

```text
Project settings
→ Agent pools
→ Add pool
```

Scegliere:

```text
New
Pool type: Self-hosted
Name: pool-ud09-wsl
```

Creandolo dal Project garantiamo che il pool sia immediatamente disponibile anche alle future pipeline di:

```text
az900-az104-devops
```

Il pool apparirà anche a livello Organization.

Se compare un'opzione per concedere automaticamente l'accesso del pool a tutte le pipeline, lasciarla disabilitata: la futura pipeline verrà autorizzata esplicitamente.

Aprire il nuovo pool. All'inizio è normale vedere:

```text
Agents: 0
```

Il pool esiste, ma non abbiamo ancora registrato nessun esecutore.

---

# 9. Preparare l'autenticazione di registrazione dell'agent

Per registrare un self-hosted agent l'identità usata deve poter amministrare il relativo Agent Pool.

Aprire:

```text
Project settings
→ Agent pools
→ pool-ud09-wsl
→ Security
```

Verificare che l'account che sta svolgendo il laboratorio disponga del ruolo/permesso necessario ad amministrare il pool.

## Percorso principale del laboratorio: PAT temporaneo

Aprire:

```text
User settings
→ Personal access tokens
→ New Token
```

Impostare:

```text
Name: ud09-agent-registration
Organization: quella corrente
Expiration: la più breve disponibile e adatta al laboratorio
Scopes: Custom defined
Agent Pools: Read & manage
```

Tutti gli altri scope devono restare non selezionati.

Creare il token e conservarlo **solo temporaneamente** fino alla configurazione dell'agent.

Non inserirlo:

- nel repository;
- nei file di consegna;
- in uno script;
- in una variabile salvata in `.bashrc`.

Il PAT verrà revocato appena la registrazione sarà completata.

## Se la policy dell'Organization impedisce la creazione di PAT

Non modificare policy di sicurezza e non richiedere `Full access`.

Azure DevOps supporta anche la registrazione tramite **Device Code Flow**.

Nel file di consegna scrivere:

```text
PAT_POLICY_BLOCKED
Registrazione agent eseguita con Device Code Flow.
```

Durante `./config.sh`, al tipo di autenticazione usare:

```text
AAD
```

e completare il login nel browser con il codice mostrato.

In questo percorso non esiste un PAT da revocare; il controllo successivo verrà marcato:

```text
N/A — Device Code Flow
```

---

# 10. Scaricare l'agent corretto dalla pagina del pool

Aprire:

```text
Organization settings
→ Agent pools
→ pool-ud09-wsl
→ Agents
→ New agent
```

Scegliere:

```text
Linux
```

Controllare da WSL:

```bash
uname -m
```

Se restituisce `x86_64`, scegliere il pacchetto x64. Se restituisce `aarch64`, scegliere ARM64.

La pagina Azure DevOps mostra i comandi aggiornati per la versione corrente dell'agent. Copiare **l'URL di download mostrato dalla pagina**, non utilizzare un URL scritto mesi prima nel materiale.

Creare la directory:

```bash
mkdir -p "$HOME/azdo-agent"
cd "$HOME/azdo-agent"
```

Scaricare usando l'URL copiato, per esempio:

```bash
curl -fL '<URL-MOSTRATO-DA-AZURE-DEVOPS>' -o agent.tar.gz
```

Estrarre:

```bash
tar xzf agent.tar.gz
```

Verificare:

```bash
ls
```

Devono comparire file come:

```text
config.sh
run.sh
bin/
```

## Dipendenze Linux

Azure Pipelines fornisce nel pacchetto uno script per verificare/installare le dipendenze Linux richieste.

Su Ubuntu/WSL2 eseguire:

```bash
./bin/installdependencies.sh
```

Se il comando richiede privilegi `sudo`, inserire la password Linux quando richiesto.

Se lo script segnala problemi di repository APT o connettività, risolvere **prima** di eseguire `config.sh`: un agent con runtime incompleto non è una baseline affidabile.

---

# 11. Configurare l'agent in modalità interattiva

Questo è un passaggio importante e **non lo nascondiamo in un comando unattended**.

Dalla directory:

```bash
cd "$HOME/azdo-agent"
```

eseguire:

```bash
./config.sh
```

Il programma fa alcune domande. Rispondiamo una per una.

## Server URL

Quando chiede:

```text
Enter server URL
```

inserire:

```text
https://dev.azure.com/<ORG_NAME>
```

## Authentication type

Se il PAT è stato creato regolarmente, scegliere:

```text
PAT
```

e incollare il PAT temporaneo quando richiesto.

Il valore non deve essere salvato nella documentazione.

Se invece la policy ha impedito la creazione del PAT, scegliere:

```text
AAD
```

e completare il Device Code Flow nel browser.

I due metodi servono **solo alla registrazione** dell'agent.

## Agent pool

Inserire:

```text
pool-ud09-wsl
```

## Agent name

Usare un nome riconoscibile, per esempio:

```text
wsl-ud09-<proprio-username>
```

## Work folder

Accettare il valore proposto:

```text
_work
```

Se vengono proposte altre opzioni non necessarie, mantenere i default salvo diversa esigenza esplicita del laboratorio.

Al termine la registrazione deve concludersi senza errori.

---

# 12. Avviare il processo agent

La registrazione ha creato la configurazione, ma l'agent deve ora mettersi in ascolto.

Eseguire:

```bash
cd "$HOME/azdo-agent"
./run.sh
```

Il terminale rimane occupato dal processo.

Dovrebbe comparire un messaggio simile a:

```text
Listening for Jobs
```

Da questo momento **questo terminale è dedicato all'agent** e va lasciato aperto.

Per eventuali altri comandi WSL2 della giornata aprire **un secondo terminale Ubuntu/WSL2**. In questo modo non dobbiamo fermare l'agent soltanto per eseguire `git status` o altri controlli.

---

# 13. Verificare dal Portale che l'agent sia Online

Tornare nel browser:

```text
Organization settings
→ Agent pools
→ pool-ud09-wsl
→ Agents
```

L'agent appena registrato deve apparire:

```text
Online
```

Annotare nella consegna:

- nome agent;
- pool;
- stato;
- versione mostrata.

Non serve copiare ID interni.

---

# 14. Chiudere la credenziale di registrazione

## Se è stato usato il PAT

Tornare a:

```text
User settings
→ Personal access tokens
```

Individuare:

```text
ud09-agent-registration
```

ed eseguire:

```text
Revoke
```

Attendere qualche secondo e ricaricare la pagina del pool.

L'agent deve continuare a risultare:

```text
Online
```

Questo dimostra che il PAT è servito **alla registrazione**, non alla comunicazione ordinaria successiva dell'agent.

## Se è stato usato Device Code Flow

Non c'è un PAT da revocare.

Nella consegna indicare:

```text
Registration authentication: Device Code Flow
PAT revoke: N/A
Agent Online: yes
```

---

# 15. Leggere le capability dell'agent

Aprire:

```text
Agent pools
→ pool-ud09-wsl
→ Agents
→ <nome-agent>
→ Capabilities
```

Individuare almeno:

```text
Agent.OS
Agent.Version
git
PATH
```

Se `python`/`python3` compare, annotarlo.

Non aggiungere manualmente capability soltanto per far apparire un valore: in questa fase vogliamo osservare ciò che l'agent rileva realmente.

---

# 16. Provare volontariamente il passaggio Online → Offline → Online

Nel terminale dove è in esecuzione `./run.sh`, premere:

```text
Ctrl+C
```

Tornare al Portale e aggiornare la pagina.

L'agent deve diventare:

```text
Offline
```

Questo non significa che la registrazione sia stata persa. Significa che il processo non è in esecuzione.

Riavviarlo:

```bash
cd "$HOME/azdo-agent"
./run.sh
```

Verificare nuovamente:

```text
Online
```

Non creare un nuovo PAT e non rieseguire `./config.sh` per un semplice processo fermo.

---

# 17. Costruire la readiness finale

Compilare nella consegna:

```text
Organization:
Project privato:
GitHub repository/integration readiness:
Microsoft-hosted status:
Self-hosted status:
Pool:
Agent:
Agent Online:
PAT revocato oppure Device Code Flow:
Capability essenziali:
Restart Offline/Online verificato:
Nessun segreto nel repository:
```

Questa checklist ci dice se l'ambiente è realmente pronto per le prossime UD.

---

# 18. Mettere in sicurezza il repository e le consegne

Il software agent resta in:

```text
~/azdo-agent/
```

Non deve essere copiato nel repository personale.

Tornare quindi al repository:

```bash
cd "$LAB_REPO"
git status
```

Verificare che nelle consegne non siano presenti:

- PAT;
- URL contenenti token;
- file di configurazione agent;
- log `_diag` completi;
- subscription/tenant ID non necessari.

L'agent resterà configurato per le UD successive.

Se il terminale dedicato rimane aperto, l'agent resta `Online`. Se il terminale viene chiuso a fine giornata, la configurazione non viene persa: nella UD successiva sarà sufficiente riavviarlo con:

```bash
cd "$HOME/azdo-agent"
./run.sh
```

Non rieseguire `./config.sh` e non creare un nuovo PAT per un semplice riavvio del processo.
