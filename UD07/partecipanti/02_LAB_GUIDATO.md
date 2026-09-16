# UD07 — Laboratorio guidato
## Amministrazione ripetibile, Azure Monitor e troubleshooting

In questo laboratorio non ci limiteremo a creare qualche risorsa. Costruiremo invece una piccola sequenza amministrativa nella quale ogni passaggio lascia un'evidenza osservabile.

Il percorso sarà:

```text
preparazione delle directory
→ verifica del contesto Azure
→ amministrazione CLI e PowerShell
→ Activity Log
→ Log Analytics + KQL
→ metriche
→ alert
→ correlazione delle evidenze
→ cleanup
```

Lavoreremo soprattutto da **Ubuntu in WSL2**, ma useremo anche **Cloud Shell PowerShell** e il **Portale Azure** quando questi strumenti rendono più chiaro ciò che stiamo configurando.

---

# 0. Preparare l'ambiente di lavoro prima di toccare Azure

Prima di creare risorse è importante sapere **dove stiamo lavorando e dove finiranno le consegne**. Useremo due directory distinte:

```text
materiale del corso
→ contiene i file distribuiti
→ non va modificato durante il laboratorio

repository personale
→ contiene il lavoro del partecipante
→ contiene consegne/UD07/
```

La struttura attesa è:

```text
~/workspace/
├── corso-azure-devops/
│   └── UD07/
│       └── partecipanti/
│           ├── 00_CONCETTI.md
│           ├── 02_LAB_GUIDATO.md
│           ├── modelli/
│           └── script/
└── azure-devops-lab/
    └── consegne/
        └── UD07/
```

Aprire **Ubuntu/WSL2**. Tutti i comandi `bash`, `az` e `git` della UD vanno eseguiti qui, salvo quando il LAB indica esplicitamente **Portale Azure** oppure **Cloud Shell PowerShell**.

Verificare la shell e la directory corrente:

```bash
echo "$SHELL"
pwd
```

Impostiamo ora tre variabili che useremo per tutta la giornata:

```bash
export COURSE_UD07="$HOME/workspace/corso-azure-devops/UD07/partecipanti"
export LAB_REPO="$HOME/workspace/azure-devops-lab"
export LAB_SUBMISSION="$LAB_REPO/consegne/UD07"
```

Se uno dei due repository si trova in un percorso differente, cambiare **soltanto** la variabile corrispondente.

Prima di continuare controlliamo che i due punti di partenza esistano davvero:

```bash
test -d "$COURSE_UD07" && echo "Materiali UD07 trovati"
test -d "$LAB_REPO/.git" && echo "Repository personale trovato"
```

Creiamo adesso la cartella unica delle consegne:

```bash
mkdir -p "$LAB_SUBMISSION"
```

Copiamo i quattro modelli. Usiamo `cp -n`: l'opzione `-n` evita di sovrascrivere un file che il partecipante abbia già iniziato a compilare.

```bash
cp -n "$COURSE_UD07/modelli/00_DOMANDE_CONCETTI.md" \
      "$LAB_SUBMISSION/00_DOMANDE_CONCETTI.md"

cp -n "$COURSE_UD07/modelli/01_LAB_GUIDATO.md" \
      "$LAB_SUBMISSION/01_LAB_GUIDATO.md"

cp -n "$COURSE_UD07/modelli/02_LAB_AUTONOMO.md" \
      "$LAB_SUBMISSION/02_LAB_AUTONOMO.md"

cp -n "$COURSE_UD07/modelli/03_VERIFICA.md" \
      "$LAB_SUBMISSION/03_VERIFICA.md"
```

Controlliamo il risultato:

```bash
find "$LAB_SUBMISSION" \
  -maxdepth 1 \
  -type f \
  -printf '%f\n' \
  | sort
```

Devono comparire:

```text
00_DOMANDE_CONCETTI.md
01_LAB_GUIDATO.md
02_LAB_AUTONOMO.md
03_VERIFICA.md
```

Infine ci spostiamo nel repository personale:

```bash
cd "$LAB_REPO"
git status --short
```

