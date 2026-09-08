# Laboratorio guidato — Creare, interrogare e rimuovere un piccolo ambiente Azure

## Risultato atteso

Creerai per la prima volta un resource group, una rete virtuale e uno storage account tramite Azure Portal. Dopo ogni provisioning userai Azure CLI per verificare contesto e proprietà reali. Nel laboratorio autonomo ricreerai poi le stesse tipologie da CLI: questa progressione permette di comprendere prima le scelte del servizio e soltanto dopo renderle ripetibili.

Le risorse sono leggere e temporanee. La rete virtuale non genera normalmente un costo diretto; lo storage account rimarrà vuoto. La sottoscrizione può comunque applicare prezzi, policy o limitazioni proprie: per questo il cleanup è obbligatorio.

## 1. Verifica il contesto locale

Apri Ubuntu e raggiungi il repository personale:

```bash
cd ~/workspace/azure-devops-lab
pwd
git status
code .
```

`pwd` deve mostrare un percorso Linux sotto `/home`, non `/mnt/c`. `git status` deve confermare che la cartella appartiene al repository personale. Se sono presenti modifiche precedenti non comprese, non cancellarle: completa o conserva il relativo lavoro prima di preparare il commit di questa unità.

Verifica la cartella delle consegne preparata seguendo il README:

```bash
mkdir -p consegne/UD02
```

Il comando `mkdir -p` è stato introdotto nell'UD01: crea i livelli mancanti e non restituisce errore se esistono già.

I quattro modelli devono essere già presenti. Il controllo seguente evita di iniziare il laboratorio scrivendo nel repository dei materiali:

```bash
ls -1 consegne/UD02/*.md
```

Apri `consegne/UD02/01_LAB_GUIDATO.md` in VS Code e lascialo disponibile: verrà completato durante i checkpoint, non ricostruito soltanto alla fine.

## 2. Controlla Azure CLI prima di usarla

Nel terminale WSL:

```bash
az version
```

Se il comando restituisce le versioni, non reinstallare Azure CLI. Se non esiste, applica la procedura dell'UD01, `02_LAB_GUIDATO.md`, sezione **Verifica Azure Portal e Azure CLI**. Se esiste ma fallisce, registra la prima riga dell'errore e verifica il percorso:

```bash
command -v az
type -a az
```

`command -v` indica quale eseguibile verrebbe usato; `type -a` mostra eventuali installazioni multiple. Una reinstallazione non è il primo tentativo di diagnosi.

Controlla l'autenticazione:

```bash
az account show \
  --query "{Name:name,State:state,IsDefault:isDefault}" \
  --output table
```

Se la sessione è scaduta o non esiste:

```bash
az login --use-device-code
```

Usa il codice soltanto nella pagina di autenticazione e non conservarlo. Ripeti `az account show` al termine.

Se possiedi più sottoscrizioni, elencale senza mostrare gli ID:

```bash
az account list \
  --query "[].{Name:name,State:state,IsDefault:isDefault}" \
  --output table
```

Imposta quella assegnata al laboratorio e verifica il cambiamento:

```bash
az account set --subscription "<NOME_O_ID_SOTTOSCRIZIONE>"
az account show \
  --query "{Name:name,State:state,IsDefault:isDefault}" \
  --output table
```

Non copiare l'ID della sottoscrizione nell'evidenza.

## 3. Verifica località e provider

Controlla `italynorth`:

```bash
az account list-locations \
  --query "[?name=='italynorth'].{Name:name,DisplayName:displayName}" \
  --output table
```

Se la località compare, userai `italynorth`. Se la tabella è vuota, verifica e usa `westeurope`:

```bash
az account list-locations \
  --query "[?name=='westeurope'].{Name:name,DisplayName:displayName}" \
  --output table
```

Controlla poi i provider necessari:

```bash
az provider show \
  --namespace Microsoft.Network \
  --query "{Namespace:namespace,State:registrationState}" \
  --output table

az provider show \
  --namespace Microsoft.Storage \
  --query "{Namespace:namespace,State:registrationState}" \
  --output table
```

