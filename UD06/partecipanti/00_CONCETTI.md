# UD06 — Concetti

# 1. Azure Compute

Con il termine **Compute** in Azure si indica l'insieme dei servizi che mettono a disposizione capacità di elaborazione per eseguire un workload. Il workload può essere un sistema operativo completo, un'applicazione Web, un insieme di container, una funzione eseguita in risposta a un evento oppure un'applicazione distribuita su più nodi.

Azure offre più servizi Compute perché non tutti i workload richiedono lo stesso livello di controllo. In alcuni casi serve amministrare direttamente il sistema operativo; in altri è preferibile delegare ad Azure la gestione dell'infrastruttura e concentrarsi sull'applicazione.

Tra i principali servizi Compute troviamo:

```text
Virtual Machines
App Service
Virtual Machine Scale Sets
Container Instances
Container Apps
AKS
Functions
```

In questa UD ci concentriamo su tre servizi che permettono di osservare bene la differenza tra gestione dell'infrastruttura e gestione dell'applicazione:

```text
VM
+
VM Scale Set
+
App Service
```

La **Virtual Machine** rappresenta il modello più vicino a un server tradizionale. Il **Virtual Machine Scale Set** estende questo modello permettendo di gestire più istanze VM in modo coordinato. **App Service**, invece, sposta l'attenzione dal server all'applicazione e rappresenta quindi un buon esempio di Platform as a Service.

---

# 2. IaaS e PaaS

Uno dei concetti più importanti del cloud è capire **chi gestisce che cosa**. Spostando un workload nel cloud non scompare la necessità di amministrare sistemi, applicazioni, sicurezza e aggiornamenti: cambia però il confine di responsabilità tra il cliente e il cloud provider.

## Virtual Machine

Una Virtual Machine Azure è un servizio **IaaS — Infrastructure as a Service**.

```text
IaaS
```

Azure mette a disposizione l'infrastruttura fisica e il livello di virtualizzazione necessario a eseguire la VM, ma il sistema operativo guest rimane sotto la responsabilità del cliente. Questo significa che chi gestisce la VM deve occuparsi di attività molto simili a quelle richieste da un server tradizionale:

- configurazione del sistema operativo;
- patch e aggiornamenti del guest OS;
- installazione e aggiornamento del software;
- configurazioni applicative;
- firewall del sistema operativo;
- controllo dei servizi che devono essere avviati e mantenuti operativi.

Se, ad esempio, una VM Linux espone un sito Web tramite Nginx, Azure fornisce la capacità di calcolo e la connettività, ma siamo noi a installare Nginx, configurarlo e verificare che il servizio sia in esecuzione.

## App Service

Azure App Service è invece un servizio **PaaS — Platform as a Service**.

```text
PaaS
```

In questo modello Azure gestisce una parte molto più ampia della piattaforma sottostante. Il cliente non deve amministrare una VM come server generico, ma può concentrarsi soprattutto sull'applicazione e sul modo in cui deve essere eseguita.

Le attività del cliente diventano quindi principalmente:

- deployment dell'applicazione;
- configurazione dell'ambiente applicativo;
- scelta della capacità necessaria;
- scaling;
- monitoraggio;
- gestione delle impostazioni applicative.

La differenza non è quindi semplicemente “VM contro sito Web”. È soprattutto una differenza di **livello di responsabilità**. Con IaaS manteniamo molto controllo ma anche più attività operative; con PaaS rinunciamo a parte del controllo sull'infrastruttura per ridurre il lavoro di amministrazione.

---

# 3. Componenti di una VM

Una VM Azure non deve essere immaginata come una singola risorsa isolata. Per funzionare utilizza più componenti che collaborano tra loro.

Una rappresentazione semplificata è la seguente:

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

L'**image** è la base da cui viene creato il sistema operativo della VM. Se scegliamo, per esempio, un'immagine Ubuntu Server, Azure utilizza quell'immagine per predisporre il disco di sistema e avviare la nuova macchina.

L'image rappresenta quindi il punto di partenza della VM, non la quantità di CPU o memoria disponibile.

## Size