Se sono presenti modifiche appartenenti a una giornata precedente, metterle in sicurezza prima di proseguire. Non usare `git reset --hard` per "fare pulizia": potrebbe eliminare lavoro non ancora salvato.

---

# 1. Verificare il contesto Azure prima di creare risorse

Molti errori apparentemente misteriosi dipendono semplicemente dal fatto che la CLI sta lavorando sulla subscription sbagliata oppure con un'identità diversa da quella prevista.

Per questo iniziamo sempre verificando il contesto.

Da **Ubuntu/WSL2**:

```bash
az login
```

Poi:

```bash
az account show \
  --query "{Subscription:name,User:user.name}" \
  --output table
```

Leggere il risultato e verificare che la subscription sia quella utilizzata per il corso.

Non copiare subscription ID o tenant ID nella consegna.

Questo controllo dovrebbe diventare un'abitudine:

```text
prima di amministrare Azure
→ verificare sempre il contesto
```

---

# 2. Preparare le variabili che useremo nella sessione

Per evitare di riscrivere continuamente gli stessi nomi, definiamo alcune variabili Bash.

Eseguirle nella **stessa shell WSL2** che resterà aperta per il LAB:

```bash
export LAB_RG="rg-ud07-monitor"
export LAB_LOCATION="westeurope"
export LAW="law-ud07-$RANDOM"
export ALERT_NAME="alert-ud07-storage-transactions"
export AG_NAME="ag-ud07"
export DIAG_NAME="ud07-activity-to-law"
export STG="stud07$(date +%s | tail -c 9)"
```

Controlliamo cosa abbiamo impostato:

```bash
printf 'RG=%s\nLOCATION=%s\nLAW=%s\nSTORAGE=%s\n' \
  "$LAB_RG" "$LAB_LOCATION" "$LAW" "$STG"
```

Lo Storage Account richiede un nome globalmente univoco, composto da lettere minuscole e numeri. Il suffisso derivato dal timestamp riduce la probabilità di collisione.

Queste variabili appartengono alla shell corrente. Se chiudiamo il terminale, dovremo reimpostarle.

---

# 3. Creare il Resource Group che conterrà le risorse di monitoraggio

Creiamo il Resource Group principale della giornata:

```bash
az group create \
  --name "$LAB_RG" \
  --location "$LAB_LOCATION" \
  --tags Course=AZ104 UD=07 \
  --output table
```

Qui è utile ricordare una cosa: la `location` del Resource Group non obbliga tutte le risorse contenute ad avere la stessa regione. Il Resource Group è un contenitore logico; ogni risorsa mantiene la propria location.

Verifichiamo:

```bash
az group show \
  --name "$LAB_RG" \
  --query "{Name:name,Location:location,State:properties.provisioningState}" \
  --output table
```

Il `ProvisioningState` atteso è:

```text
Succeeded
```

---

# 4. Leggere ed eseguire un primo script CLI semplice

Uno degli obiettivi di UD07 è capire che cosa rende una procedura ripetibile. Per questo usiamo **un solo script Bash**, volutamente semplice.

Non lo eseguiamo subito: prima lo leggiamo.

```bash
cat "$COURSE_UD07/script/ud07-cli-admin.sh"
```

Nel file dovresti riconoscere questa logica:

```text
1. definisci nome e regione
2. chiedi ad Azure se il Resource Group esiste
3. se non esiste → crealo
4. se esiste → riusalo
5. aggiorna i tag
6. mostra lo stato finale
```

Il cuore è:

```bash
EXISTS=$(az group exists --name "$RG")

if [ "$EXISTS" = "false" ]; then
  ...
else
  ...
fi
```

Non ci sono funzioni, array o gestione avanzata degli errori: l'obiettivo è poter leggere il file dall'inizio alla fine e capire ogni riga.

Eseguiamo lo script:

```bash
"$COURSE_UD07/script/ud07-cli-admin.sh"
```

Poi eseguiamolo una seconda volta:

```bash
"$COURSE_UD07/script/ud07-cli-admin.sh"
```

Osservare la differenza.

Alla prima esecuzione dovrebbe comparire un messaggio equivalente a:

```text
Il Resource Group non esiste: lo creo.
```

Alla seconda:

```text
Il Resource Group esiste già: lo riutilizzo.
```

Nel file `01_LAB_GUIDATO.md` della consegna spiegare con parole proprie perché questo comportamento è più sicuro rispetto a tentare sempre la creazione della stessa risorsa.

---

# 5. Usare `--query` per ridurre l'output a ciò che ci interessa

Ora interroghiamo il Resource Group principale:

```bash
az group show \
  --name "$LAB_RG" \
  --query "{Name:name,Location:location,Provisioning:properties.provisioningState}" \
  --output table
```

Notare che il comando `az group show` recupera molte più proprietà. È `--query` che seleziona solo quelle utili.

Proviamo poi a recuperare un unico valore:

```bash
az group show \
  --name "$LAB_RG" \
  --query name \
  --output tsv
```

Qui usiamo `tsv` perché ci interessa un valore semplice.

Per capire la differenza, eseguire anche:

```bash
az group show \
  --name "$LAB_RG" \
  --query name \
  --output json
```

Confrontare i due output.

Nella consegna indicare quando preferiremmo:

```text
table
```

e quando:

```text
tsv
```

---

# 6. Ripetere lo stesso ragionamento con Azure PowerShell

A questo punto cambiamo strumento, non obiettivo.

Aprire dal Portale:

```text
Cloud Shell
→ PowerShell
```

Verificare innanzitutto il contesto:

```powershell
Get-AzContext
```

Anche qui non copiare nella consegna ID sensibili.

Creeremo un Resource Group di prova separato:

```text
rg-ud07-ps-test
```

La logica è volutamente simile allo script Bash:

```powershell
$RgName = "rg-ud07-ps-test"
$Location = "westeurope"

$rg = Get-AzResourceGroup `
  -Name $RgName `
  -ErrorAction SilentlyContinue

if (-not $rg) {
    $rg = New-AzResourceGroup `
      -Name $RgName `
      -Location $Location
}

Update-AzTag `
  -ResourceId $rg.ResourceId `
  -Tag @{ ManagedBy="PowerShell"; UD="07"; State="Verified" } `
  -Operation Merge | Out-Null

Get-AzResourceGroup `
  -Name $RgName |
  Select-Object ResourceGroupName, Location, ProvisioningState, Tags
```

Leggiamo prima la logica:

```text
Get-AzResourceGroup
→ prova a recuperare il RG

if (-not $rg)
→ se non è stato trovato...

New-AzResourceGroup
→ ...lo crea

Update-AzTag
→ porta i tag allo stato desiderato
```

Eseguire il blocco una seconda volta.

La seconda esecuzione non deve creare un altro Resource Group. Questo è lo stesso principio di idempotenza già osservato con Bash, espresso con la sintassi e gli oggetti PowerShell.

---

# 7. Creare il Log Analytics Workspace senza nascondere la scelta della regione

Torniamo in **Ubuntu/WSL2**.

Per il workspace partiamo da:

```bash
export LAB_LOCATION="westeurope"
```

Creiamo:

```bash
az monitor log-analytics workspace create \
  --resource-group "$LAB_RG" \
  --workspace-name "$LAW" \
  --location "$LAB_LOCATION" \
  --output table
```

Se il comando riesce, manteniamo `westeurope`.

Se Azure restituisce **esplicitamente un problema di disponibilità regionale**, cambiare la variabile seguendo quest'ordine:

```text
1. northeurope
2. francecentral
3. germanywestcentral
```

Per esempio:

```bash
export LAB_LOCATION="northeurope"
```

e ripetere **lo stesso comando di creazione**.

Non cambiare regione se l'errore riguarda:

```text
AuthorizationFailed
nome non valido
subscription
quota non pertinente alla regione
```

In questi casi va risolta la causa reale.

Quando il workspace è stato creato, verifichiamo:

```bash
az monitor log-analytics workspace show \
  --resource-group "$LAB_RG" \
  --workspace-name "$LAW" \
  --query "{Name:name,Location:location,State:provisioningState}" \
  --output table
```

Registrare nella consegna la regione effettivamente utilizzata.

