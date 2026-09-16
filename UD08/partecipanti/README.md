# UD08 — DevOps, Git collaborativo e Catalogo prodotti locale

## Obiettivi

Al termine saprai:

- spiegare DevOps come collaborazione tra persone, processi e strumenti;
- distinguere Continuous Integration, Continuous Delivery e Continuous Deployment;
- creare e usare branch;
- aprire una Pull Request;
- revisionare una Pull Request;
- gestire una richiesta di modifica;
- eseguire merge;
- riconoscere e risolvere un conflitto semplice;
- concedere e rimuovere accesso temporaneo al repository personale;
- eseguire localmente il Catalogo prodotti;
- distinguere frontend, backend/API, configurazione e dati;
- testare endpoint HTTP;
- applicare un fix con branch + test + PR.

## Prerequisiti

Devono funzionare:

```bash
git --version
gh --version
gh auth status
python3 --version
```

Il repository personale già usato nelle UD precedenti deve essere disponibile localmente.

Verifica:

```bash
cd ~/workspace/azure-devops-lab
git status
git remote -v
gh repo view --json nameWithOwner,url
```

Se il repository locale si trova in un'altra cartella:

```bash
cd <cartella-repository-personale>
```

e poi:

```bash
export LAB_REPO="$PWD"
```

Se il percorso standard è corretto:

```bash
export LAB_REPO="$HOME/workspace/azure-devops-lab"
```

## Preparazione obbligatoria del LAB

Il `02_LAB_GUIDATO.md` inizia creando manualmente `consegne/UD08/` e copiando i quattro modelli. Questa preparazione non è automatizzata: serve a rendere chiara la separazione tra materiali del corso, repository personale e file da consegnare.

## Consegne

```text
consegne/UD08/
├── 00_DOMANDE_CONCETTI.md
├── 01_LAB_GUIDATO.md
├── 02_LAB_AUTONOMO.md
└── 03_VERIFICA.md
```

## Regola importante

La collaborazione GitHub richiede una seconda persona reale.

Il materiale non richiede coordinamento del docente: i due partecipanti si organizzano in coppia e svolgono entrambe le direzioni:

```text
A collabora nel repository di B
B collabora nel repository di A
```

Se in quel momento non è disponibile un secondo partecipante:

1. completare tutte le parti locali e individuali;
2. non simulare una review effettuata da un'altra persona;
3. lasciare la sezione collaborazione come `PENDING`;
4. completarla successivamente con un collaboratore reale.

## Sicurezza

Non condividere:

- token GitHub;
- password;
- chiavi SSH private;
- file `.git-credentials`;
- PAT;
- segreti applicativi.

L'accesso collaboratore è temporaneo e deve essere rimosso al termine.
