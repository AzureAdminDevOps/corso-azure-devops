# UD06 — Azure Compute, scaling, monitoraggio e protezione

## Obiettivi

Al termine della giornata dovrai saper:

- scegliere tra VM e App Service;
- creare e amministrare una VM Linux;
- riconoscere image, size, NIC, IP, dischi e NSG;
- distinguere Availability Zone, Availability Set e VM Scale Set;
- distinguere scale up e scale out;
- comprendere il funzionamento dell'autoscaling VM;
- creare una Web App in App Service;
- comprendere le opzioni di scaling App Service;
- usare Azure Monitor Metrics;
- spiegare il ruolo di Log Analytics;
- distinguere HA, Backup e Disaster Recovery;
- descrivere Recovery Services vault, backup policy e recovery point;
- diagnosticare un problema reale di raggiungibilità della VM.

## Sequenza

| Orario | Attività |
|---|---|
| 09:00–11:00 | Compute, VM, availability, scaling, App Service, Monitor, Backup/DR |
| 11:15–11:30 | Domande sui concetti |
| 11:30–11:50 | Scenari di consolidamento e confronto architetturale |
| 11:50–13:00 | Lab: VM Linux + SSH |
| 14:00–15:00 | Nginx + NSG + Network Watcher + Metrics |
| 15:00–15:35 | App Service + scaling |
| 15:35–16:00 | Backup/DR guidato |
| 16:15–17:10 | Lab autonomo |
| 17:10–17:35 | Verifica |
| 17:35–18:00 | Cleanup e consegna |

## Consegne

Crea:

```bash
mkdir -p consegne/UD06
```

e usa i modelli presenti in `modelli/`.

```text
consegne/UD06/
├── 00_DOMANDE_CONCETTI.md
├── 01_LAB_GUIDATO.md
├── 02_LAB_AUTONOMO.md
└── 03_VERIFICA.md
```

## Regola di sicurezza

Non pubblicare:

- chiavi private SSH;
- password;
- token;
- subscription ID;
- object ID;
- recovery point identificativi non necessari;
- URL o segreti che consentano accesso alle risorse.


## Autonomia del materiale

Tutti i file della UD sono progettati per essere completati senza dipendere da demo o spiegazioni orali. Le eventuali attività svolte durante l'erogazione servono a rafforzare i concetti, ma ogni scelta operativa, fallback e regola necessaria è riportata direttamente nei materiali partecipante.
