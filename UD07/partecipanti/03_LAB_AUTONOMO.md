# UD07 — Laboratorio autonomo
## Amministrazione, monitoraggio e troubleshooting

# Scenario

Un amministratore deve verificare una risorsa Azure dopo una modifica.

Non basta dire:

```text
"la risorsa esiste"
```

Deve produrre una catena verificabile:

```text
comando
→ modifica
→ Activity Log
→ metrica/log
→ alert
→ interpretazione
```

---

# Attività 1 — Scrivi un piccolo script Bash idempotente

Crea uno script Bash che gestisca:

```text
rg-ud07-auto
```

Lo script deve essere intenzionalmente semplice e leggibile. Sono sufficienti:

```text
variabili
az group exists
if / else
az group create
az group update
az group show
```

Non servono funzioni, array, `trap`, parsing avanzato o gestione sofisticata degli errori.

Il comportamento richiesto è:

- se il Resource Group non esiste, crearlo;
- se esiste, riutilizzarlo;
- applicare i tag `ManagedBy=Autonomo` e `UD=07`;
- mostrare nome, location e provisioning state.

Prima di eseguirlo, rileggi il file e verifica di comprendere ogni riga.

---

# Attività 2 — Scrivi l'equivalente PowerShell

In Cloud Shell PowerShell crea una procedura equivalente per:

```text
rg-ud07-auto-ps
```

Deve:

- verificare l'esistenza;
- creare solo se necessario;
- aggiungere/aggiornare tag;
- mostrare proprietà essenziali.

---

# Attività 3 — Activity Log

Dopo una modifica a uno dei due Resource Group:

- trova l'evento nell'Activity Log;
- identifica operazione;
- status;
- timestamp.

Non riportare `caller`.

---

# Attività 4 — KQL

Esegui nel workspace UD07 questa query:

```kusto
datatable(
  Component:string,
  Status:string,
  DurationMs:int
)
[
  "WEB","OK",120,
  "API","OK",180,
  "DB","WARN",430,
  "API","WARN",510
]
| summarize
    Requests=count(),
    AvgDuration=avg(DurationMs)
  by Status
| sort by AvgDuration desc
```

Rispondi:

1. quante righe aggregate produce?
2. quale stato ha latenza media più alta?
3. perché `summarize` cambia la granularità dei dati?

---

# Attività 5 — Metrics

Sul Resource Group principale individua lo Storage Account UD07 e:

1. elenca le metric definitions;
2. scegli una metrica;
3. indica unità;
4. aggregazione primaria;
5. prova a leggerla.

Se non ha ancora dati, documenta il fatto senza cambiare metrica per tentativi.

---

# Attività 6 — Analizza l'alert

Senza modificarlo, verifica:

- scope;
- condition;
- severity;
- evaluation frequency;
- Action Group presente/assente.

Spiega perché:

```text
alert rule configurata
```

non equivale necessariamente a:

```text
alert fired
```

---

# Attività 7 — Guasto amministrativo controllato

Esegui intenzionalmente:

```bash
az group show \
  --name rg-ud07-NON-ESISTE \
  --output table
```

Documenta:

```text
sintomo
tipo di errore
ipotesi
controllo
correzione
verifica
```

Non creare il Resource Group inesistente.

---

# Attività 8 — Scrivi un runbook

Titolo:

```text
RUNBOOK — Risorsa Azure non trovata o contesto errato
```

Deve contenere:

1. Sintomo
2. Controllo account/subscription
3. Controllo nome RG
4. Controllo resource ID/name
5. Activity Log
6. Interpretazione
7. Correzione minima
8. Verifica finale
9. Cleanup

---

# Attività 9 — Cleanup autonomo

Elimina:

```text
rg-ud07-auto
rg-ud07-auto-ps
```

Verifica che non esistano più.

Non eliminare il Resource Group principale UD07 prima della verifica finale della giornata.