---

# 8. Interrogare Log Analytics prima ancora di avere log reali

Recuperiamo l'identificativo del workspace usato dalle query:

```bash
export LAW_CUSTOMER_ID=$(az monitor log-analytics workspace show \
  --resource-group "$LAB_RG" \
  --workspace-name "$LAW" \
  --query customerId \
  --output tsv)
```

Non serve riportare questo valore nella consegna.

Eseguiamo una prima query KQL che non dipende dall'ingestion:

```bash
az monitor log-analytics query \
  --workspace "$LAW_CUSTOMER_ID" \
  --analytics-query "print Course='AZ-104', UD=7, Status='OK'" \
  --output table
```

Questa query è utile perché ci permette di verificare:

```text
autenticazione
+
workspace
+
motore KQL
```

senza aspettare dati esterni.

Proviamo poi:

```bash
az monitor log-analytics query \
  --workspace "$LAW_CUSTOMER_ID" \
  --analytics-query "datatable(Component:string,Status:string)[
    'API','OK',
    'DB','WARN',
    'WEB','OK'
  ]
  | summarize Count=count() by Status" \
  --output table
```

Leggere il risultato e verificare che i record siano stati raggruppati per `Status`.

---

# 9. Generare intenzionalmente un evento amministrativo e trovarlo nell'Activity Log

Per vedere un evento reale nel control plane modifichiamo un tag del Resource Group:

```bash
az group update \
  --name "$LAB_RG" \
  --set tags.LastChange=UD07 \
  --output none
```

La modifica è semplice, ma Azure la registra come operazione amministrativa.

Interroghiamo quindi l'Activity Log:

```bash
az monitor activity-log list \
  --resource-group "$LAB_RG" \
  --offset 2h \
  --max-events 20 \
  --query "[].{
    Time:eventTimestamp,
    Operation:operationName.localizedValue,
    Status:status.localizedValue
  }" \
  --output table
```

Cercare un evento coerente con la modifica appena eseguita.

Il punto importante non è imparare a memoria il nome dell'operazione, ma collegare:

```text
azione eseguita
→ evento registrato
```

Nella consegna annotare:

- timestamp;
- operazione;
- status.

Non è necessario riportare il `Caller`.

---

# 10. Inviare l'Activity Log a Log Analytics con una Diagnostic Setting

Finora abbiamo consultato l'Activity Log direttamente.

Ora vogliamo costruire questo flusso:

```text
Activity Log
→ Diagnostic Setting
→ Log Analytics Workspace
→ KQL
```

Per rendere visibile il concetto useremo il **Portale Azure**, mentre useremo la CLI dopo per verificare il risultato.

Aprire:

```text
Azure Monitor
→ Activity Log
```

Cercare il comando:

```text
Export Activity Logs
```

oppure la voce equivalente che apre le **Diagnostic settings** dell'Activity Log.

Creare una nuova diagnostic setting con nome:

```text
ud07-activity-to-law
```

Selezionare almeno queste categorie:

```text
Administrative
Policy
Alert
ServiceHealth
ResourceHealth
```

Come destinazione scegliere:

```text
Send to Log Analytics workspace
```

e selezionare il workspace creato in questa UD.

Salvare.

## Se il Portale non consente il salvataggio

Leggere il messaggio.

Se indica un problema di autorizzazione, **non modificare ruoli o privilegi per aggirarlo**.

Nel file di consegna scrivere:

```text
Diagnostic setting non creata per autorizzazione insufficiente.
Activity Log verificato direttamente; KQL verificato con dati sintetici.
```

e proseguire.

## Se la creazione riesce

Da WSL recuperare la subscription corrente:

```bash
export SUB_ID=$(az account show \
  --query id \
  --output tsv)
```

Verificare la diagnostic setting:

```bash
az monitor diagnostic-settings subscription show \
  --name "$DIAG_NAME" \
  --subscription "$SUB_ID" \
  --query "{Name:name,Workspace:workspaceId}" \
  --output table
```

Il comando di verifica ci mostra che esiste una regola a livello subscription che punta al workspace.

---