La **size** definisce invece le caratteristiche computazionali della VM. In modo semplificato determina una combinazione di:

```text
vCPU
RAM
I/O
caratteristiche disponibili
```

Cambiare size significa quindi modificare la capacità della macchina. Una VM con più vCPU o più RAM può sostenere workload più impegnativi, ma normalmente comporta anche un costo maggiore.

Image e size rispondono quindi a due domande differenti:

```text
Image → quale sistema operativo/base software uso?
Size  → quante risorse di calcolo assegno alla VM?
```

## OS Disk

L'**OS Disk** contiene il sistema operativo della VM. È il disco dal quale il sistema viene avviato e sul quale risiedono i file necessari al funzionamento del guest OS.

## Data Disk

Un **Data Disk** è un disco aggiuntivo utilizzato per dati o applicazioni. Separare sistema operativo e dati può essere utile perché permette di progettare la gestione dello storage in modo più ordinato e indipendente dal disco di sistema.

## NIC

La **Network Interface Card**, o NIC, collega logicamente la VM alla rete virtuale Azure. Attraverso la NIC la VM riceve il proprio indirizzo IP privato e comunica con altre risorse della VNet.

Il Public IP, quando presente, non sostituisce la NIC: è una risorsa che consente di raggiungere dall'esterno la configurazione di rete associata alla VM. Anche NSG, subnet e indirizzamento concorrono quindi al comportamento della connettività.

---

# 4. VM e rete

Per capire perché una VM sia o non sia raggiungibile è utile ragionare sul **percorso del traffico**, invece di limitarsi a controllare se esiste un Public IP.

Un percorso molto semplificato dall'esterno verso un servizio eseguito sulla VM può essere rappresentato così:

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

Il Public IP rende possibile indirizzare traffico proveniente da Internet verso la risorsa, ma **non equivale ad autorizzare quel traffico e non garantisce che l'applicazione risponda**.

Perché una connessione abbia successo devono essere coerenti più livelli:

- il traffico deve poter seguire un percorso di rete valido;
- l'NSG deve consentire il protocollo, la porta e la sorgente richiesti;
- il firewall del sistema operativo non deve bloccare la connessione;
- il servizio applicativo deve essere avviato;
- il servizio deve essere in ascolto sulla porta prevista.

Questo permette di capire un principio fondamentale di troubleshooting: se una pagina Web non risponde, il problema non è necessariamente “la rete Azure”. Potrebbe essere Nginx non avviato, una porta errata, il firewall Linux, una regola NSG o un altro elemento del percorso.

Nel laboratorio useremo proprio questa logica: prima verificheremo che Nginx risponda localmente sulla VM e solo successivamente verificheremo l'accesso tramite rete. In questo modo possiamo isolare progressivamente il livello in cui si trova un eventuale problema.

---

# 5. SSH

Per amministrare una VM Linux si utilizza normalmente **SSH — Secure Shell**, che usa per impostazione tipica il protocollo TCP sulla porta 22.

```text
SSH
TCP 22
```

SSH permette di aprire una sessione remota cifrata sul sistema Linux. Per autenticarsi è preferibile utilizzare una coppia di chiavi crittografiche invece di affidarsi soltanto a una password.

La coppia è composta da:

```text
chiave privata
→ resta sul client

chiave pubblica
→ viene installata sulla VM
```

La chiave privata rappresenta la parte segreta dell'identità e deve restare sotto il controllo dell'utente. La chiave pubblica può invece essere copiata sulla VM perché serve al server per verificare l'autenticazione.

Quando il client tenta la connessione, non invia semplicemente la chiave privata al server: la utilizza per dimostrare di possedere la credenziale associata alla chiave pubblica presente sulla VM.

Per questo motivo la chiave privata **non deve mai essere pubblicata in un repository Git**, inserita nei materiali condivisi o copiata in posizioni accessibili ad altri utenti. La presenza della chiave privata in un repository costituirebbe un problema di sicurezza molto più grave della semplice esposizione di una configurazione.

---

# 6. Disponibilità

Quando un'applicazione deve essere affidabile non è sufficiente avere “una VM potente”. Occorre progettare cosa deve accadere quando un componente hardware, una singola istanza o parte dell'infrastruttura non è disponibile.

