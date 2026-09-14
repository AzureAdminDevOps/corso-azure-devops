# UD06 — Laboratorio guidato

## Obiettivo

Creare e osservare una VM reale, completare il troubleshooting di rete iniziato in UD05, osservare metriche, distribuire una Web App e analizzare scaling, backup e DR.

Il laboratorio segue un unico percorso logico: si parte dal provisioning della VM, si abilita l’accesso in modo controllato, si verifica il percorso di rete, si installa un servizio reale e si passa quindi a troubleshooting, monitoraggio, scaling e resilienza. I comandi non vanno quindi letti come una semplice sequenza da copiare: ogni passaggio modifica o verifica un componente preciso dell’architettura e prepara il passaggio successivo.

---

# 1. Login e variabili

Prima di creare risorse dobbiamo assicurarci che la CLI stia operando sulla **subscription Azure corretta** e definire una convenzione di nomi riutilizzabile in tutti i comandi. `az login` autentica la CLI, mentre `az account show` permette di controllare quale tenant e quale subscription verranno effettivamente modificati. Le variabili `LAB_*` che definiamo subito dopo non creano ancora alcuna risorsa: esistono soltanto nella shell corrente e ci permettono di riutilizzare gli stessi nomi nei comandi successivi, riducendo errori di battitura e rendendo il laboratorio più ripetibile. Prima di proseguire deve quindi essere chiaro **su quale subscription stiamo lavorando** e **quali nomi useremo per le risorse**.

```bash
az login
az account show --output table
```

```bash
export LAB_RG="rg-ud06-compute"
export LAB_VM="vm-ud06-linux"
export LAB_VNET="vnet-ud06"
export LAB_SUBNET="snet-vm"
```

**Scelta autonoma della regione.** Una VM può non essere disponibile in una certa regione per limiti della subscription, quota, capacità o restrizioni dello SKU. Per questo non fissiamo semplicemente una regione e non aspettiamo che l'errore emerga durante il deployment: il ciclo seguente interroga alcune regioni candidate, cerca la prima in cui `Standard_B1s` non presenta restrizioni e salva il risultato in `LAB_LOCATION`. Tutti i passaggi successivi useranno quindi la stessa regione. È un piccolo esempio di un principio generale di progettazione Azure: la disponibilità di una risorsa dipende anche da **regione** e **subscription**, perciò i vincoli vanno verificati prima del deployment.

Usare come prima scelta `westeurope`. Prima di procedere, verificare che la size di laboratorio `Standard_B1s` non presenti restrizioni nella subscription.

```bash
export LAB_LOCATION=""

for REGION in westeurope northeurope francecentral germanywestcentral; do
  AVAILABLE=$(az vm list-skus \
    --location "$REGION" \
    --size Standard_B1s \
    --all \
    --query "length([?name=='Standard_B1s' && length(restrictions)==\`0\`])" \
    --output tsv)

  if [ "$AVAILABLE" -gt 0 ]; then
    export LAB_LOCATION="$REGION"
    break
  fi
done

if [ -z "$LAB_LOCATION" ]; then
  echo "Nessuna delle regioni previste espone Standard_B1s senza restrizioni."
  echo "Usare il Portale per verificare la prima piccola B-series disponibile e scegliere, nell'ordine: westeurope, northeurope, francecentral, germanywestcentral."
  exit 1
fi

echo "Regione selezionata: $LAB_LOCATION"
```

La regione individuata deve essere utilizzata in tutti i passaggi successivi della UD.

---

# 2. Chiave SSH

La VM Linux verrà amministrata senza password, usando autenticazione a chiave pubblica. È il modello normalmente preferito perché evita di trasmettere o memorizzare password di accesso alla VM.

`ssh-keygen` crea una coppia di chiavi:

- la **chiave privata** resta sul computer del partecipante ed è il segreto con cui ci si autentica;
- la **chiave pubblica** verrà registrata sulla VM Azure e può essere distribuita senza esporre il segreto.

