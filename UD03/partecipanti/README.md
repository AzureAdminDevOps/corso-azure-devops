# UD03 — Identità, accessi, sicurezza, governance e costi

In questa unità collegheremo un'identità Microsoft Entra alle autorizzazioni sulle risorse Azure. Ogni nuovo oggetto sarà introdotto dal portale; CLI servirà poi a verificare in modo ripetibile ciò che è stato configurato.

## Percorso dell'unità

| Fascia | Attività |
|---|---|
| 09:00–11:00 | Identità, autenticazione, autorizzazione, utenti, gruppi, ruoli Entra, Azure RBAC, scope, ereditarietà, Zero Trust e minimo privilegio |
| 11:15–12:00 | Approfondimento guidato dei concetti: lettura del tenant, IAM, ruolo, principal e scope |
| 12:00–13:00 | Laboratorio guidato: prerequisiti, resource group, osservazione o creazione controllata di utente e gruppo |
| 14:00–16:00 | Laboratorio guidato: assegnazione RBAC, verifica, Cost Analysis, budget, tag e lock |
| 16:15–17:10 | Laboratorio autonomo situazionale |
| 17:10–17:35 | Verifica individuale |
| 17:35–18:00 | Cleanup di ruoli, lock, budget, oggetti di test e resource group; commit finale |

## Ordine dei materiali

1. Nel repository personale crea `consegne/UD03` e copia i quattro file presenti in `partecipanti/modelli`:

   ```bash
   cd ~/workspace/azure-devops-lab
   mkdir -p consegne/UD03
   cp ~/workspace/corso-azure-devops/UD03/partecipanti/modelli/*.md consegne/UD03/
   ```

2. Studia `00_CONCETTI.md` e inserisci le risposte richieste in `consegne/UD03/00_DOMANDE_CONCETTI.md`.
3. Esegui `02_LAB_GUIDATO.md` e documenta i checkpoint in `consegne/UD03/01_LAB_GUIDATO.md`.
4. Svolgi `03_LAB_AUTONOMO.md` e compila `consegne/UD03/02_LAB_AUTONOMO.md`.
5. Completa `04_VERIFICA.md` in `consegne/UD03/03_VERIFICA.md`.

I file dentro `partecipanti/modelli` non devono essere modificati: servono a creare le copie personali.

## Consegne richieste

```text
azure-devops-lab/
└── consegne/
    └── UD03/
        ├── 00_DOMANDE_CONCETTI.md
        ├── 01_LAB_GUIDATO.md
        ├── 02_LAB_AUTONOMO.md
        └── 03_VERIFICA.md
```

Non pubblicare tenant ID, subscription ID, object ID, indirizzi personali, password, token o schermate contenenti dati di altri utenti.