Azure offre modelli differenti di disponibilità. È importante non considerarli sinonimi, perché risolvono problemi diversi.

## Availability Zone

Le **Availability Zone** sono zone fisicamente separate all'interno della stessa regione Azure.

```text
Region
├── Zone 1
├── Zone 2
└── Zone 3
```

L'idea è evitare che tutte le istanze di un workload dipendano dalla stessa zona fisica. Se più istanze vengono distribuite tra zone differenti, un problema che interessa una singola zona può avere un impatto minore sull'intero servizio.

Una singola VM collocata in una Availability Zone, però, rimane comunque una singola VM: la zona da sola non crea automaticamente ridondanza applicativa. Per ottenere vera continuità del servizio occorre progettare più istanze o altri meccanismi di disponibilità.

## Availability Set

Un **Availability Set** è un modello differente che distribuisce più VM tra **Fault Domain** e **Update Domain**.

```text
Fault Domain
Update Domain
```

Il Fault Domain serve a ridurre il rischio che tutte le VM dipendano dallo stesso insieme di componenti fisici. L'Update Domain permette invece di distribuire le istanze in modo che attività di manutenzione pianificata non coinvolgano necessariamente tutte le VM nello stesso momento.

Availability Set e Availability Zone perseguono quindi lo stesso obiettivo generale — aumentare la disponibilità — ma attraverso modelli architetturali diversi.

## VM Scale Set

Un **Virtual Machine Scale Set** gestisce un insieme di istanze VM secondo una configurazione coordinata.

```text
VM Scale Set
├── VM 1
├── VM 2
└── VM 3
```

Il vantaggio non è soltanto “avere tre VM”. Il Scale Set permette di trattare quelle istanze come una capacità elastica che può essere aumentata o ridotta secondo necessità.

Può quindi supportare:

- gestione coordinata delle istanze;
- aumento o riduzione del numero di VM;
- integrazione con meccanismi di autoscaling.

Il VM Scale Set è particolarmente importante quando il carico può variare nel tempo e il workload è progettato per funzionare su più istanze.

---

# 7. Scale up e scale out

Quando un sistema non dispone di capacità sufficiente abbiamo, in termini generali, due strategie: rendere più potente l'istanza esistente oppure aumentare il numero di istanze.

## Scale up

**Scale up**, o scaling verticale, significa assegnare più risorse alla stessa istanza.

```text
2 vCPU
↓
4 vCPU
```

La macchina rimane logicamente la stessa, ma dispone di maggiore capacità. È un approccio intuitivo, ma ha limiti pratici: ogni famiglia di VM ha dimensioni massime e una singola istanza continua a rappresentare un singolo punto operativo.

## Scale out

**Scale out**, o scaling orizzontale, significa aumentare il numero delle istanze che collaborano all'esecuzione del workload.

```text
1 VM
↓
3 VM
```

In questo caso il carico può essere distribuito tra più macchine. Questo modello si presta meglio all'elasticità e alla disponibilità, ma richiede che l'applicazione sia progettata per funzionare correttamente su più istanze.

Una regola mnemonica utile rimane:

```text
UP  → istanza più potente
OUT → più istanze
```

La scelta tra scale up e scale out non è puramente tecnica: coinvolge architettura dell'applicazione, disponibilità, costi e modalità con cui il workload gestisce lo stato.

---

# 8. Autoscaling VM

Lo scale out può essere eseguito manualmente, ma in ambienti reali il carico spesso cambia durante la giornata. Azure Monitor Autoscale consente di modificare automaticamente il numero di istanze di un VM Scale Set utilizzando regole basate su metriche o pianificazioni.

Una regola può tenere conto di:

- una metrica, per esempio la CPU;
- una soglia;
- un intervallo temporale durante il quale la condizione deve persistere;
- un'azione di incremento o riduzione;
- una schedule, quando la variazione di capacità è prevedibile.

Esempio concettuale:

```text
CPU media > 70%
per 5 minuti
       ↓
aggiungi istanze
```

