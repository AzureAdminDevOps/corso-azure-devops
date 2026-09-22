# UD12 — Bicep e Terraform

## Obiettivo

Durante la giornata passeremo da:

```text
"eseguo una serie di comandi per creare risorse"
```

a:

```text
"descrivo lo stato desiderato dell'infrastruttura in file versionabili"
```

Useremo due strumenti:

```text
Bicep
→ linguaggio Azure-native

Terraform
→ Infrastructure as Code multipiattaforma
```

Non li useremo per creare infrastrutture complesse. Il punto della UD è comprendere bene il ciclo:

```text
scrivo
→ valido
→ vedo cosa cambierà
→ applico
→ verifico
→ modifico
→ distruggo quando non serve più
```

## Ordine dei file

1. `00_CONCETTI.md`
2. `02_LAB_GUIDATO.md`
3. `03_LAB_AUTONOMO.md`
4. `04_VERIFICA.md`

## Directory di consegna

Il LAB guidato prepara:

```text
consegne/UD12/
├── 00_DOMANDE_CONCETTI.md
├── 01_LAB_GUIDATO.md
├── 02_LAB_AUTONOMO.md
└── 03_VERIFICA.md
```

## Elementi che devono sopravvivere a UD12

Al termine della giornata **non eliminare**:

```text
infra/bicep/
infra/terraform/
installazione Terraform
installazione Bicep
~/azdo-agent/
configurazione dell'agent self-hosted
```

Le UD successive riutilizzano questi elementi.


## Readiness degli Agent

UD12 prepara gli strumenti ma **non introduce ancora pipeline**.

Alla fine distinguiamo:

```text
Self-hosted
→ Terraform/Bicep/CLI/Docker/Git/Python installati o raggiungibili nel WSL2
→ Agent riavviato
→ capability/Path verificati

Microsoft-hosted
→ nessuna installazione persistente locale
→ nuova macchina per ogni Job
→ tool e versioni da verificare dentro la pipeline
```

La prima pipeline IaC di UD13 userà il self-hosted Agent.

Il Microsoft-hosted verrà utilizzato successivamente quando lo stato preparato in UD09 sarà disponibile.


## Dal WSL2 al build server aziendale

Il Gate 2 sul WSL2 rappresenta in piccolo la verifica che un'organizzazione farebbe sui propri build Agent. La toolchain CI è responsabilità della piattaforma self-hosted condivisa, non del singolo sviluppatore.

### Regola da ricordare

```text
self-hosted
≠ PC dello sviluppatore

self-hosted
= Agent su infrastruttura gestita dall'organizzazione
```

Nel laboratorio il WSL2 personale rappresenta soltanto quella macchina Agent.


## Revisione didattica IaC per neofiti — 21/09/2026

`00_CONCETTI.md` è stato riscritto con progressione introduttiva:

```text
problema concreto
→ IaC
→ Bicep letto riga per riga
→ lint / What-If / deployment
→ Terraform letto file per file
→ provider / variabili / riferimenti
→ init / validate / plan / apply
→ state con esempio
→ confronto ragionato Bicep vs Terraform
→ collegamento diretto al LAB
```

Il laboratorio operativo e i file IaC rimangono invariati.