Quando in seguito eseguiremo `ssh -i ...`, il client dimostrerà di possedere la chiave privata corrispondente alla chiave pubblica presente sulla VM.

Il repository può contenere istruzioni e file di laboratorio, ma **mai la chiave privata**. Chi ne entra in possesso può tentare di autenticarsi come il proprietario della chiave.

```bash
ssh-keygen -t ed25519 \
  -f ~/.ssh/ud06_azure \
  -C "ud06"
```

Non sovrascrivere chiavi già esistenti.

Chiave pubblica:

```bash
cat ~/.ssh/ud06_azure.pub
```

La chiave privata non deve mai entrare nel repository.

---

# 3. Creare la VM dal Portale

Creiamo la prima VM dal Portale per vedere in modo esplicito quali decisioni compongono una risorsa Compute: gruppo di risorse, regione, immagine, dimensione, autenticazione, rete, indirizzo pubblico e regole di ingresso. Più avanti questi stessi elementi potranno essere automatizzati da CLI o Infrastructure as Code.

La VM non è una risorsa isolata. Il deployment coinvolge almeno:

`VM → NIC → subnet → VNet`, più disco OS e, in questo laboratorio, un Public IP.

Impostando `Public inbound ports: None` creiamo volutamente la VM **senza aprire subito SSH**. Questo ci consente di aggiungere successivamente una regola NSG minima e ragionare sul principio del **least privilege**.

Durante la procedura non limitarti a premere *Create*: individua quali valori riguardano **compute**, quali **identità/accesso** e quali **rete**.

```text
Virtual machines
→ Create
→ Azure virtual machine
```

Impostazioni da utilizzare:

```text
Resource Group: rg-ud06-compute
VM name: vm-ud06-linux
Region: valore di $LAB_LOCATION
Image: Ubuntu Server LTS più recente pubblicata da Canonical
Size: Standard_B1s
Authentication: SSH public key
Username: azureuser
Public inbound ports: None
```

Se `Standard_B1s` non compare nel Portale non proseguire scegliendo una VM più costosa a caso: tornare al passo 1 e selezionare una delle regioni di fallback previste.

Networking:

```text
VNet: vnet-ud06
Subnet: snet-vm
Public IP: sì
Inbound: None
```

Creare la VM.

---

# 4. Inventario da CLI

Dopo aver creato la VM dal Portale, la interroghiamo dalla CLI per verificare che la risorsa esista davvero e per imparare a leggere lo stato dell'infrastruttura senza dipendere dall'interfaccia grafica.

`az vm show --show-details` restituisce proprietà operative della VM. La query riduce l'output alle informazioni che ci servono: stato di alimentazione, IP privato, IP pubblico e size.

Una VM Azure è collegata ad altre risorse. Fare l'inventario serve a costruire il modello mentale delle dipendenze e aiuta nel troubleshooting: se la VM non è raggiungibile, il problema potrebbe non essere nella VM, ma nella NIC, nella subnet, nell'NSG o nell'indirizzo pubblico.

```bash
az vm show \
  --resource-group "$LAB_RG" \
  --name "$LAB_VM" \
  --show-details \
  --query "{Power:powerState,Private:privateIps,Public:publicIps,Size:hardwareProfile.vmSize}" \
  --output table
```

Registrare:

- image;
- size;
- private IP;
- public IP;
- VNet/subnet;
- OS disk;
- NIC.

---

# 5. Regola SSH minima

La VM possiede un Public IP, ma questo da solo **non significa che sia raggiungibile**. Per permettere SSH dobbiamo autorizzare il traffico TCP verso la porta 22 attraverso le regole di sicurezza di rete.

Aprire la porta 22 verso Internet intero (`0.0.0.0/0`) sarebbe più semplice, ma aumenterebbe inutilmente la superficie di attacco. Limitare la sorgente al proprio IP pubblico applica il principio del **minimo accesso necessario**.

Una regola NSG decide se un flusso può passare in base a direzione, protocollo, sorgente, destinazione, porta e priorità. Qui stiamo creando intenzionalmente la regola minima necessaria per amministrare la VM.