# 11. Interrogare `AzureActivity` e capire la latenza di ingestion

Se la diagnostic setting è stata creata, proviamo:

```bash
az monitor log-analytics query \
  --workspace "$LAW_CUSTOMER_ID" \
  --analytics-query "AzureActivity
  | where TimeGenerated > ago(2h)
  | project TimeGenerated,
            OperationNameValue,
            ActivityStatusValue,
            ResourceGroup
  | take 20" \
  --output table
```

Due risultati sono accettabili.

## Caso A — compaiono righe

Cercare un'operazione relativa alle risorse della UD e riportare nella consegna una riga significativa, senza identificativi personali.

## Caso B — non compaiono ancora righe

Non concludere che il workspace è guasto.

Abbiamo già verificato:

- il workspace con le query sintetiche;
- l'Activity Log direttamente;
- eventualmente la diagnostic setting.

La spiegazione più probabile nelle prime fasi è la latenza di ingestion.

Annotare:

```text
AzureActivity non ancora popolata nel time range osservato.
```

e proseguire.

---

# 12. Creare una risorsa che ci permetta di osservare metriche

Per le metriche usiamo uno Storage Account, perché è una risorsa leggera e dispone di diversi segnali Azure Monitor.

Creiamo lo Storage Account nella stessa regione del workspace:

```bash
az storage account create \
  --resource-group "$LAB_RG" \
  --name "$STG" \
  --location "$LAB_LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --tags Course=AZ104 UD=07 \
  --output table
```

Recuperiamo il Resource ID in una variabile:

```bash
export STG_ID=$(az storage account show \
  --resource-group "$LAB_RG" \
  --name "$STG" \
  --query id \
  --output tsv)
```

Non stampare l'ID nella consegna.

---

# 13. Prima capire quali metriche esistono, poi leggerne una

Non è buona pratica scegliere a caso il nome di una metrica.

Chiediamo prima ad Azure quali metriche sono definite per la risorsa:

```bash
az monitor metrics list-definitions \
  --resource "$STG_ID" \
  --query "[].{
    Metric:name.value,
    Unit:unit,
    Primary:primaryAggregationType
  }" \
  --output table
```

Individuare almeno:

```text
UsedCapacity
Transactions
```

Osservare per ciascuna:

- unità;
- aggregazione primaria.

Ora interroghiamo `UsedCapacity`:

```bash
az monitor metrics list \
  --resource "$STG_ID" \
  --metric UsedCapacity \
  --interval PT1H \
  --aggregation Average \
  --output table
```

Se il campione non è ancora disponibile, annotare:

```text
metrica supportata, campione non ancora disponibile
```

e non cambiare casualmente metrica soltanto per ottenere un numero.

---

# 14. Creare un Action Group dal Portale

L'Action Group rappresenta la **destinazione dell'azione**, non la condizione dell'alert.

Aprire:

```text
Azure Monitor
→ Alerts
→ Action groups
→ Create
```

Impostare:

```text
Resource Group: rg-ud07-monitor
Action group name: ag-ud07
Display name / Short name: UD07AG
```

Nella sezione delle notifiche aggiungere:

```text
Notification type: Email/SMS message/Push/Voice
Name: SelfEmail
Email: il proprio indirizzo utilizzabile
```

Salvare.

Se non si vuole utilizzare un indirizzo email personale nel laboratorio, è possibile creare la regola di alert senza Action Group. In quel caso la consegna deve dichiararlo esplicitamente.

Verificare da CLI che l'Action Group esista, senza stampare l'indirizzo email:

```bash
az monitor action-group show \
  --resource-group "$LAB_RG" \
  --name "$AG_NAME" \
  --query "{Name:name,Enabled:enabled}" \
  --output table
```

---

# 15. Creare una Metric Alert Rule e leggere ciò che abbiamo configurato

Ora costruiamo la parte:

```text
Storage Account
→ metrica Transactions
→ condizione
→ Alert Rule
→ Action Group
```

Aprire lo Storage Account nel Portale:

```text
Storage Account
→ Monitoring
→ Alerts
→ Create
→ Alert rule
```

