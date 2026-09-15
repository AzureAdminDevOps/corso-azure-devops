# UD07 — Concetti
## Amministrare Azure in modo ripetibile, osservare ciò che accade e diagnosticare i problemi

Nelle UD precedenti abbiamo creato e configurato risorse Azure utilizzando soprattutto il Portale e, progressivamente, alcuni comandi CLI. In questa unità facciamo un passo diverso: non ci interessa soltanto **creare** una risorsa, ma imparare a **interrogarla, modificarla, osservare ciò che Azure registra e costruire una procedura di troubleshooting ripetibile**.

È un passaggio importante nel lavoro reale di un amministratore. Quando si gestiscono poche risorse, il Portale può sembrare sufficiente. Quando invece bisogna ripetere la stessa operazione, confrontare configurazioni, raccogliere evidenze o capire perché qualcosa non funziona, diventa necessario utilizzare strumenti che producano risultati leggibili e ripetibili.

In questa UD lavoreremo quindi con quattro elementi che devono essere tenuti distinti ma collegati:

```text
Azure CLI / Azure PowerShell
        ↓
amministrazione ripetibile
        ↓
Azure Monitor
        ↓
metriche, log, alert e troubleshooting
```

L'obiettivo non è imparare a memoria molti comandi. L'obiettivo è capire **che cosa stiamo chiedendo ad Azure**, quale informazione ci restituisce e come usare quella informazione per prendere una decisione.

---

# 1. Azure CLI: dal clic al comando ripetibile

Azure CLI è l'interfaccia a riga di comando multipiattaforma di Azure. Il comando principale è:

```text
az
```

e viene seguito da un gruppo, eventualmente da un sottogruppo, e infine dall'azione da eseguire.

Per esempio:

```bash
az group show --name rg-demo
```

può essere letto quasi come una frase:

```text
Azure
→ Resource Group
→ mostrami
→ quello chiamato rg-demo
```

Questa lettura è utile perché evita di percepire la CLI come una sequenza arbitraria di parole da memorizzare. Molti comandi seguono infatti lo stesso modello:

```text
az <risorsa o servizio> <azione> [parametri]
```

Esempi:

```bash
az group list
az storage account show
az vm list
az monitor activity-log list
```

Quando non ricordiamo un comando è preferibile usare l'help:

```bash
az group --help
az monitor activity-log --help
```

piuttosto che procedere per tentativi.

## Perché usare la CLI se esiste il Portale?

Il Portale è molto utile per esplorare e comprendere visivamente una risorsa. La CLI diventa particolarmente utile quando vogliamo:

- ripetere la stessa operazione;
- ottenere sempre lo stesso tipo di output;
- filtrare soltanto le informazioni che ci servono;
- documentare una procedura;
- inserire i comandi in uno script;
- confrontare rapidamente più risorse.

Un buon amministratore Azure non deve scegliere "Portale oppure CLI". Deve sapere **quando è più conveniente usare l'uno o l'altra**.

---

# 2. L'output: non sempre vogliamo vedere tutto

Molti comandi Azure CLI restituiscono una quantità notevole di dati. Il formato naturale è JSON, perché le risorse Azure sono oggetti strutturati con proprietà, sotto-proprietà e collezioni.

Possiamo chiedere diversi formati:

```text
json
jsonc
table
tsv
yaml
```

Per esempio:

```bash
az group list --output table
```

produce una tabella leggibile da una persona.

Quando invece dobbiamo recuperare **un solo valore** da riutilizzare in un comando successivo, `tsv` è spesso più comodo. Immaginiamo di voler recuperare l'ID di un Resource Group:

```bash
RG_ID=$(az group show \
  --name rg-demo \
  --query id \
  --output tsv)
```

In questo caso non vogliamo parentesi, virgolette o un oggetto JSON completo: vogliamo soltanto il valore.

Questa differenza è importante:

```text
table
→ lettura umana

tsv
→ valore semplice da riutilizzare
```

---

# 3. JMESPath e `--query`: chiedere ad Azure solo ciò che serve

