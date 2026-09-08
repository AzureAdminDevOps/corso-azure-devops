# UD02 — Cloud, architettura Azure e gestione iniziale delle risorse

In questa unità collegheremo i modelli cloud alla struttura reale di Microsoft Azure. Useremo prima Azure Portal e Cloud Shell per osservare il contesto, poi Azure CLI per creare e interrogare un piccolo ambiente. Tutte le risorse verranno infine eliminate e il cleanup sarà verificato.

## Percorso dell'unità

| Fascia | Attività |
|---|---|
| 09:00–11:00 | Modelli cloud, responsabilità condivisa, architettura Azure, regioni, zone e principali famiglie di servizi |
| 11:15–12:05 | Approfondimento guidato dei concetti: Azure Portal, Cloud Shell, sottoscrizione, località, naming, tag e sequenza operativa |
| 12:05–13:00 | Laboratorio guidato, sezioni 1–4: repository, CLI, account, provider, nomi e variabili |
| 14:00–16:00 | Laboratorio guidato, sezioni 5–10: resource group, VNet, storage account, interrogazioni ed evidenza |
| 16:15–17:10 | Laboratorio autonomo basato su requisiti operativi |
| 17:10–17:35 | Verifica individuale |
| 17:35–18:00 | Laboratorio guidato, sezione 12: cleanup verificato, consolidamento e commit finale |

La pianificazione copre **450 minuti effettivi**. La sezione 11 del laboratorio guidato viene consultata quando si presenta un errore e rimane comunque materiale di studio autonomo. Al termine delle verifiche si ritorna alla sezione 12 per eliminare l'ambiente guidato e controllare il commit finale.

## Ordine dei materiali

1. Prima di iniziare, nel repository personale crea `consegne/UD02` e copia i quattro file presenti in `partecipanti/modelli`:

   ```bash
   cd ~/workspace/azure-devops-lab
   mkdir -p consegne/UD02
   cp ~/workspace/corso-azure-devops/UD02/partecipanti/modelli/*.md consegne/UD02/
   ```

2. Studia `00_CONCETTI.md` e inserisci le risposte richieste in `consegne/UD02/00_DOMANDE_CONCETTI.md`.
3. Esegui `02_LAB_GUIDATO.md` e documenta i checkpoint in `consegne/UD02/01_LAB_GUIDATO.md`; lo script di variabili creato durante la procedura va salvato come `consegne/UD02/01_VARIABILI_LAB.sh`.
4. Svolgi `03_LAB_AUTONOMO.md` e compila `consegne/UD02/02_LAB_AUTONOMO.md`.
5. Completa `04_VERIFICA.md` in `consegne/UD02/03_VERIFICA.md`.

I file dentro `partecipanti/modelli` sono sorgenti non compilati: le risposte e gli output devono essere inseriti soltanto nelle copie del repository personale.

## Richiamo a UD01

Si presume già noto come:

- distinguere PowerShell dal terminale Ubuntu;
- aprire il repository con `code .` nel contesto WSL;
- usare `git status`, `git diff`, `git add`, `git commit` e `git push`;
- controllare la versione di Azure CLI;
- evitare la pubblicazione di tenant ID, subscription ID, token e codici temporanei.

Quando uno di questi passaggi ricorre, il materiale richiama `UD01` invece di ripeterne integralmente la spiegazione.

## Criterio di completamento

Il repository personale deve contenere:

```text
azure-devops-lab/
└── consegne/
    └── UD02/
        ├── 00_DOMANDE_CONCETTI.md
        ├── 01_LAB_GUIDATO.md
        ├── 01_VARIABILI_LAB.sh
        ├── 02_LAB_AUTONOMO.md
        └── 03_VERIFICA.md
```

Il completamento richiede anche che:

- le risorse create non siano più presenti;
- il resource group del laboratorio risulti eliminato;
- i file pubblicati non contengano identificativi o credenziali non necessari;
- il commit finale sia visibile su GitHub.