L'intervallo temporale è importante. Se scalassimo il sistema alla prima oscillazione momentanea della CPU, potremmo creare e rimuovere istanze troppo frequentemente. L'autoscaling deve reagire a una condizione significativa, non necessariamente a ogni picco istantaneo.

Un profilo di autoscaling specifica anche i limiti entro i quali Azure può operare:

```text
minimum: 1
default: 1
maximum: 3
```

`minimum` rappresenta la capacità minima che deve rimanere disponibile. `maximum` impedisce allo scaling di crescere senza controllo. Il limite massimo è importante sia dal punto di vista tecnico sia dal punto di vista economico: aumentare le istanze significa normalmente aumentare anche il costo.

Un esempio di configurazione CLI è:

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

In questa UD il comando serve soprattutto a riconoscere i parametri di una configurazione di autoscaling. Il punto centrale non è memorizzare la sintassi, ma capire che una policy definisce **limiti, condizioni e comportamento** del sistema.

---

# 9. Lifecycle della VM

Lo stato di una VM incide sia sul funzionamento sia sui costi. In particolare non bisogna confondere una VM semplicemente arrestata con una VM deallocata.

```text
Stopped
```

non è equivalente a:

```text
Stopped (deallocated)
```

`az vm stop` arresta il sistema operativo guest. Dal punto di vista del sistema è simile allo spegnimento della macchina, ma la capacità compute può rimanere allocata nell'infrastruttura Azure.

`az vm deallocate`, invece, rilascia la compute allocation associata alla VM. È questa differenza che rende la deallocazione particolarmente importante quando si vuole interrompere il costo della componente compute.

Deallocare una VM non significa però eliminare tutte le risorse associate. Possono continuare a esistere e quindi a generare costi, a seconda della configurazione:

- dischi;
- backup;
- indirizzi IP secondo configurazione/SKU;
- altri servizi collegati.

Il principio da ricordare è quindi:

```text
Deallocated
≠
risorsa eliminata
```

La VM continua a esistere come configurazione e conserva le risorse persistenti necessarie a poter essere nuovamente avviata.

---

# 10. App Service

Azure App Service è un servizio PaaS destinato all'esecuzione di applicazioni Web e API. Rispetto alla VM, l'obiettivo è evitare al cliente molte attività di gestione del server sottostante.

Per comprendere App Service è fondamentale distinguere **App Service Plan** e **Web App**.

Una rappresentazione semplificata è:

```text
App Service Plan
├── Web App A
└── Web App B
```

## App Service Plan

L'**App Service Plan** definisce l'ambiente di capacità sul quale vengono eseguite le applicazioni. Tra gli elementi rilevanti troviamo:

- regione;
- sistema operativo;
- tier;
- capacità;
- funzionalità disponibili.

Il Plan è quindi la parte che determina principalmente **quali risorse e funzionalità sono disponibili per l'esecuzione**.

## Web App

La **Web App** rappresenta invece l'applicazione ospitata. Contiene la configurazione applicativa, il deployment e gli elementi necessari a pubblicare il workload Web.

La distinzione è importante anche dal punto di vista economico e operativo: non bisogna immaginare che ogni Web App equivalga necessariamente a un server autonomo. Più Web App possono essere associate allo stesso App Service Plan e condividere la capacità del piano.

In forma sintetica:

```text
App Service Plan → capacità e caratteristiche della piattaforma
Web App          → applicazione che utilizza quella piattaforma
```

---

# 11. Scaling App Service

Anche App Service può essere scalato verticalmente oppure orizzontalmente, ma il meccanismo viene applicato alla piattaforma gestita invece che a una VM amministrata direttamente dal cliente.

## Scale up

Lo **scale up** consiste nel passare a un tier o a una capacità superiore.

```text
piano piccolo
↓
piano più potente
```

L'obiettivo è mettere a disposizione maggiore capacità per ogni istanza o funzionalità aggiuntive previste dal tier.

## Scale out

Lo **scale out** aumenta invece il numero delle istanze che eseguono l'applicazione.

```text
1 istanza
↓
3 istanze
```

Più istanze permettono di distribuire il carico e possono aumentare la capacità complessiva dell'applicazione.

Per lo scale out esistono modalità differenti.