Verificare che lo **Scope** sia lo Storage Account della UD.

Scegliere come segnale:

```text
Transactions
```

Configurare la condizione con questi valori:

```text
Aggregation type: Total
Operator: Greater than
Threshold value: 0
```

Se l'interfaccia richiede window size/evaluation frequency, usare:

```text
Window size: 5 minutes
Evaluation frequency: 5 minutes
```

Come severity impostare:

```text
3 - Informational
```

Se è stato creato l'Action Group:

```text
Action group: ag-ud07
```

Nome regola:

```text
alert-ud07-storage-transactions
```

Creare la regola.

Non dobbiamo aspettare che l'alert vada necessariamente nello stato `Fired`. In questa UD ci interessa soprattutto verificare che la regola sia costruita correttamente.

Da WSL:

```bash
az monitor metrics alert show \
  --name "$ALERT_NAME" \
  --resource-group "$LAB_RG" \
  --query "{Name:name,Enabled:enabled,Severity:severity,Scopes:scopes}" \
  --output table
```

Nella consegna spiegare la differenza tra:

```text
Enabled
```

e:

```text
Fired
```

---

# 16. Correlare una modifica con l'Activity Log senza inventare una causalità

Modifichiamo lo Storage Account:

```bash
az storage account update \
  --resource-group "$LAB_RG" \
  --name "$STG" \
  --set tags.State=Changed \
  --output none
```

Cerchiamo l'evento:

```bash
az monitor activity-log list \
  --resource-id "$STG_ID" \
  --offset 1h \
  --max-events 10 \
  --query "[].{
    Time:eventTimestamp,
    Operation:operationName.localizedValue,
    Status:status.localizedValue
  }" \
  --output table
```

Ora abbiamo almeno due evidenze:

```text
la modifica è stata eseguita
+
Azure ha registrato l'operazione
```

Questo non dimostra automaticamente che un eventuale cambiamento di metrica sia stato causato da quel tag.

Nel file di consegna rispondere:

```text
La presenza dell'evento prova causalità?
```

motivando la risposta.

---

# 17. Cleanup: Attenzione da svolgere dopo il Laboratorio autonomo

## Eliminare prima ciò che vive fuori dal Resource Group

Prima di eliminare il Resource Group principale dobbiamo ricordare che la diagnostic setting dell'Activity Log è a livello **subscription**.

Se la diagnostic setting è stata creata, eliminarla:

```bash
az monitor diagnostic-settings subscription delete \
  --name "$DIAG_NAME" \
  --subscription "$SUB_ID"
```

Se non era stata creata per mancanza di autorizzazioni, saltare questo comando.

Ora possiamo eliminare il Resource Group di prova CLI:

```bash
az group delete \
  --name rg-ud07-cli-test \
  --yes \
  --no-wait
```

Per il Resource Group creato con PowerShell, tornare in **Cloud Shell PowerShell**:

```powershell
$rg = Get-AzResourceGroup `
  -Name "rg-ud07-ps-test" `
  -ErrorAction SilentlyContinue

if ($rg) {
    Remove-AzResourceGroup `
      -Name "rg-ud07-ps-test" `
      -Force
}
```

Infine, da WSL2, eliminare il Resource Group principale:

```bash
az group delete \
  --name "$LAB_RG" \
  --yes
```

Verificare:

```bash
az group exists \
  --name "$LAB_RG"
```

Atteso:

```text
false
```

---

# 18. Chiudere la giornata mettendo in sicurezza le consegne

Tornare nel repository personale:

```bash
cd "$LAB_REPO"
```

Controllare i file compilati:

```bash
find "$LAB_SUBMISSION" \
  -maxdepth 1 \
  -type f \
  -printf '%f\n' \
  | sort
```

Verificare Git:

```bash
git status
```

Prima del commit controllare che nelle consegne non siano presenti:

- subscription ID;
- tenant ID;
- object ID non necessari;
- email se non serve;
- token o chiavi.

A questo punto il laboratorio è completo: abbiamo creato risorse, modificato configurazioni, osservato eventi, interrogato metriche e log, configurato un alert e infine eliminato l'ambiente in modo controllato.
