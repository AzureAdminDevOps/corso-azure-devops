# UD07 — Amministrazione e monitoraggio operativo

## Obiettivi

Al termine della giornata dovrai saper:

- usare Azure CLI e Azure PowerShell;
- interrogare output senza leggerli manualmente;
- scrivere procedure ripetibili;
- spiegare l'idempotenza;
- leggere Activity Log;
- distinguere Activity Log, Metrics e Logs;
- usare un Log Analytics workspace;
- eseguire prime query KQL;
- comprendere e configurare diagnostic settings;
- creare una metric alert rule;
- comprendere un Action Group;
- correlare una modifica con evidenze operative;
- redigere un runbook di troubleshooting.

## Sequenza

| Fascia | Attività |
|---|---|
| 09:00–11:00 | CLI, PowerShell, JMESPath, oggetti, idempotenza, Monitor, Logs, alert |
| 11:15–11:30 | Domande concetti |
| 11:30–13:00 | Script CLI + sequenza PowerShell |
| 14:00–14:45 | Activity Log + Log Analytics + KQL |
| 14:45–15:25 | Metrics |
| 15:25–16:00 | Metric alert + Action Group |
| 16:15–17:10 | Lab autonomo e troubleshooting |
| 17:10–17:35 | Verifica |
| 17:35–18:00 | Cleanup e consegna |

## Preparazione obbligatoria del LAB

Il `02_LAB_GUIDATO.md` inizia con la preparazione dell'ambiente di lavoro. Prima di creare risorse Azure vengono:

1. identificata la cartella dei materiali;
2. identificato il repository personale;
3. creata `consegne/UD07/`;
4. copiati i quattro modelli senza sovrascrivere file esistenti;
5. verificato lo stato Git.

Questa parte va svolta manualmente: i comandi sono semplici e servono anche a rendere chiara la struttura delle directory utilizzata durante la giornata.

---

## Consegne

```text
consegne/UD07/
├── 00_DOMANDE_CONCETTI.md
├── 01_LAB_GUIDATO.md
├── 02_LAB_AUTONOMO.md
└── 03_VERIFICA.md
```

## Sicurezza

Non pubblicare:

- subscription ID;
- tenant ID;
- token;
- chiavi;
- indirizzi email personali non necessari;
- output completi che includano identificativi sensibili.

Nei file di consegna sostituisci identificativi non necessari con:

```text
<omesso>
```