Portale:

```text
VM
→ Networking
→ Network settings
→ Create port rule
```

Configurare:

```text
Source: My IP address
TCP 22
Allow
Priority: 300
Name: Allow-SSH-MyIP
```

---

# 6. Collegamento SSH

Ora verifichiamo l'intera catena di accesso appena configurata: Public IP, NSG, NIC, sistema operativo e autenticazione SSH. Se il collegamento riesce, sappiamo che più componenti stanno funzionando insieme correttamente.

Recuperiamo il Public IP direttamente da Azure e lo salviamo in `LAB_VM_IP`, evitando di copiarlo manualmente dal Portale.

- `hostname`: conferma su quale host siamo connessi;
- `ip addr`: mostra le interfacce e gli indirizzi visti dal sistema operativo;
- `uname -a`: identifica kernel e piattaforma Linux;
- `df -h`: mostra lo spazio disco disponibile.

Il confronto tra ciò che Azure mostra all'esterno e ciò che Linux vede all'interno è fondamentale per capire la distinzione tra **control plane Azure** e **guest operating system**.

```bash
export LAB_VM_IP=$(az vm show \
  --resource-group "$LAB_RG" \
  --name "$LAB_VM" \
  --show-details \
  --query publicIps \
  --output tsv)
```

```bash
ssh -i ~/.ssh/ud06_azure azureuser@"$LAB_VM_IP"
```

Dentro la VM:

```bash
hostname
ip addr
uname -a
df -h
```

---

# 7. Installare Nginx

Finora abbiamo verificato solo l'accesso amministrativo SSH. Installando Nginx trasformiamo la VM in un piccolo server Web e introduciamo un secondo servizio applicativo, sulla porta TCP 80.

1. `apt update` aggiorna l'indice locale dei pacchetti.
2. `apt install` installa Nginx nella VM.
3. `systemctl status` verifica che il servizio sia avviato.
4. `curl -I http://localhost` testa Nginx **dall'interno della VM**.

Quest'ultimo test è importante: se `localhost` funziona ma il browser esterno no, il problema non è Nginx ma quasi certamente il percorso di rete o le regole di sicurezza.

Dentro la VM:

```bash
sudo apt update
sudo apt install -y nginx
systemctl status nginx --no-pager
curl -I http://localhost
```

Uscire:

```bash
exit
```

---

# 8. Consentire HTTP solo dal proprio IP

Nginx è in esecuzione, ma Azure continua a bloccare il traffico HTTP in ingresso perché non abbiamo ancora autorizzato la porta 80. Aggiungiamo quindi una seconda regola NSG, anch'essa limitata al nostro IP pubblico.

Prima abbiamo eseguito `curl localhost` **dentro** la VM, quindi il traffico non attraversava il Public IP né l'NSG. Ora `curl http://$LAB_VM_IP` parte dal client e attraversa realmente l'infrastruttura Azure.

Il percorso da verificare è:

`client → Public IP → NSG → NIC → VM → Nginx`.

Se uno solo di questi elementi non è configurato correttamente, la richiesta può fallire.

Creare:

```text
Source: My IP address
TCP 80
Allow
Priority: 310
Name: Allow-HTTP-MyIP
```

Test:

```bash
curl -I "http://$LAB_VM_IP"
```

Ora il percorso reale è:

```text
client
→ Public IP
→ NSG
→ NIC
→ VM
→ Nginx
```

---

# 9. IP Flow Verify

Quando una connessione non funziona, guardare manualmente tutte le regole NSG può essere lento e ambiguo. **IP Flow Verify** simula un flusso e indica se Azure lo consentirebbe o lo bloccherebbe, mostrando anche la regola responsabile.

La domanda è sostanzialmente: “un pacchetto TCP proveniente dal mio IP pubblico e diretto alla porta 80 di questa VM sarebbe ammesso?”.