### Manuale

Nello scaling manuale siamo noi a impostare il numero di istanze. È semplice da comprendere, ma richiede un intervento umano quando il carico aumenta o diminuisce.

### Azure Monitor Autoscale

Con **Azure Monitor Autoscale** il numero di istanze viene modificato sulla base di regole definite esplicitamente. Le regole possono utilizzare:

- metriche;
- soglie;
- finestre temporali;
- schedule.

Il concetto è analogo a quello visto per i VM Scale Set: osserviamo una condizione e definiamo come deve cambiare la capacità quando quella condizione si verifica.

La disponibilità di questa funzione dipende dal tier utilizzato.

### Automatic Scaling

**Automatic Scaling** è una modalità distinta da Azure Monitor Autoscale. In questo caso la piattaforma gestisce lo scaling in modo maggiormente orientato al traffico, usando parametri specifici della capacità dell'applicazione.

Tra i concetti che si possono incontrare troviamo:

```text
Always ready
Maximum burst
Maximum scale limit
Prewarmed instances
```

Non è necessario in questa UD approfondire ogni parametro operativo. È invece importante comprendere che **Automatic Scaling e Azure Monitor Autoscale non sono due nomi della stessa funzione**: rappresentano modelli di scaling differenti.

Anche in questo caso la disponibilità dipende dal tier. Nel laboratorio non viene richiesto di acquistare un tier Premium soltanto per osservare queste funzionalità: l'obiettivo è comprenderne il modello, non generare costi inutili.

---

# 12. Deployment slot

Una Web App può disporre di più **deployment slot**, per esempio:

```text
production
staging
```

Lo slot `production` rappresenta normalmente l'ambiente che riceve il traffico reale. Uno slot `staging` può invece ospitare una nuova versione dell'applicazione prima che venga resa disponibile agli utenti.

Il vantaggio è poter distribuire e validare la nuova versione in un ambiente separato, pur rimanendo all'interno della stessa Web App. Dopo le verifiche è possibile effettuare uno **swap** tra gli slot.

Il concetto da comprendere è quindi che lo slot riduce il rischio di distribuire direttamente una nuova versione sull'ambiente di produzione senza averla prima verificata.

La disponibilità degli slot dipende dal tier utilizzato.

---

# 13. Azure Monitor

Gestire un workload significa anche poter osservare ciò che sta accadendo. Azure Monitor è il servizio di riferimento per la raccolta e l'analisi della telemetria proveniente dalle risorse Azure.

Una visione semplificata è:

```text
Risorsa Azure
   |
   +------ Metrics
   |
   +------ Logs
```

Questa distinzione è importante perché metriche e log rappresentano due modi diversi di osservare il sistema.

## Metrics

Le **Metrics** sono valori numerici associati al tempo. Permettono di rispondere rapidamente a domande come:

- quanto è stata utilizzata la CPU?
- quanto traffico di rete è entrato o uscito?
- quante richieste ha ricevuto una Web App?
- come è cambiato il tempo di risposta nell'ultima ora?

Per una VM possiamo osservare, ad esempio:

```text
Percentage CPU
Network In
Network Out
Disk operations
```

Per App Service possiamo trovare metriche come:

```text
Requests
CPU Time
Response Time
HTTP status
```

Metrics Explorer consente di rappresentare queste serie temporali, cambiare intervallo temporale e aggregazione e confrontare metriche diverse.

La parte importante non è limitarsi a leggere un numero. Una metrica deve essere interpretata nel tempo. Una CPU al 90% per pochi secondi può avere un significato molto diverso da una CPU al 90% per un periodo prolungato.

---

# 14. Log Analytics

Le metriche sono molto utili per osservare tendenze numeriche, ma spesso per capire **perché** è successo qualcosa abbiamo bisogno di informazioni più dettagliate.

Un **Log Analytics workspace** è un datastore nel quale possono essere raccolti dati di log provenienti da risorse Azure e non Azure.

I dati possono essere interrogati utilizzando:

```text
KQL
Kusto Query Language
```

In questa UD non è necessario diventare operativi su KQL. È però fondamentale distinguere il ruolo delle metriche da quello dei log:

```text
Metrics
→ valori numerici nel tempo
→ utili per trend, soglie, grafici e alert

Logs
→ record interrogabili
→ utili per ricerca, correlazione e analisi dettagliata
```

Un grafico può mostrarci che il numero di errori è aumentato; i log possono aiutarci a capire quali richieste, componenti o condizioni hanno prodotto quegli errori.

La parte operativa relativa a Log Analytics e KQL viene approfondita nella UD07.

---

# 15. Monitorare non significa fare backup

Monitoraggio e backup vengono talvolta associati perché entrambi riguardano l'affidabilità del sistema, ma hanno scopi completamente diversi.

Il **monitoraggio** ci permette di osservare il comportamento del workload:

```text
"osservo lo stato e ciò che sta accadendo"
```

Il **backup** serve invece a conservare stati recuperabili nel tempo:

```text
"creo punti da cui posso recuperare dati o sistemi"
```

Monitorare una VM non crea automaticamente una copia recuperabile dei suoi dati. Allo stesso modo, avere un backup non ci dice in tempo reale che la CPU è satura o che l'applicazione sta rispondendo lentamente.

Sono quindi strumenti complementari, ma rispondono a domande differenti:

```text
Monitoraggio → cosa sta succedendo?
Backup       → da quale stato posso recuperare?
```

---

# 16. Azure Backup

Per proteggere una VM Azure da perdita o corruzione dei dati può essere utilizzato Azure Backup.

Il flusso concettuale può essere rappresentato così:

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

Questi elementi hanno ruoli distinti.

## Recovery Services vault

Il **Recovery Services vault** è una risorsa utilizzata per organizzare e gestire la protezione e i recovery point associati ai workload supportati.

Non bisogna pensarlo semplicemente come “una cartella contenente file di backup”. È una risorsa Azure che partecipa alla gestione del ciclo di protezione.

## Backup policy

La **Backup Policy** stabilisce come deve essere eseguita la protezione. Definisce, tra l'altro:

- frequenza;
- schedule;
- retention.

In altre parole, la policy stabilisce **quando eseguire il backup e per quanto tempo conservarne i punti di ripristino**.

Una retention più lunga permette di tornare più indietro nel tempo, ma implica anche una maggiore quantità di dati conservati. La progettazione di una policy deve quindi derivare dai requisiti del servizio e non da valori scelti casualmente.

## Recovery point

Un **Recovery Point** rappresenta uno stato recuperabile prodotto dal processo di backup.

Quando dobbiamo ripristinare, non “torniamo indietro nel tempo” in modo astratto: scegliamo uno dei recovery point disponibili e lo utilizziamo come riferimento per il recupero.

Il primo backup può essere avviato:

```text
secondo schedule
```

oppure manualmente attraverso:

```text
Backup now
```

Nel laboratorio non è necessario completare realmente il backup. L'obiettivo è riconoscere il workflow e capire il rapporto tra vault, policy e recovery point.

---

# 17. Backup non è disponibilità

Avere un backup non significa che il servizio rimanga disponibile durante un guasto.

Supponiamo di avere una sola VM e di eseguirne regolarmente il backup. Se quella VM diventa indisponibile, il backup può permetterci di recuperare uno stato precedente, ma durante il tempo necessario al ripristino l'applicazione può comunque essere offline.

Per questo bisogna distinguere:

```text
Backup
→ capacità di recuperare dati o stato

Availability
→ capacità di ridurre o evitare l'interruzione del servizio
```

La disponibilità cerca quindi di mantenere il servizio operativo o di ridurre il downtime. Il backup interviene invece quando abbiamo bisogno di recuperare uno stato.

Un'architettura affidabile può richiedere entrambi.

---

# 18. Disaster Recovery

La **Disaster Recovery**, o DR, riguarda la capacità di ripristinare un workload dopo un evento sufficientemente grave da compromettere l'ambiente principale.

Non stiamo quindi parlando soltanto del guasto di una singola VM. Il problema può coinvolgere una parte più ampia dell'infrastruttura e richiedere il ripristino del servizio in un ambiente alternativo.

