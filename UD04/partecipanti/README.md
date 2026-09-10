# UD04 — Azure Storage

In questa unità passeremo dalla risorsa storage osservata in UD02 alla gestione effettiva dei dati. Lo storage account, già creato una prima volta dal portale, verrà ora ricreato da CLI. Il primo container Blob, il primo caricamento e la prima policy lifecycle saranno invece configurati dal portale e poi verificati da CLI.

## Percorso dell'unità

| Fascia | Attività |
|---|---|
| 09:00–11:00 | Storage account, Blob, Files, Queue, Table, ridondanza, tier, endpoint, sicurezza e metodi di accesso |
| 11:15–11:55 | Approfondimento guidato dei concetti: piano di gestione, piano dati, endpoint e scelta del servizio |
| 11:55–13:00 | Laboratorio guidato: controlli, account da CLI, primo container e primo Blob dal portale |
| 14:00–16:00 | Laboratorio guidato: RBAC dati, operazioni CLI, Shared Key, SAS e lifecycle management |
| 16:15–17:10 | Laboratorio autonomo su requisiti di archiviazione |
| 17:10–17:35 | Verifica individuale |
| 17:35–18:00 | Cleanup, controllo dei costi, evidenza e commit finale |

La pianificazione copre 450 minuti effettivi.

## Ordine dei materiali e delle consegne

1. Nel repository personale crea `consegne/UD04` e copia i quattro file presenti in `partecipanti/modelli`:

   ```bash
   cd ~/workspace/azure-devops-lab
   mkdir -p consegne/UD04
   cp ~/workspace/corso-azure-devops/UD04/partecipanti/modelli/*.md consegne/UD04/
   ```

2. Studia `00_CONCETTI.md` e inserisci le risposte richieste in `consegne/UD04/00_DOMANDE_CONCETTI.md`.
3. Esegui `02_LAB_GUIDATO.md`, compila `consegne/UD04/01_LAB_GUIDATO.md` e conserva il file tecnico richiesto come `consegne/UD04/01_DOCUMENTO_LAB.txt`.
4. Svolgi `03_LAB_AUTONOMO.md` e compila `consegne/UD04/02_LAB_AUTONOMO.md`.
5. Completa `04_VERIFICA.md` in `consegne/UD04/03_VERIFICA.md`.

I modelli pubblicati con il materiale del corso rimangono invariati; si lavora soltanto sulle copie del repository personale.

## Consegne richieste

```text
azure-devops-lab/
└── consegne/
    └── UD04/
        ├── 00_DOMANDE_CONCETTI.md
        ├── 01_LAB_GUIDATO.md
        ├── 01_DOCUMENTO_LAB.txt
        ├── 02_LAB_AUTONOMO.md
        └── 03_VERIFICA.md
```

Non pubblicare chiavi, token SAS, URL firmati, subscription ID, object ID o dati personali.