Non stiamo solo verificando che HTTP funzioni: stiamo imparando uno strumento di **network troubleshooting** che permette di distinguere rapidamente un problema di regole NSG da un problema applicativo o di sistema operativo.

Portale:

```text
Network Watcher
→ IP flow verify
```

Impostare:

```text
VM: vm-ud06-linux
Direction: Inbound
Protocol: TCP
Local port: 80
Remote IP: proprio IP pubblico
```

Registrare:

- Allow/Deny;
- regola responsabile.

---

# 10. Azure Monitor Metrics

Dopo aver creato e raggiunto la VM passiamo dall'amministrazione al **monitoraggio**. Azure raccoglie metriche di piattaforma che descrivono il comportamento della risorsa nel tempo.

- `Percentage CPU`: utilizzo del processore;
- `Network In`: traffico ricevuto;
- `Network Out`: traffico trasmesso.

Cambiare intervallo temporale e aggregazione serve a capire che una metrica non è solo “un numero”: è una serie temporale che può essere letta con granularità e funzioni diverse.

**Metrics** e **Log Analytics** non sono la stessa cosa. Le metriche sono valori numerici temporali già raccolti dalla piattaforma; i log sono record/eventi interrogabili e richiedono un modello di raccolta e analisi differente.

Aprire:

```text
VM
→ Monitoring
→ Metrics
```

Osservare:

```text
Percentage CPU
Network In
Network Out
```

Provare a cambiare:

- time range;
- aggregation;
- metrica.

Annotare:

```text
metrica
valore/tendenza
interpretazione
```

Non confondere questa vista con Log Analytics.

---

# 11. VM Scale Set e autoscaling — configurazione guidata

Una singola VM ha capacità finita ed è anche un singolo punto di servizio. I VM Scale Set consentono di gestire un insieme di istanze omogenee e di variarne automaticamente il numero in funzione del carico.

In questa UD non creiamo realmente il VMSS: leggiamo una configurazione completa per capire **quali parametri servono a una politica di autoscaling**.

- `min-count`: numero minimo di istanze che deve rimanere disponibile;
- `count`: capacità iniziale/predefinita;
- `max-count`: limite superiore oltre il quale lo scaling non deve andare;
- `Percentage CPU > 70 avg 5m`: condizione osservata;
- `scale out 1`: azione da applicare quando la condizione è vera.

L'autoscaling deve aumentare la capacità, ma senza crescita incontrollata. Il massimo protegge da costi imprevedibili, errori di configurazione e scaling eccessivo dovuto a picchi o anomalie.

Questa parte è **analisi/configurazione**. In questa UD non è stato creato un VM Scale Set, quindi i comandi seguenti **non devono essere eseguiti**: servono per leggere una configurazione completa e riconoscerne i parametri.

Esempio di creazione di un profilo Autoscale per un VM Scale Set già esistente:

```bash
az monitor autoscale create \
  --resource-group <RG> \
  --resource <VMSS_NAME> \
  --resource-type Microsoft.Compute/virtualMachineScaleSets \
  --name autoscale \
  --min-count 1 \
  --max-count 3 \
  --count 1
```

e una regola concettuale:

```bash
az monitor autoscale rule create \
  --resource-group <RG> \
  --autoscale-name autoscale \
  --condition "Percentage CPU > 70 avg 5m" \
  --scale out 1
```

Compilare:

```text
min:
default:
max:
metrica:
soglia:
azione:
```

Domanda:

```text
Perché impostare un massimo?
```

Risposta nella consegna.

---

# 12. App Service Plan e Web App

Finora abbiamo gestito direttamente una VM, quindi anche sistema operativo e server Web. Con **Azure App Service** passiamo a un modello PaaS: ci concentriamo sull'applicazione mentre Azure gestisce gran parte dell'infrastruttura sottostante.

L'**App Service Plan** definisce la capacità di calcolo, la regione e il tier economico. La **Web App** è invece l'applicazione ospitata sopra quel piano. Separare i due concetti aiuta a capire dove si configurano costi, scaling e capacità.

