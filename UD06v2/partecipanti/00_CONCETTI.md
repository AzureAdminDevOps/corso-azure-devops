# UD06 — Concetti

# 1. Azure Compute

Compute indica i servizi che eseguono workload.

Esempi:

```text
Virtual Machines
App Service
Virtual Machine Scale Sets
Container Instances
Container Apps
AKS
Functions
```

In questa UD ci concentriamo su:

```text
VM
+
VM Scale Set
+
App Service
```

---

# 2. IaaS e PaaS

## Virtual Machine

```text
IaaS
```

Il cliente gestisce:

- sistema operativo;
- patch del guest OS;
- software;
- configurazioni applicative;
- firewall del sistema operativo.

Azure gestisce l'infrastruttura fisica sottostante.

## App Service

```text
PaaS
```

Azure gestisce una parte maggiore della piattaforma.

Il cliente si concentra maggiormente su:

- applicazione;
- configurazione;
- deployment;
- scaling;
- monitoraggio.

---

# 3. Componenti di una VM

```text
VM
├── Image
├── Size
├── OS Disk
├── Data Disk opzionale
└── NIC
    ├── Private IP
    ├── Public IP opzionale
    ├── Subnet
    └── NSG
```

## Image

Definisce la base del sistema operativo.

## Size

Definisce una combinazione di:

```text
vCPU
RAM
I/O
caratteristiche disponibili
```

## OS Disk

Contiene il sistema operativo.

## Data Disk

Volume aggiuntivo destinato a dati/applicazioni.

---

# 4. VM e rete

Percorso semplificato:

```text
Internet
   |
Public IP
   |
NSG
   |
NIC
   |
VM
   |
servizio
```

Un Public IP **non garantisce** la raggiungibilità.

Servono anche:

- routing coerente;
- NSG coerente;
- firewall OS coerente;
- servizio in ascolto;
- porta corretta.

---

# 5. SSH

Per Linux:

```text
SSH
TCP 22
```

Meglio una coppia di chiavi:

```text
chiave privata
→ resta sul client

chiave pubblica
→ viene installata sulla VM
```

La chiave privata non deve essere caricata su Git.

---

# 6. Disponibilità

## Availability Zone

Zone fisicamente separate nella stessa regione.

```text
Region
├── Zone 1
├── Zone 2
└── Zone 3
```

## Availability Set

Distribuisce più VM tra:

```text
Fault Domain
Update Domain
```

È un modello di disponibilità differente dalle Availability Zone.

## VM Scale Set

Gestisce un insieme di istanze VM.

```text
VM Scale Set
├── VM 1
├── VM 2
└── VM 3
```

Può supportare:

- crescita/riduzione del numero di istanze;
- gestione coordinata;
- autoscaling.

---

# 7. Scale up e scale out

## Scale up

Istanza più potente.

```text
2 vCPU
↓
4 vCPU
```

## Scale out

Più istanze.

```text
1 VM
↓
3 VM
```

Regola:

```text
UP  → più potente
OUT → più numerose
```

---

# 8. Autoscaling VM

Azure Monitor Autoscale può modificare il numero di istanze di un VM Scale Set sulla base di:

- metriche;
- soglie;
- intervalli temporali;
- schedule.

Esempio:

```text
CPU media > 70%
per 5 minuti
       ↓
aggiungi istanze
```

Profilo concettuale:

```text
minimum: 1
default: 1
maximum: 3
```

Il limite massimo è importante anche per i costi.

Esempio CLI:

```bash
az monitor autoscale create \
  --resource-group <RG> \
  --resource <VMSS> \
  --resource-type Microsoft.Compute/virtualMachineScaleSets \
  --name autoscale \
  --min-count 1 \
  --max-count 3 \
  --count 1
```

---

# 9. Lifecycle della VM

Non confondere:

```text
Stopped
```

con:

```text
Stopped (deallocated)
```

`az vm stop` arresta il guest.

`az vm deallocate` rilascia la compute allocation.

Possibili costi residui dopo deallocate:

- dischi;
- backup;
- indirizzi IP secondo configurazione/SKU;
- altri servizi collegati.

---

# 10. App Service

Azure App Service è un PaaS per applicazioni Web e API.

Schema:

```text
App Service Plan
├── Web App A
└── Web App B
```

## App Service Plan

Definisce:

- regione;
- sistema operativo;
- tier;
- capacità;
- funzionalità disponibili.

## Web App

Rappresenta l'applicazione ospitata.

---

# 11. Scaling App Service

App Service può essere scalato:

## Scale up

Cambio di tier/capacità.

```text
piano piccolo
↓
piano più potente
```

## Scale out

Aumento delle istanze.

```text
1 istanza
↓
3 istanze
```

Esistono più modalità di scale-out.

### Manuale

Numero di istanze impostato manualmente.

### Azure Monitor Autoscale

Scaling basato su:

- metriche;
- regole;
- schedule.

È disponibile dai tier che lo supportano.

### Automatic Scaling

Modalità traffic-based gestita dalla piattaforma.

È distinta da Azure Monitor Autoscale.

Concetti:

```text
Always ready
Maximum burst
Maximum scale limit
Prewarmed instances
```

La disponibilità dipende dal tier.

Nel laboratorio non viene richiesto di acquistare un tier Premium solo per provare questa funzione.

---

# 12. Deployment slot

Una Web App può utilizzare slot, per esempio:

```text
production
staging
```

Uno slot permette di validare una versione prima dello swap.

La disponibilità dipende dal tier.

---

# 13. Azure Monitor

Azure Monitor raccoglie e analizza telemetria.

Schema semplificato:

```text
Risorsa Azure
   |
   +------ Metrics
   |
   +------ Logs
```

## Metrics

Dati numerici nel tempo.

Esempi VM:

```text
Percentage CPU
Network In
Network Out
Disk operations
```

Esempi App Service:

```text
Requests
CPU Time
Response Time
HTTP status
```

Metrics Explorer permette di visualizzare e confrontare metriche.

---

# 14. Log Analytics

Un **Log Analytics workspace** è un datastore per dati log raccolti da risorse Azure e non Azure.

I log possono essere interrogati con:

```text
KQL
Kusto Query Language
```

In questa UD è sufficiente comprendere:

```text
Metrics
→ valori numerici temporali

Logs
→ record interrogabili
```

La parte operativa Log Analytics/KQL viene approfondita in UD07.

---

# 15. Monitorare non significa fare backup

Monitoraggio:

```text
"osservo lo stato"
```

Backup:

```text
"creo punti da cui recuperare dati"
```

Sono obiettivi differenti.

---

# 16. Azure Backup

Per proteggere VM Azure si può usare Azure Backup.

Schema:

```text
VM
 |
Azure Backup
 |
Recovery Services vault
 |
Backup Policy
 |
Recovery Point
```

## Recovery Services vault

Risorsa di gestione della protezione e dei recovery point.

## Backup policy

Definisce, tra l'altro:

- frequenza;
- schedule;
- retention.

## Recovery point

Stato recuperabile prodotto dal backup.

Il primo backup può essere avviato:

```text
secondo schedule
```

oppure:

```text
Backup now
```

---

# 17. Backup non è disponibilità

Una VM con backup può comunque essere indisponibile durante un guasto.

```text
Backup
→ recupero

Availability
→ riduzione/interruzione del downtime
```

---

# 18. Disaster Recovery

Disaster Recovery riguarda il ripristino del servizio dopo un evento significativo.

Azure Site Recovery può orchestrare:

- replica;
- failover;
- failback.

Esempio concettuale:

```text
Region A
VM primaria
    |
 replica
    v
Region B
VM/risorse di recovery
```

---

# 19. HA vs Backup vs DR

| Obiettivo | Tecnologia/concetto |
|---|---|
| ridurre downtime di componenti | High Availability |
| recuperare dati/stati | Backup |
| ripristinare workload dopo disastro | Disaster Recovery |

Schema:

```text
HA
→ continuo a funzionare

Backup
→ recupero uno stato

DR
→ ripristino il servizio in un'altra condizione/location
```

---

# 20. RPO e RTO

## RPO — Recovery Point Objective

Quanta perdita di dati è accettabile.

Esempio:

```text
RPO = 1 ora
```

## RTO — Recovery Time Objective

Quanto tempo può impiegare il servizio a tornare operativo.

Esempio:

```text
RTO = 30 minuti
```

---

# 21. Troubleshooting VM

Metodo:

```text
1. VM Running?
2. IP corretto?
3. NSG?
4. route?
5. firewall OS?
6. servizio attivo?
7. porta in ascolto?
8. DNS, se usato?
```

Non aprire `Any` su tutte le porte per "vedere se funziona".

---

# 22. Network Watcher e IP Flow Verify

IP Flow Verify aiuta a determinare se uno specifico flusso verso una VM viene:

```text
Allowed
```

oppure:

```text
Denied
```

e può indicare la regola responsabile.

Non dimostra però da solo che l'applicazione stia funzionando.

---

# 23. Costi

VM:

```text
size
tempo compute
dischi
IP
backup
rete
```

App Service:

```text
tier del piano
numero istanze
servizi collegati
```

Autoscaling:

```text
più istanze
→ più capacità
→ potenziale aumento costo
```

---

# 24. Domande di controllo

1. Quali risorse e componenti principali costituiscono una VM Azure?
2. Perché Public IP e raggiungibilità non sono sinonimi?
3. Distingui Availability Zone, Availability Set e VM Scale Set.
4. Qual è la differenza tra scale up e scale out?
5. Come può Azure Monitor Autoscale modificare un VM Scale Set?
6. Qual è la differenza tra App Service Plan e Web App?
7. Qual è la differenza tra Azure Monitor Autoscale e App Service Automatic Scaling?
8. Distingui Metrics e Logs/Log Analytics.
9. Qual è il ruolo di Recovery Services vault, backup policy e recovery point?
10. Distingui High Availability, Backup e Disaster Recovery.
11. Che cosa indicano RPO e RTO?
12. Perché una VM `deallocated` può continuare a generare costi?