Azure Site Recovery può orchestrare concetti come:

- **replication**, cioè mantenere una copia coerente del workload verso l'ambiente di recovery;
- **failover**, cioè attivare il workload nell'ambiente di recovery quando quello primario non è utilizzabile;
- **failback**, cioè riportare il workload verso l'ambiente primario quando le condizioni lo consentono.

Schema concettuale:

```text
Region A
VM primaria
    |
 replica
    v
Region B
VM/risorse di recovery
```

La replica non deve essere confusa con un normale backup. Nel DR l'obiettivo principale è poter **ripristinare il servizio** secondo tempi e livelli di perdita dati definiti.

---

# 19. HA vs Backup vs DR

High Availability, Backup e Disaster Recovery partecipano tutti alla resilienza di un sistema, ma non sono intercambiabili.

| Obiettivo | Tecnologia/concetto |
|---|---|
| ridurre il downtime dovuto al guasto di componenti | High Availability |
| recuperare dati o uno stato precedente | Backup |
| ripristinare il workload dopo un evento grave | Disaster Recovery |

Possiamo immaginarli attraverso tre domande differenti.

**High Availability:** cosa succede se una singola istanza o un componente smette di funzionare? Il sistema dovrebbe continuare a erogare il servizio, magari attraverso un'altra istanza.

**Backup:** cosa succede se devo recuperare dati cancellati, corrotti o uno stato precedente? Ho bisogno di un recovery point valido.

**Disaster Recovery:** cosa succede se l'ambiente principale non è più utilizzabile? Devo poter ripristinare il workload in un ambiente alternativo.

Lo schema sintetico rimane:

```text
HA
→ continuo a funzionare

Backup
→ recupero uno stato

DR
→ ripristino il servizio in un'altra condizione/location
```

Un progetto serio può richiedere tutti e tre i livelli contemporaneamente. Il backup non sostituisce l'HA; l'HA non sostituisce il DR; il DR non elimina la necessità di conservare recovery point adeguati.

---

# 20. RPO e RTO

Quando si progetta una strategia di backup o Disaster Recovery non basta dichiarare che “il servizio deve essere protetto”. Occorre trasformare il requisito in valori misurabili.

Due indicatori fondamentali sono **RPO** e **RTO**.

## RPO — Recovery Point Objective

L'RPO indica quanta perdita di dati può essere accettata, espressa come intervallo temporale.

Esempio:

```text
RPO = 1 ora
```

Significa che, in caso di evento grave, il requisito accetta al massimo la perdita dei dati prodotti nell'ultima ora.

Se l'ultimo punto recuperabile risale a tre ore prima, non stiamo rispettando un RPO di un'ora.

L'RPO influenza quindi la frequenza con cui dobbiamo proteggere o replicare i dati.

## RTO — Recovery Time Objective

L'RTO indica quanto tempo può trascorrere prima che il servizio torni operativo dopo un'interruzione.

Esempio:

```text
RTO = 30 minuti
```

Significa che il processo di recovery deve consentire al servizio di tornare operativo entro trenta minuti dal momento considerato nel piano di continuità.

RPO e RTO misurano quindi due aspetti differenti:

```text
RPO → quanti dati posso perdere?
RTO → quanto tempo posso restare fermo?
```

Un RPO molto basso e un RTO molto basso richiedono normalmente un'architettura più sofisticata e possono comportare costi maggiori.

---

# 21. Troubleshooting VM

Il troubleshooting deve essere eseguito in modo ordinato. Modificare contemporaneamente NSG, firewall, applicazione e routing rende difficile capire quale modifica abbia realmente risolto il problema e può introdurre nuove vulnerabilità.

Per una VM che non risponde possiamo seguire una sequenza dal livello più generale verso quello applicativo:

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

La logica della sequenza è importante.

Se la VM non è in esecuzione, non ha senso iniziare dal DNS. Se Nginx non è attivo, aprire ulteriormente l'NSG non farà comparire il sito. Se il servizio risponde su `localhost` ma non dal client remoto, abbiamo già raccolto un'informazione molto utile: l'applicazione probabilmente funziona e il problema va cercato nel percorso di rete o nei controlli di accesso.