Lo stato atteso è `Registered`. Se uno stato è `NotRegistered`, registra il provider e attendi il completamento:

```bash
az provider register --namespace Microsoft.Network --wait
az provider register --namespace Microsoft.Storage --wait
```

La registrazione abilita la sottoscrizione a creare quel tipo di risorsa. Non installa software nella postazione.

## 4. Prepara nomi e tag nel repository

Genera un suffisso tecnico:

```bash
LAB_SUFFIX="$(date +%s%N | sha256sum | cut -c1-8)"
printf 'Suffisso generato: %s\n' "$LAB_SUFFIX"
```

Il valore non contiene dati personali. Apri il file che conserverà le variabili:

```bash
code consegne/UD02/01_VARIABILI_LAB.sh
```

Inserisci il contenuto seguente, sostituendo `<SUFFISSO>` con il valore appena generato e scegliendo la località verificata:

```bash
export LAB_LOCATION="italynorth"
export LAB_SUFFIX="<SUFFISSO>"
export LAB_RG="rg-cea-ud02-${LAB_SUFFIX}"
export LAB_VNET="vnet-cea-ud02"
export LAB_SUBNET="snet-app"
export LAB_STORAGE="stcea${LAB_SUFFIX}"
export LAB_DELETE_AFTER="$(date -d '+2 days' +%F)"
```

Il file contiene nomi e data, non credenziali. `export` rende le variabili disponibili ai comandi eseguiti dalla shell. La data `deleteAfter` segnala quando l'ambiente avrebbe dovuto essere eliminato anche se il cleanup venisse dimenticato; il tag non elimina automaticamente nulla.

Carica le variabili:

```bash
source consegne/UD02/01_VARIABILI_LAB.sh
```

Controllale senza mostrare informazioni di account:

```bash
printf 'Località: %s\nRG: %s\nVNet: %s\nSubnet: %s\nStorage: %s\nCleanup entro: %s\n' \
  "$LAB_LOCATION" "$LAB_RG" "$LAB_VNET" "$LAB_SUBNET" \
  "$LAB_STORAGE" "$LAB_DELETE_AFTER"
```

Verifica il vincolo del nome storage:

```bash
if [[ "$LAB_STORAGE" =~ ^[a-z0-9]{3,24}$ ]]; then
  printf 'Nome storage formalmente valido.\n'
else
  printf 'Nome storage non valido: usare 3-24 caratteri minuscoli o numerici.\n'
fi
```

`=~` confronta il valore con un'espressione regolare. Il controllo locale verifica forma e lunghezza; la disponibilità globale verrà controllata da Azure.

⏱

## 5. Crea il resource group dal portale

Accedi ad Azure Portal e cerca **Resource groups**. Seleziona **Create** e compila:

| Campo | Valore |
|---|---|
| Subscription | la sottoscrizione già verificata |
| Resource group | valore di `LAB_RG` |
| Region | località corrispondente a `LAB_LOCATION` |

Nella scheda **Tags** aggiungi:

| Name | Value |
|---|---|
| `course` | `cloud-engineer-academy` |
| `unit` | `UD02` |
| `environment` | `lab` |
| `deleteAfter` | valore di `LAB_DELETE_AFTER` |

Seleziona **Review + create**, leggi il riepilogo e crea il gruppo. La validazione del portale controlla forma e autorizzazioni, ma il risultato deve essere verificato dopo il provisioning.

Nel terminale WSL:

```bash
az group show \
  --name "$LAB_RG" \
  --query "{Name:name,Location:location,State:properties.provisioningState,Tags:tags}" \
  --output jsonc
```

Il criterio di successo è:

- nome uguale a `LAB_RG`;
- località prevista;
- `provisioningState` uguale a `Succeeded`;
- quattro tag presenti.