Il parametro:

```text
--query
```

permette di interrogare la struttura JSON restituita da Azure CLI.

Consideriamo:

```bash
az group show \
  --name rg-demo \
  --query "{Name:name,Location:location,State:properties.provisioningState}" \
  --output table
```

Il comando completo recupera il Resource Group, ma `--query` dice ad Azure CLI:

```text
dell'oggetto che hai ottenuto
mostrami soltanto:
- name
- location
- provisioningState
```

Il risultato diventa quindi molto più leggibile.

È importante non confondere JMESPath con una ricerca testuale. Un comando come:

```bash
grep "westeurope"
```

cerca caratteri dentro del testo.

JMESPath invece lavora sulla **struttura dell'oggetto**. Questo lo rende più affidabile quando vogliamo automatizzare un'attività.

Nel LAB utilizzeremo query abbastanza semplici. Lo scopo non è diventare esperti JMESPath, ma abituarsi a chiedere ad Azure solo le proprietà realmente utili.

---

# 4. Azure PowerShell: lo stesso Azure, un modello diverso

Azure PowerShell offre un altro modo di amministrare Azure. I cmdlet appartengono principalmente al modulo `Az` e seguono la convenzione tipica di PowerShell:

```text
Verbo-AzSostantivo
```

Per esempio:

```powershell
Get-AzResourceGroup
New-AzResourceGroup
Remove-AzResourceGroup
```

Il verbo esprime l'azione:

```text
Get
New
Set
Update
Remove
```

mentre il sostantivo identifica l'oggetto Azure.

Nel LAB useremo Azure PowerShell in Cloud Shell. Non perché sia obbligatorio amministrare Azure in questo modo, ma perché è importante riconoscere entrambi gli strumenti.

## La differenza più importante: gli oggetti

PowerShell lavora in modo naturale con oggetti.

Per esempio:

```powershell
$rg = Get-AzResourceGroup -Name "rg-demo"
```

non mette in `$rg` una semplice riga di testo. Memorizza un oggetto dal quale possiamo leggere proprietà:

```powershell
$rg.ResourceGroupName
$rg.Location
$rg.Tags
```

Possiamo anche passare oggetti da un comando all'altro attraverso la pipeline PowerShell.

Questo è concettualmente diverso dal tipico utilizzo Bash/CLI, nel quale lavoriamo spesso con JSON, query e variabili testuali.

La conclusione non deve essere:

```text
PowerShell è migliore
```

oppure:

```text
CLI è migliore
```

ma:

```text
sono due strumenti diversi per amministrare le stesse risorse
```

---

# 5. Idempotenza: poter rieseguire una procedura senza paura

Supponiamo di avere questa istruzione:

```bash
az group create --name rg-demo --location westeurope
```

Se il nostro obiettivo è semplicemente creare un Resource Group una volta, il comando è sufficiente.

Ma se stiamo scrivendo una procedura da usare più volte, vogliamo sapere prima in quale stato ci troviamo.

Una logica semplice può essere:

```text
il Resource Group esiste?
        |
   +----+----+
   |         |
  no        sì
   |         |
crealo    riusalo
```

Questo è un esempio di **idempotenza**: rieseguire la procedura deve portarci allo stato desiderato senza produrre ogni volta effetti indesiderati.

Nel LAB vedremo volutamente uno script Bash molto semplice. Non useremo funzioni, array, gestione avanzata delle eccezioni o costrutti complessi. Ci interessa leggere la logica:

```bash
EXISTS=$(az group exists --name "$RG")

if [ "$EXISTS" = "false" ]; then
  ...
else
  ...
fi
```

e capire perché una procedura amministrativa ripetibile è preferibile a una sequenza di comandi eseguiti senza verificare lo stato corrente.

---

# 6. Da amministrare a osservare: entra in gioco Azure Monitor

Creare una risorsa ci dice che Azure ha accettato una configurazione. Non ci dice però tutto ciò che accade dopo.

Un amministratore deve poter rispondere a domande come:

- la risorsa è stata modificata?
- chi ha eseguito l'operazione?
- l'operazione è riuscita?
- la risorsa sta consumando più del solito?
- una metrica ha superato una soglia?
- esistono log che aiutano a spiegare il problema?

Azure Monitor raccoglie e rende utilizzabili diversi tipi di telemetria.

Per orientarsi, è utile distinguere tre categorie:

```text
Activity Log
Metrics
Logs
```

Non sono tre modi diversi di vedere la stessa informazione. Rispondono a domande differenti.

---

# 7. Activity Log: che cosa è successo al control plane?

L'Activity Log registra eventi relativi principalmente alle operazioni di gestione della subscription e delle risorse.

Se eseguiamo:

```text
creazione di un Resource Group
modifica di una risorsa
eliminazione
assegnazione o valutazione di una policy
```

Azure registra eventi che possono aiutarci a capire:

```text
quando è avvenuta l'operazione?
quale operazione è stata richiesta?
con quale esito?
da quale identità?
```

Per esempio:

```bash
az monitor activity-log list \
  --resource-group rg-demo
```

permette di interrogare gli eventi relativi a un Resource Group.

## Che cosa NON ci dice l'Activity Log

Se una Web App risponde lentamente, l'Activity Log non è automaticamente il posto giusto per trovare la causa applicativa.

L'Activity Log riguarda soprattutto il **control plane**, cioè le operazioni di amministrazione della risorsa.

È quindi utile per domande del tipo:

```text
"questa configurazione è stata cambiata?"
```

più che:

```text
"perché questa richiesta HTTP ha impiegato 4 secondi?"
```

Questa distinzione evita molto troubleshooting casuale.

---

# 8. Metrics: numeri osservati nel tempo

Una metrica è un valore numerico associato al tempo.

Esempi:

```text
CPU Percentage
Transactions
Requests
UsedCapacity
Network In
Network Out
Latency
```

Una metrica non è soltanto "un numero". È una serie temporale.

Per esempio:

```text
10:00 → CPU 20%
10:05 → CPU 35%
10:10 → CPU 82%
10:15 → CPU 76%
```

La dimensione temporale ci permette di osservare una tendenza.

## Aggregazioni

Quando interroghiamo una metrica, Azure può aggregare i campioni.

Esempi:

```text
Average
Minimum
Maximum
Total
Count
```

L'aggregazione deve essere coerente con il significato della metrica.

Per una quantità cumulativa come il numero di transazioni, `Total` può essere significativo. Per l'utilizzo medio di una risorsa, può essere utile `Average`.

Per questo, prima di costruire un alert, dobbiamo capire:

```text
che cosa misura il segnale?
con quale unità?
quale aggregazione ha senso?
in quale intervallo temporale?
```

---

# 9. Logs: record più ricchi da interrogare

I log contengono record, non soltanto numeri.

Un record può comprendere:

```text
timestamp
risorsa
operazione
categoria
status
identità
dettagli
```

Questa ricchezza permette analisi che una metrica da sola non può fare.

I log però devono avere una destinazione nella quale essere raccolti e interrogati. Uno dei servizi principali usati in Azure Monitor è **Log Analytics**.

---

# 10. Log Analytics Workspace: dove interroghiamo i log

Un Log Analytics workspace è un ambiente nel quale possono essere raccolti dati di log e nel quale possiamo eseguire query.

Possiamo immaginare il flusso così:

```text
sorgente
   ↓
raccolta / instradamento
   ↓
Log Analytics Workspace
   ↓
query KQL
```

Il workspace non "inventa" automaticamente i dati. Dobbiamo capire quali sorgenti stanno inviando informazioni e attraverso quale configurazione.

Questo è il motivo per cui nel LAB distingueremo chiaramente:

```text
workspace
```

da:

```text
diagnostic setting
```

---

# 11. Diagnostic Settings: decidere quali dati inviare e dove

Una diagnostic setting definisce l'instradamento di determinate categorie di log o metriche verso una destinazione.

Destinazioni comuni:

```text
Log Analytics Workspace
Storage Account
Event Hub
```

Nel nostro laboratorio invieremo categorie dell'Activity Log al Log Analytics workspace.

È utile pensare a una diagnostic setting come a una regola di instradamento:

```text
sorgente
→ quali categorie?
→ verso quale destinazione?
```

Il workspace è invece il luogo nel quale quei dati potranno essere interrogati.

Quindi:

```text
Diagnostic Setting
≠
Log Analytics Workspace
```

---

# 12. KQL: interrogare i dati invece di scorrerli manualmente

KQL significa **Kusto Query Language**.

Viene utilizzato per interrogare dati in Azure Monitor e Log Analytics.

Una query molto semplice è:

```kusto
print Course="AZ-104", UD=7, Status="OK"
```

Questa query non ha bisogno di dati già raccolti: costruisce direttamente una riga di risultato.

Nel LAB la useremo per verificare che il motore di query funzioni prima di dipendere dall'ingestion dei log.

Un esempio con dati sintetici:

```kusto
datatable(Component:string, Status:string)
[
  "API", "OK",
  "DB", "WARN",
  "WEB", "OK"
]
| summarize Count=count() by Status
```

Qui succedono due cose:

1. `datatable()` crea alcuni record;
2. `summarize` li raggruppa per `Status`.

Il risultato non mostra più i tre record originali, ma il conteggio per stato.

Questa idea — filtrare, proiettare, raggruppare — diventerà sempre più importante quando lavoreremo con dati reali.

---

# 13. AzureActivity: Activity Log dentro Log Analytics

L'Activity Log può essere consultato direttamente dal Portale o dalla CLI.

Se lo instradiamo verso Log Analytics, possiamo interrogare quegli eventi anche tramite KQL, nella tabella:

```text
AzureActivity
```

Per esempio:

```kusto
AzureActivity
| where TimeGenerated > ago(2h)
| project TimeGenerated,
          OperationNameValue,
          ActivityStatusValue,
          ResourceGroup
| take 20
```

Qui c'è un'importante considerazione operativa: **l'ingestion richiede tempo**.

Se abbiamo appena configurato una diagnostic setting e `AzureActivity` è vuota, non possiamo concludere immediatamente:

```text
"Log Analytics è guasto"
```

Dobbiamo verificare:

- la diagnostic setting;
- il time range;
- i permessi;
- il tempo trascorso;
- se sono stati realmente generati eventi.

Questo è già troubleshooting.

---

# 14. Alert: trasformare una condizione in un segnale operativo

Un alert di Azure Monitor osserva un segnale e valuta una condizione.

Per esempio:

```text
scope:
Storage Account

signal:
Transactions

condition:
Total > 0

evaluation:
ogni 5 minuti
```

L'alert rule descrive **che cosa osservare e quando considerare vera una condizione**.

Questo non significa che appena creiamo la regola essa debba necessariamente entrare nello stato Fired.

Dobbiamo distinguere:

```text
Enabled
```

da:

```text
Fired
```

`Enabled` significa che la regola è attiva e può essere valutata.

`Fired` significa che la condizione è stata effettivamente soddisfatta.

---

# 15. Action Group: che cosa fare quando scatta un alert

L'Action Group è separato dall'Alert Rule.

Una regola può dire:

```text
se Transactions supera la soglia...
```

L'Action Group stabilisce:

```text
...che cosa facciamo?
```

Esempi:

```text
invia email
invia SMS
chiama webhook
avvia Azure Function
avvia Logic App
```

Questo disaccoppiamento è utile perché lo stesso Action Group può essere riutilizzato da più alert.

Schema:

```text
Metric / Log
     ↓
Alert Rule
     ↓
condizione vera?
     ↓
Action Group
     ↓
notifica / automazione
```

---

# 16. Alert non significa automaticamente incidente

Un alert è un segnale.

Un incidente è una situazione che richiede gestione perché produce o può produrre un impatto reale.

Una soglia mal configurata può creare molti alert inutili.

Questo fenomeno viene spesso chiamato:

```text
alert noise
```

Se ogni minima variazione genera una notifica, gli operatori iniziano a ignorare gli alert.

Per questo una buona regola deve essere:

- significativa;
- verificabile;
- coerente con il comportamento normale;
- collegata a un'azione utile.

---

# 17. Correlazione non significa causalità

Supponiamo di osservare:

```text
10:15 modifica della risorsa
10:20 aumento di una metrica
10:25 alert Fired
```

Possiamo dire con certezza che gli eventi sono avvenuti in questa sequenza.

Non possiamo ancora dire con certezza:

```text
la modifica delle 10:15 ha causato l'alert
```

Per affermare una causalità servono altre evidenze.

Per esempio:

- che cosa è stato modificato?
- la metrica osservata è tecnicamente collegata alla modifica?
- esistono log applicativi coerenti?
- il comportamento ritorna normale dopo il rollback?
- lo stesso fenomeno è riproducibile?

Questa prudenza è fondamentale nel troubleshooting professionale.

---

# 18. Troubleshooting: raccogliere evidenze prima di modificare

Quando qualcosa non funziona, è facile iniziare a cambiare impostazioni casualmente.

Un metodo più affidabile è:

```text
1. descrivere il sintomo
2. chiarire il risultato atteso
3. raccogliere evidenze
4. formulare un'ipotesi
5. verificare l'ipotesi
6. applicare la modifica minima
7. ripetere il test
8. documentare
```

Esempio:

```text
Sintomo:
Resource Group non trovato

Atteso:
il comando deve mostrare il RG

Evidenze:
az account show
az group exists
az group list

Ipotesi:
nome errato o subscription errata

Correzione:
usare il nome corretto / selezionare la subscription corretta

Verifica:
az group show
```

La modifica minima è importante perché ci permette di capire se la nostra ipotesi era corretta.

---

# 19. Runbook: trasformare l'esperienza in una procedura

Un runbook non è un elenco casuale di comandi.

È una procedura pensata per poter essere seguita anche in un momento di pressione.

Un buon runbook contiene almeno:

```text
Sintomo
Prerequisiti
Controlli
Comandi
Come interpretare il risultato
Correzione
Verifica finale
Rollback / Cleanup
```

La parte "come interpretare il risultato" è essenziale.

Per esempio:

```bash
az group exists --name rg-demo
```

non è utile soltanto perché produce `true` o `false`.

Il runbook deve spiegare:

```text
true  → il RG esiste; verificare subscription e proprietà
false → il nome è errato oppure il RG non esiste nella subscription corrente
```

In questo modo il comando diventa parte di un ragionamento.

---

# 20. Quadro complessivo della UD

Alla fine della giornata dovremmo riuscire a leggere questo flusso:

```text
Amministrazione
Azure CLI / PowerShell
        ↓
modifica di una risorsa
        ↓
Activity Log
        ↓
Metrics / Logs
        ↓
Log Analytics + KQL
        ↓
Alert Rule
        ↓
Action Group
        ↓
Troubleshooting basato su evidenze
```

Non tutti i problemi richiedono tutti questi strumenti.

La competenza consiste nel scegliere il segnale giusto in base alla domanda che dobbiamo risolvere.

---

# 21. Domande di controllo

1. Perché `--query` è preferibile a cercare manualmente una stringa nell'output JSON?
2. Qual è la differenza tra `table` e `tsv` in Azure CLI?
3. Che cosa significa lavorare con oggetti in PowerShell?
4. Che cosa significa che una procedura amministrativa è idempotente?
5. Distingui Activity Log, Metrics e Logs.
6. A che cosa serve un Log Analytics workspace?
7. A che cosa serve una diagnostic setting?
8. Perché Activity Log e AzureActivity non sono esattamente la stessa cosa?
9. Distingui Alert Rule e Action Group.
10. Perché un alert Fired non equivale automaticamente a un incidente?
11. Qual è la differenza tra correlazione e causalità?
12. Quali sono i passaggi essenziali di un troubleshooting ripetibile?