Per questo motivo non bisogna aprire `Any` su tutte le porte semplicemente “per vedere se funziona”. Una regola eccessivamente permissiva può nascondere il problema invece di diagnosticarlo e introduce un rischio di sicurezza.

Un buon troubleshooting modifica **una variabile alla volta**, esegue un test e registra il risultato.

---

# 22. Network Watcher e IP Flow Verify

Network Watcher mette a disposizione strumenti utili per analizzare il comportamento della rete Azure. In questa UD utilizziamo in particolare **IP Flow Verify**.

IP Flow Verify permette di verificare, per uno specifico flusso di traffico associato a una VM, se la configurazione di rete porta a un risultato:

```text
Allowed
```

oppure:

```text
Denied
```

Quando possibile può anche indicare la regola responsabile della decisione.

Questo è particolarmente utile nel troubleshooting degli NSG perché consente di passare dalla domanda generica “la rete funziona?” a una domanda precisa:

```text
Questo traffico TCP,
da questa sorgente,
verso questa VM e questa porta,
viene consentito o negato?
```

IP Flow Verify non dimostra però che l'applicazione stia realmente funzionando. Se il traffico verso la porta 80 risulta `Allowed` ma Nginx è fermo, la pagina continuerà a non rispondere.

Lo strumento verifica quindi **una parte del percorso**, non l'intero comportamento end-to-end del servizio.

---

# 23. Costi

Nel cloud il costo non dipende da un unico oggetto. Una soluzione può essere composta da più risorse, ciascuna con il proprio modello di consumo.

Per una VM, tra gli elementi da considerare troviamo:

```text
size
tempo compute
dischi
IP
backup
rete
```

La size incide sulla capacità assegnata e quindi sul costo della componente compute. Arrestare la VM non significa necessariamente eliminare tutti i costi, perché dischi e altri servizi possono rimanere presenti.

Per App Service incidono soprattutto elementi come:

```text
tier del piano
numero istanze
servizi collegati
```

Questo spiega perché la scelta del tier non deve essere fatta soltanto in base alle funzionalità disponibili: è anche una scelta economica.

L'autoscaling introduce infine una relazione diretta tra domanda, capacità e costo:

```text
più istanze
→ più capacità
→ potenziale aumento costo
```

L'autoscaling non deve quindi essere interpretato come un meccanismo che “fa risparmiare automaticamente”. Può ridurre capacità quando non serve, ma può anche aumentarla quando il carico cresce. Per questo sono importanti soglie coerenti e limiti massimi.

Una buona progettazione cloud tiene sempre insieme tre dimensioni:

```text
prestazioni
+
disponibilità
+
costo
```

Ottimizzare una sola delle tre senza considerare le altre può produrre una soluzione tecnicamente funzionante ma poco sostenibile.

---

# 24. Domande di controllo

Le domande seguenti servono a verificare non soltanto la memorizzazione dei termini, ma soprattutto la capacità di collegare i concetti studiati durante la UD.

1. Quali risorse e componenti principali costituiscono una VM Azure e quale ruolo svolge ciascuno?
2. Perché la presenza di un Public IP non garantisce che un servizio sulla VM sia raggiungibile da Internet?
3. Distingui Availability Zone, Availability Set e VM Scale Set, spiegando quale problema affronta ciascuno.
4. Qual è la differenza tra scale up e scale out?
5. Come può Azure Monitor Autoscale modificare un VM Scale Set e perché sono importanti soglie e limiti minimo/massimo?
6. Qual è la differenza tra App Service Plan e Web App?
7. Qual è la differenza concettuale tra Azure Monitor Autoscale e App Service Automatic Scaling?
8. Distingui Metrics e Logs/Log Analytics e indica che tipo di informazione fornisce ciascuno.
9. Qual è il ruolo di Recovery Services vault, backup policy e recovery point e come sono collegati?
10. Distingui High Availability, Backup e Disaster Recovery utilizzando un esempio di esigenza per ciascuno.
11. Che cosa indicano RPO e RTO e perché rappresentano due requisiti diversi?
12. Perché una VM `deallocated` può continuare a generare costi?