La [documentazione Microsoft sulla gestione dei resource group con Azure CLI](https://learn.microsoft.com/azure/azure-resource-manager/management/manage-resource-groups-cli) descrive le stesse operazioni di creazione, lettura ed eliminazione.

## 6. Crea la prima rete virtuale dal portale

Nel portale cerca **Virtual networks** e seleziona **Create**. Nella scheda **Basics** scegli la sottoscrizione già verificata, il resource group indicato da `LAB_RG`, il nome contenuto in `LAB_VNET` e la località `LAB_LOCATION`.

Questi campi definiscono proprietà diverse: la sottoscrizione stabilisce il confine amministrativo e di fatturazione; il resource group raccoglie la risorsa nel ciclo di vita del laboratorio; la località indica dove Azure mantiene la rete logica. In un'attività lavorativa, una scelta errata del contesto può separare la rete dalle risorse che devono usarla o attribuire il costo al progetto sbagliato.

Apri la scheda **IP addresses**. Imposta lo spazio IPv4 `10.20.0.0/16`, rimuovi o modifica l'eventuale subnet proposta e crea una subnet con il nome indicato da `LAB_SUBNET` e intervallo `10.20.1.0/24`. `10.20.0.0/16` è lo spazio della VNet; `10.20.1.0/24` è una sua porzione. CIDR e progettazione degli indirizzi verranno approfonditi nell'UD05; qui devi soltanto verificare che la subnet appartenga allo spazio della rete.

Nella scheda **Tags** inserisci gli stessi quattro tag usati per il resource group: `course`, `unit`, `environment` e `deleteAfter`. Seleziona **Review + create**, controlla che Azure non segnali errori e avvia la creazione. Non attivare servizi o protezioni aggiuntive non richiesti: verranno valutati quando avremo i concetti necessari per comprenderne effetto e costo.

La creazione è stata svolta nel portale perché è la prima VNet del percorso. Ora la CLI trasforma le scelte visuali in proprietà interrogabili e costituisce un controllo indipendente:

Verifica il risultato:

```bash
az network vnet show \
  --resource-group "$LAB_RG" \
  --name "$LAB_VNET" \
  --query "{Name:name,Location:location,Address:addressSpace.addressPrefixes,Subnets:subnets[].{Name:name,Prefix:addressPrefix},Tags:tags}" \
  --output jsonc
```

L'output deve mostrare la VNet, l'intervallo `/16`, la subnet e l'intervallo `/24`.

## 7. Crea il primo storage account dal portale

Controlla prima la disponibilità globale del nome:

```bash
az storage account check-name \
  --name "$LAB_STORAGE" \
  --query "{Available:nameAvailable,Reason:reason,Message:message}" \
  --output jsonc
```

Se `Available` è `true`, prosegui. Se è `false`, genera un nuovo suffisso e aggiorna **soltanto** il valore di `LAB_STORAGE` in `variabili-lab.sh`. Il resource group esiste già e il suo nome non deve cambiare:

```bash
NEW_STORAGE_SUFFIX="$(date +%s%N | sha256sum | cut -c1-8)"
printf 'Nuovo nome storage proposto: stcea%s\n' "$NEW_STORAGE_SUFFIX"
```

Sostituisci nel file la riga con `LAB_STORAGE`, ricaricalo con `source` e ripeti il controllo. Non modificare soltanto la variabile in memoria: il file deve rimanere la fonte dei valori utilizzati.

Nel portale cerca **Storage accounts** e seleziona **Create**. Nella scheda **Basics** indica la sottoscrizione e il resource group già verificati, usa il valore di `LAB_STORAGE` come nome, scegli `LAB_LOCATION`, imposta **Standard** come performance e **Locally-redundant storage (LRS)** come ridondanza. Mantieni il tipo di account predefinito general purpose v2 (`StorageV2`).

`Standard_LRS` conserva copie sincrone nella stessa region ed è sufficiente per un laboratorio temporaneo, ma non è una scelta universale: requisiti di durabilità e ridondanza saranno confrontati nell'UD04. Il nome deve essere disponibile globalmente perché entra negli endpoint pubblici del servizio; per questo lo abbiamo controllato prima tramite CLI.

Nelle opzioni avanzate verifica che sia richiesto il trasferimento sicuro, che la versione TLS minima sia almeno 1.2 e che l'accesso Blob pubblico anonimo sia disabilitato. Le etichette del portale possono cambiare leggermente, quindi leggi anche il riepilogo finale: l'obiettivo non è memorizzare la posizione di un controllo, ma riconoscere la proprietà di sicurezza che stai impostando.

Nella scheda **Tags** inserisci `course`, `unit`, `environment` e `deleteAfter` con gli stessi valori già usati. Seleziona **Review + create**, esamina riepilogo e validazione e crea l'account. Non creare container e non caricare dati: in questa UD osserviamo la risorsa; dati, accessi e servizi Storage saranno trattati nell'UD04.

Verifica quindi con la CLI, senza leggere o mostrare chiavi:

```bash
az storage account show \
  --resource-group "$LAB_RG" \
  --name "$LAB_STORAGE" \
  --query "{Name:name,Location:location,Kind:kind,Sku:sku.name,HttpsOnly:enableHttpsTrafficOnly,MinimumTls:minimumTlsVersion,PublicBlobAccess:allowBlobPublicAccess,State:provisioningState,Tags:tags}" \
  --output jsonc
```

La [guida Microsoft alla creazione di uno storage account](https://learn.microsoft.com/azure/storage/common/storage-account-create) ricorda che ogni storage account appartiene a un resource group e che l'eliminazione rimuove anche i dati contenuti. Nel nostro account non verranno caricati dati.

## 8. Costruisci l'inventario con query diverse

Elenca le risorse:

```bash
az resource list \
  --resource-group "$LAB_RG" \
  --query "[].{Name:name,Type:type,Location:location,Unit:tags.unit,DeleteAfter:tags.deleteAfter}" \
  --output table
```

L'inventario deve mostrare almeno VNet e storage account. La subnet è una risorsa figlia e può non apparire come riga autonoma nell'elenco generico.

Osserva lo stesso insieme come JSON colorato:

```bash
az resource list \
  --resource-group "$LAB_RG" \
  --query "[].{name:name,type:type,location:location}" \
  --output jsonc
```

`table` privilegia la lettura umana; `jsonc` conserva struttura e annidamento; `tsv` è utile quando serve un singolo valore in uno script.

Recupera gli ID e anonimizzali prima di conservarli:

```bash
az resource list \
  --resource-group "$LAB_RG" \
  --query "[].id" \
  --output tsv \
  | sed -E 's#/subscriptions/[^/]+#/subscriptions/<omitted>#'
```

La pipe invia l'output a `sed`. L'espressione sostituisce il vero subscription ID con `<omitted>` lasciando leggibile il resto della gerarchia. Copia nell'evidenza soltanto la versione anonimizzata.

## 9. Confronta portale e CLI

Nel portale apri il resource group e seleziona **Resources**. Confronta:

- numero e tipo delle risorse;
- località;
- tag;
- stato di provisioning;
- struttura dell'ID nella pagina **JSON View**, senza copiarne la parte riservata.

Il portale è più efficace per esplorare proprietà non ancora note. La CLI è più efficace per ripetere controlli e selezionare esattamente i campi necessari. Nessuno dei due strumenti è sempre superiore: la scelta dipende dal compito.

Completa `consegne/UD02/01_LAB_GUIDATO.md` descrivendo questa differenza con un esempio osservato, non con una definizione astratta.

### Checkpoint delle 16:00

Prima della pausa devono risultare disponibili VNet e storage account, l'inventario CLI e una prima compilazione dell'evidenza. Non eliminare ancora il resource group guidato: la sezione 12 verrà eseguita nel blocco finale, dopo laboratorio autonomo e verifica. La sezione 11 rimane disponibile in qualunque momento si presenti uno degli errori descritti.

## 10. Controlla modifiche e dati pubblicabili

Nel repository:

```bash
git status --short
git diff -- consegne/UD02/01_VARIABILI_LAB.sh consegne/UD02/01_LAB_GUIDATO.md
```

Controlla che non compaiano:

- subscription ID o tenant ID;
- e-mail e nomi completi non necessari;
- token o codici di login;
- chiavi dello storage account;
- output integrali non ripuliti.

Non eseguire `az storage account keys list`: il laboratorio non richiede chiavi e produrrebbe materiale sensibile da proteggere.

⏱

## 11. Risolvi gli errori con il loro contesto

Se compare `SubscriptionNotFound` o una risorsa non è visibile:

```bash
az account list --query "[].{Name:name,State:state,IsDefault:isDefault}" --output table
az account show --query "{Name:name,State:state,IsDefault:isDefault}" --output table
```

Imposta la sottoscrizione corretta e ripeti il comando fallito.

Se compare `AuthorizationFailed`, verifica account e scope. Il laboratorio richiede almeno il diritto di creare risorse nel resource group. Un nuovo login non aggiunge privilegi: aggiorna soltanto la sessione. Registra l'operazione bloccata e il ruolo necessario senza tentare di aggirare le autorizzazioni.

Se la località non è valida, non sostituirla casualmente. Ripeti `az account list-locations` e usa una località verificata aggiornando anche `variabili-lab.sh`.

Se lo storage name non è disponibile, applica la rigenerazione del suffisso descritta nella sezione 7. Non aggiungere trattini o lettere maiuscole.

Se un provider rimane `Registering`, ricontrolla:

```bash
az provider show \
  --namespace Microsoft.Storage \
  --query registrationState \
  --output tsv
```

Ripeti la creazione soltanto quando lo stato è `Registered`.

Se il comando restituisce un errore non previsto, usa:

```bash
az <GRUPPO_COMANDO> <OPERAZIONE> --help
```

e confronta nome del comando, parametri obbligatori, valori delle variabili e prima riga dell'errore. `--debug` può produrre dati eccessivi: non salvarne l'output nel repository.

## 12. Elimina e verifica

Prima di eliminare, salva in `consegne/UD02/01_LAB_GUIDATO.md` l'inventario ripulito e le decisioni. Poi avvia la rimozione dell'intero resource group:

```bash
az group delete \
  --name "$LAB_RG" \
  --yes \
  --no-wait
```

`--yes` evita una richiesta interattiva perché il nome è già stato verificato; `--no-wait` restituisce il controllo mentre Azure elimina le risorse dipendenti. Queste opzioni rendono ancora più importante controllare la variabile prima del comando:

```bash
printf 'Resource group richiesto per il cleanup: %s\n' "$LAB_RG"
```

Attendi la conclusione:

```bash
az group wait --name "$LAB_RG" --deleted
```

Verifica infine con un risultato booleano:

```bash
az group exists --name "$LAB_RG"
```

Il risultato atteso è `false`. Se `az group wait` termina con timeout ma `exists` restituisce `true`, attendi alcuni minuti e ripeti soltanto il controllo. Non lanciare ripetutamente nuove eliminazioni.

Aggiorna la sezione cleanup di `consegne/UD02/01_LAB_GUIDATO.md` e prepara il commit:

```bash
git status
git diff -- consegne/UD02/
git add consegne/UD02/00_DOMANDE_CONCETTI.md \
        consegne/UD02/01_LAB_GUIDATO.md \
        consegne/UD02/01_VARIABILI_LAB.sh \
        consegne/UD02/02_LAB_AUTONOMO.md \
        consegne/UD02/03_VERIFICA.md
git status
git commit -m "Documenta architettura e prime risorse Azure"
git push
```

Il checkpoint finale è superato quando il commit e i cinque file richiesti sono visibili su GitHub, `az group exists` restituisce `false` e sai spiegare perché il resource group era il confine corretto di cleanup.

⏱