I runtime disponibili possono cambiare nel tempo. Interrogarli dalla CLI rende il laboratorio più robusto e mostra che un deployment deve verificare i prerequisiti reali dell'ambiente.

Il laboratorio ha finalità didattica. Se F1 non è disponibile, non ha senso trasformare automaticamente un esercizio gratuito in una risorsa con costo. In quel caso si prosegue in modalità di analisi, preservando l'obiettivo formativo senza introdurre spese non previste.

```bash
export WEB_PLAN="plan-ud06-$RANDOM"
export WEB_APP="ud06-web-$RANDOM-$RANDOM"
```

Individuare automaticamente un runtime Linux disponibile. Si preferisce PHP; se non è disponibile si usa Node.js.

```bash
export WEB_RUNTIME=$(az webapp list-runtimes --os linux --output tsv | grep '^PHP:' | head -n 1)

if [ -z "$WEB_RUNTIME" ]; then
  export WEB_RUNTIME=$(az webapp list-runtimes --os linux --output tsv | grep '^NODE:' | head -n 1)
fi

echo "Runtime selezionato: $WEB_RUNTIME"
```

Se `WEB_RUNTIME` è vuoto, **non creare la Web App**: annotare `runtime Linux non disponibile nella CLI corrente` e proseguire direttamente dal paragrafo **14. Scaling App Service** in modalità di analisi, usando la tabella presente nel materiale.

Tentare quindi la creazione di un App Service Plan **Free F1**. Non usare un tier a pagamento come fallback.

```bash
export APP_SERVICE_LIVE="no"

if [ -n "$WEB_RUNTIME" ] && az appservice plan create \
  --resource-group "$LAB_RG" \
  --name "$WEB_PLAN" \
  --location "$LAB_LOCATION" \
  --sku F1 \
  --is-linux \
  --output table; then
  export APP_SERVICE_LIVE="yes"
else
  echo "F1 non disponibile o creazione non consentita: nessun tier a pagamento verrà creato."
fi
```

Creare la Web App **solo se** `APP_SERVICE_LIVE=yes`:

```bash
if [ "$APP_SERVICE_LIVE" = "yes" ]; then
  az webapp create \
    --resource-group "$LAB_RG" \
    --plan "$WEB_PLAN" \
    --name "$WEB_APP" \
    --runtime "$WEB_RUNTIME" \
    --output table
fi
```

Se `APP_SERVICE_LIVE=no`, non eseguire i comandi di deployment dei paragrafi 13 e 15; compilare comunque le sezioni di confronto e scaling usando quanto studiato in `00_CONCETTI.md`.

---

# 13. Deployment semplice

Creare una Web App vuota non dimostra ancora che sappiamo distribuirvi un contenuto. Prepariamo quindi una pagina minima e la pubblichiamo realmente sul servizio.

Il test copre la catena:

`file locale → comando di deployment → App Service → hostname pubblico → risposta HTTPS`.

Recuperare l'hostname dalla CLI e testarlo con `curl` evita di basarsi solo sul messaggio “deployment succeeded”: verifichiamo il risultato dal punto di vista di un client esterno.

A differenza della VM, non abbiamo installato Nginx né aperto manualmente una porta 80/443 sulla macchina: questa parte dell'infrastruttura è gestita dal servizio PaaS.

```bash
mkdir -p ~/ud06-web
cat > ~/ud06-web/index.html <<'HTML'
<!doctype html>
<html lang="it">
<head><meta charset="utf-8"><title>UD06</title></head>
<body>
<h1>UD06 - Azure App Service</h1>
<p>Deployment riuscito.</p>
</body>
</html>
HTML
```

```bash
if [ "$APP_SERVICE_LIVE" = "yes" ]; then
  az webapp deploy \
    --resource-group "$LAB_RG" \
    --name "$WEB_APP" \
    --src-path ~/ud06-web/index.html \
    --type static \
    --target-path index.html \
    --async false \
    --track-status true
fi
```

Recuperare hostname:

```bash
if [ "$APP_SERVICE_LIVE" = "yes" ]; then
  export WEB_HOST=$(az webapp show \
    --resource-group "$LAB_RG" \
    --name "$WEB_APP" \
    --query defaultHostName \
    --output tsv)
  echo "$WEB_HOST"
fi
```

Test, solo in modalità live:

```bash
if [ "$APP_SERVICE_LIVE" = "yes" ]; then
  curl -I "https://$WEB_HOST"
fi
```

---

# 14. Scaling App Service

Lo scaling può significare due cose diverse: aumentare la potenza della singola istanza oppure aumentare il numero di istanze. Questa sezione serve a distinguere chiaramente **scale up** e **scale out**.

- **Scale up**: cambio di tier/capacità della singola istanza;
- **Manual scale out**: numero di istanze deciso dall'operatore;
- **Azure Monitor Autoscale**: numero di istanze modificato in base a regole e metriche;
- **Automatic Scaling**: modalità gestita dal servizio quando disponibile per il piano/configurazione.

Alcuni tier e funzionalità di scaling comportano costi. L'obiettivo qui è capire il modello operativo, non generare spesa.

Se `APP_SERVICE_LIVE=yes`, dal Portale aprire:

```text
Web App
→ Scale up
```

e osservare i tier **senza applicare modifiche**.

Poi aprire:

```text
Web App / App Service Plan
→ Scale out
```

Se `APP_SERVICE_LIVE=no`, usare direttamente la descrizione presente in `00_CONCETTI.md`: la sezione deve essere completata comunque, senza creare un piano a pagamento.

Identificare:

- Manual;
- Azure Monitor Autoscale;
- Automatic Scaling.

**Regola di sicurezza:** durante questa UD non effettuare alcun upgrade del piano App Service e non creare tier a pagamento.

Compilare:

| Modalità | Basata su |
|---|---|
| Manual | |
| Azure Monitor Autoscale | |
| Automatic Scaling | |

---

# 15. Azure Monitor su App Service

Ripetiamo il ragionamento di osservabilità su una risorsa PaaS e confrontiamo ciò che è utile monitorare in un servizio applicativo rispetto a una VM.

- `Requests`: quante richieste raggiungono l'applicazione;
- `Response Time`: quanto tempo impiega il servizio a rispondere.

Sulla VM abbiamo guardato CPU e traffico perché amministriamo direttamente la macchina. Su App Service diventano centrali anche metriche più vicine al comportamento dell'applicazione. Questo mostra come il livello di astrazione del servizio influenzi anche il modo in cui lo si monitora.

Se `APP_SERVICE_LIVE=yes`, aprire:

```text
Web App
→ Monitoring
→ Metrics
```

e osservare almeno:

```text
Requests
Response Time
```

Confrontare con le metriche della VM.

Se `APP_SERVICE_LIVE=no`, annotare nella consegna `App Service Metrics non eseguite: piano Free non disponibile` e proseguire. Questo non blocca il completamento della UD.

---

# 16. Azure Backup — workflow guidato

Il backup non è semplicemente “fare una copia”: richiede decidere **dove**, **quando**, **quanto a lungo** conservare i punti di ripristino e come recuperarli. In questa UD studiamo il workflow senza attivare realmente il servizio.

- `Recovery Services vault`: contenitore logico che gestisce la protezione e i dati di backup;
- `Backup policy`: insieme delle regole di protezione;
- `Schedule`: quando avviare i backup;
- `Retention`: per quanto tempo conservarli;
- `Recovery point`: stato utilizzabile per un ripristino;
- `Backup now`: esecuzione manuale immediata.

Una politica di backup ha senso solo se deriva da un requisito. Frequenza e retention devono quindi essere motivate, non scelte a caso.

Non è obbligatorio avviare un backup reale.

Dal portale osservare il percorso:

```text
Virtual machine
→ Backup
```

oppure:

```text
Resiliency
→ Configure protection
```

Identificare:

```text
Recovery Services vault
Backup policy
Schedule
Retention
Recovery point
Backup now
```

Compilare una mini-policy progettuale:

```text
frequenza:
orario:
retention:
motivazione:
```

In questa UD **non abilitare Azure Backup** sulla VM. La parte partecipante si conclude con l'analisi del workflow e la progettazione della policy.

I concetti `backup job` e `recovery point` devono essere riconosciuti dalla schermata/documentazione del servizio, ma non è richiesta la creazione reale di un recovery point.

---

# 17. HA, Backup e DR

High Availability, Backup e Disaster Recovery vengono spesso confusi, ma rispondono a problemi diversi. Questa classificazione serve a collegare ogni tecnologia al requisito corretto.

- **High Availability**: mantenere il servizio disponibile nonostante il guasto di una singola componente/istanza;
- **Backup**: recuperare dati o stato precedente dopo cancellazione, corruzione o errore;
- **Disaster Recovery**: ripristinare il workload dopo un evento grave che rende indisponibile un sito o una regione.

L'obiettivo non è memorizzare tre definizioni, ma imparare a partire dal **requisito di continuità** e scegliere la soluzione adatta.

Per ciascun requisito indicare la categoria corretta.

**A.** "Voglio ridurre l'impatto del guasto di una singola istanza."

**B.** "Voglio recuperare il contenuto della VM a uno stato precedente."

**C.** "Voglio ripristinare il workload in un'altra regione dopo un grave outage."

Scelte:

```text
High Availability
Backup
Disaster Recovery
```

---

# 18. Azure Site Recovery — lettura architetturale

Dopo aver distinto Backup e DR, osserviamo l'architettura logica di una soluzione di Disaster Recovery cross-region. Non attiviamo la replica reale perché avrebbe costi e tempi non necessari al laboratorio.

Il workload primario è in **Region A**; i dati necessari al ripristino vengono replicati verso **Region B**. In caso di grave indisponibilità si può eseguire un **failover**; quando la situazione torna normale si può pianificare un **failback**.

In questo scenario è importante distinguere anche **RPO** e **RTO**. - **RPO**: quanta perdita di dati, misurata nel tempo, è accettabile;
- **RTO**: quanto tempo può trascorrere prima che il servizio debba tornare operativo.

Questi due valori non sono dettagli tecnici: sono requisiti di business che guidano la progettazione della soluzione di DR.

Schema:

```text
Region A
VM
 |
replica
 |
v
Region B
recovery
```

Concetti:

```text
replication
failover
failback
RPO
RTO
```

Non viene attivata replica cross-region nel laboratorio.

---

# 19. Cleanup

In cloud le risorse continuano a esistere — e alcune possono continuare a generare costi — finché non vengono eliminate esplicitamente. Il cleanup è quindi parte integrante del ciclo di vita del laboratorio, non una semplice operazione finale.

`az resource list` permette di vedere quali risorse appartengono al Resource Group prima di cancellarlo. È un controllo utile per comprendere cosa verrà rimosso e per individuare eventuali dipendenze inattese.

Poiché tutte le risorse di laboratorio sono state raccolte nello stesso Resource Group, eliminarlo consente di rimuovere in modo coerente l'intero ambiente.

`az group exists` deve restituire `false`: solo allora abbiamo una conferma esplicita che l'ambiente non esiste più. Se l'eliminazione fallisce, non si procede “a tentativi”: si torna all'inventario per capire quale risorsa sta impedendo il cleanup.

Prima:

```bash
az resource list \
  --resource-group "$LAB_RG" \
  --output table
```

Poi:

```bash
az group delete \
  --name "$LAB_RG" \
  --yes
```

Verificare:

```bash
az group exists --name "$LAB_RG"
```

Risultato atteso:

```text
false
```

Poiché il laboratorio partecipante **non abilita Azure Backup**, il Resource Group deve poter essere eliminato senza procedure aggiuntive legate alla protezione. Se `az group delete` non completa l'eliminazione, verificare con `az resource list --resource-group "$LAB_RG" --output table` quali risorse risultano ancora presenti prima di qualsiasi altra modifica.
