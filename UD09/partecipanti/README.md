# UD09 — Fondamenti DevOps, Azure DevOps e self-hosted agent

## Perché questa UD cambia impostazione

Prima di utilizzare Azure DevOps dobbiamo capire **DevOps**.

La UD è quindi divisa in due grandi parti:

```text
PARTE 1
Fondamenti DevOps
Agile
Version Control
CI
Testing automation
Artifact
Container
Registry
Orchestrator
IaC
Continuous Delivery / Deployment
Monitoring / feedback
        ↓
PARTE 2
Azure DevOps
Organization
Project
Boards / Repos / Pipelines / Test Plans / Artifacts
Agent Pool
Self-hosted Agent
Microsoft-hosted Agent
Service Connection
```

## Obiettivo concettuale

Al termine dovrai saper spiegare:

- che cosa è DevOps e che cosa non è;
- Agile, Scrum e Kanban;
- backlog, sprint e Work Item;
- versioning, build e artifact;
- testing automation e shift-left;
- Continuous Integration;
- pipeline, stage, job e step;
- container, registry e orchestrator;
- Infrastructure as Code;
- Continuous Delivery vs Continuous Deployment;
- monitoring e feedback;
- DevSecOps;
- toolchain DevOps;
- ruolo dei servizi Azure DevOps.

## Obiettivo operativo

Dovrai avere:

```text
Azure DevOps Organization
        ↓
Private Project
        ↓
Process Agile compreso
        ↓
GitHub repository verificato e integrazione futura definita
        ↓
Parallel jobs verificati
        ↓
Self-hosted pool
        ↓
Linux agent su WSL2
        ↓
Online
        ↓
PAT revocato oppure Device Code Flow documentato
```

## Prerequisiti

### Azure

```bash
az login
az account show --output table
```

### GitHub

```bash
gh auth status
```

Nel repository personale:

```bash
cd ~/workspace/azure-devops-lab
gh repo view --json nameWithOwner,url
```

### WSL2

```bash
uname -a
uname -m
git --version
python3 --version
curl --version
```

## Agent

La pagina Azure DevOps:

```text
Organization settings
→ Agent pools
→ pool-ud09-wsl
→ New agent
```

è il riferimento per scaricare il **pacchetto Linux corrente**.

Non usare una versione copiata da documentazione vecchia o da un altro partecipante.

## Consegne

```text
consegne/UD09/
├── 00_DOMANDE_CONCETTI.md
├── 01_LAB_GUIDATO.md
├── 02_LAB_AUTONOMO.md
└── 03_VERIFICA.md
```

## Sicurezza

Non inserire mai nelle consegne o in Git:

- PAT Azure DevOps;
- token GitHub;
- URL contenenti token;
- subscription ID;
- tenant ID;
- contenuto di diagnostica con credenziali o identificativi non necessari.

Il PAT di registrazione viene:

```text
creato
→ usato
→ revocato
```

nella stessa UD.


## Prerequisito Azure DevOps aggiornato

La creazione di una nuova Azure DevOps Organization richiede una sottoscrizione Azure attiva e la selezione della sottoscrizione durante la creazione.

Se viene riutilizzata una Organization esistente, verificare `Organization settings → Billing`.

## Integrazione GitHub

In UD09 non viene creata una connessione OAuth/PAT GitHub destinata a diventare obsoleta.

La prima pipeline GitHub userà, nelle UD finali, **Azure Pipelines GitHub App**, che è il metodo raccomandato per la CI.


## Condizioni esterne necessarie

Il laboratorio è progettato per essere autosufficiente, ma alcune condizioni dipendono dagli account e dai servizi cloud:

- sottoscrizione Azure attiva per creare/collegare l'Organization;
- permessi di creazione/amministrazione del Project e dell'Agent Pool;
- accesso GitHub al repository personale;
- connettività HTTPS da WSL2;
- repository APT raggiungibili se devono essere installate dipendenze Linux;
- policy aziendali che possono limitare i PAT.

Quando una policy impedisce i PAT, usare il fallback `AAD` / Device Code Flow descritto nel LAB invece di modificare la policy.


## Perché studiamo anche strumenti diversi da Azure DevOps

DevOps è indipendente dal prodotto.

Nel materiale confronteremo concettualmente:

```text
Azure Pipelines      → Azure Pipelines Agent
Jenkins              → Jenkins Agent
GitHub Actions       → Runner
GitLab CI/CD         → GitLab Runner
```

Non svolgeremo quattro laboratori diversi: il confronto serve a riconoscere gli stessi concetti professionali in toolchain differenti.

## Strategia Agent della UD09

```text
SELF-HOSTED
→ configurato e verificato nella UD09
→ baseline immediatamente disponibile

MICROSOFT-HOSTED
→ free tier abilitato/verificato nella UD09
→ se non disponibile, stato documentato
→ utilizzo previsto nelle UD successive
```

Il self-hosted non è quindi l'unico modello del percorso.

## Che cosa farà l'Agent più avanti

L'Agent sarà l'esecutore materiale dei Job:

```text
UD13 → validazione/deployment IaC
UD14 → test + Docker build/push
UD15 → deploy + smoke test
```

La pipeline descrive il lavoro; l'Agent lo esegue.


## Self-hosted nel laboratorio vs in produzione

Nel corso `pool-ud09-wsl → WSL2` è una simulazione didattica di un Agent Pool aziendale. In un team reale gli sviluppatori fanno push al repository e Azure Pipelines assegna i Job a VM/server Agent condivisi. Un Agent esegue un Job alla volta; il parallelismo richiede più Agent e sufficiente capacità di Parallel Jobs.
