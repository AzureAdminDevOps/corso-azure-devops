# UD10 — Docker locale su WSL2

## Obiettivi

Al termine saprai:

- distinguere image e container;
- spiegare il ruolo di un registry;
- leggere un Dockerfile;
- costruire un'immagine;
- eseguire un container;
- pubblicare una porta;
- leggere log e inspect;
- usare environment variable;
- distinguere bind mount e named volume;
- comprendere rete bridge e DNS Docker;
- usare `docker compose`;
- eseguire frontend + backend;
- diagnosticare un errore di configurazione;
- eseguire cleanup senza cancellare dati accidentalmente.

## Prerequisito operativo

Docker deve essere utilizzabile da WSL2.

Eseguire:

```bash
docker version
docker compose version
```

Se funzionano entrambi, continuare.

Se `docker` non è disponibile, seguire la procedura autonoma del Lab guidato prima di proseguire.

## Repository

Il Catalogo prodotti deve già essere presente nel repository personale dalla UD08.

Verifica:

```bash
cd ~/workspace/azure-devops-lab 2>/dev/null || true
test -d app/catalogo-prodotti && echo "Catalogo presente"
```

Se il repository è in un'altra directory:

```bash
cd <repository-personale>
```

poi:

```bash
export LAB_REPO="$PWD"
```

## Preparazione obbligatoria del LAB

Il `02_LAB_GUIDATO.md` prepara manualmente `consegne/UD10/` e verifica Docker con tre comandi leggibili (`docker version`, `docker compose version`, `docker info`). Non viene utilizzato un preflight script che nasconda questi controlli.

## Consegne

```text
consegne/UD10/
├── 00_DOMANDE_CONCETTI.md
├── 01_LAB_GUIDATO.md
├── 02_LAB_AUTONOMO.md
└── 03_VERIFICA.md
```

## Regola di autosufficienza

Ogni passaggio contiene:

```text
azione
→ risultato atteso
→ controllo
→ fallback
```

Non sono necessarie demo o indicazioni esterne per completare i file.

## Attenzione cleanup

```bash
docker compose down
```

non equivale a:

```bash
docker compose down -v
```

`-v` elimina anche i named volume del progetto.


## Raccordo con UD09 e con le pipeline successive

UD10 resta un laboratorio Docker **manuale e locale**. Non viene creata alcuna pipeline.

La relazione con gli Agent è però importante:

```text
self-hosted Agent
→ userà lo stesso ambiente WSL2
→ dovrà poter raggiungere Docker

Microsoft-hosted Agent
→ userà un ambiente gestito Microsoft
→ la pipeline verificherà i tool disponibili
```

Impariamo quindi prima a costruire, eseguire e diagnosticare i container manualmente; solo dopo automatizzeremo operazioni già comprese.
