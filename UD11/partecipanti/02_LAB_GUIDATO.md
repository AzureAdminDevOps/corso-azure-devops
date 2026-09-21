# UD11 — Laboratorio guidato
## Pubblicare un'image in ACR e distribuirla manualmente in Azure Container Apps

In UD10 l'image Docker viveva soltanto sul nostro computer. In questo laboratorio la pubblicheremo in Azure Container Registry e poi creeremo una Container App che la scaricherà usando una managed identity.


Questa UD è volutamente **manuale**.

I comandi vengono eseguiti direttamente nel terminale WSL2 del partecipante, non da Azure Pipelines.

L'obiettivo è arrivare a comprendere il processo completo che nelle UD14–UD15 verrà automatizzato:

```text
oggi — UD11
persona
→ docker build
→ docker push
→ configurazione Azure
→ deploy
→ verifica

più avanti — UD14/UD15
pipeline
→ Agent
→ build / push / deploy / smoke test
```

Non avviare `run.sh` dell'agent solo per svolgere UD11: non è un prerequisito di questa giornata.

Il percorso sarà eseguito manualmente:

```text
build locale
→ test locale
→ ACR
→ push v1
→ Container Apps Environment
→ Container App v1
→ HTTPS test
→ build/push v2
→ nuova revision
```

---

# 0. Preparare directory e consegne

Aprire **Ubuntu/WSL2**.

La struttura attesa è:

```text
~/workspace/
├── corso-azure-devops/
│   └── UD11/partecipanti/
└── azure-devops-lab/
    ├── app/
    │   └── catalog-backend-cloud/
    └── consegne/UD11/
```

Impostare:

```bash
export COURSE_UD11="$HOME/workspace/corso-azure-devops/UD11/partecipanti"
export LAB_REPO="$HOME/workspace/azure-devops-lab"
export LAB_SUBMISSION="$LAB_REPO/consegne/UD11"
```

Verificare:

```bash
test -d "$COURSE_UD11" && echo "Materiali UD11 trovati"
test -d "$LAB_REPO/.git" && echo "Repository personale trovato"
```

Creare le consegne:

```bash
mkdir -p "$LAB_SUBMISSION"
```

Copiare i modelli:

```bash
cp -n "$COURSE_UD11/modelli/00_DOMANDE_CONCETTI.md" "$LAB_SUBMISSION/00_DOMANDE_CONCETTI.md"
cp -n "$COURSE_UD11/modelli/01_LAB_GUIDATO.md"      "$LAB_SUBMISSION/01_LAB_GUIDATO.md"
cp -n "$COURSE_UD11/modelli/02_LAB_AUTONOMO.md"    "$LAB_SUBMISSION/02_LAB_AUTONOMO.md"
cp -n "$COURSE_UD11/modelli/03_VERIFICA.md"        "$LAB_SUBMISSION/03_VERIFICA.md"
```

Controllare:

```bash
find "$LAB_SUBMISSION" -maxdepth 1 -type f -printf '%f\n' | sort
```

---

# 1. Verificare Azure CLI e Docker

Azure:

```bash
az login
az account show --query "{Subscription:name,User:user.name}" --output table
```

Docker:

```bash
docker version
docker info
```

Se questi controlli non funzionano, non ha senso creare ACR: prima deve funzionare l'ambiente locale che produrrà l'image.

---

# 2. Verificare il comando Azure Container Apps

Provare:

```bash
az containerapp --help
```

Se il comando non è disponibile o l'estensione deve essere aggiornata:

```bash
az extension add --name containerapp --upgrade --yes
```

Verificare:

```bash
az extension show \
  --name containerapp \
  --query "{Name:name,Version:version}" \
  --output table
```

---

# 3. Verificare i provider necessari

Container Apps utilizza provider Azure che devono essere registrati nella subscription.

Controllare:

```bash
az provider show \
  --namespace Microsoft.App \
  --query registrationState \
  --output tsv
```

Poi:

```bash
az provider show \
  --namespace Microsoft.OperationalInsights \
  --query registrationState \
  --output tsv
```

Se uno restituisce `NotRegistered`, eseguire:

```bash
az provider register --namespace Microsoft.App
```

oppure:

```bash
az provider register --namespace Microsoft.OperationalInsights
```

verificare anche se necessario:
```bash
az provider register --namespace Microsoft.ContainerRegistry
```


Ripetere il controllo finché lo stato diventa `Registered` prima di creare l'Environment.

---




# 4. Preparare i nomi delle risorse

Useremo una sola regione per il laboratorio:

```bash
export LAB_LOCATION="westeurope"
```

Definiamo:

```bash
export LAB_RG="rg-ud11-containers"
export ACA_ENV="acaenv-ud11"
export ACA_APP="catalog-api-ud11"
export IMAGE_REPO="catalog-backend"
```

ACR richiede un nome globalmente univoco e composto da lettere/numeri. Generiamo un nome semplice basato sul timestamp:

```bash
export ACR="acr$(date +%s)ud11"
```

Controllare:

```bash
echo "$ACR"
```

Se `az acr create` dirà che il nome non è disponibile, rigenereremo il valore rieseguendo il comando dopo qualche secondo.

---

# 5. Creare il Resource Group

```bash
az group create \
  --name "$LAB_RG" \
  --location "$LAB_LOCATION" \
  --tags Course=AZ104 UD=11 \
  --output table
```

Questo Resource Group conterrà tutte le risorse cloud della giornata, così il cleanup finale sarà semplice e verificabile.

---

# 6. Copiare nel repository il backend predisposto per il cloud

I materiali UD11 includono una versione del backend che espone chiaramente `APP_VERSION`.

Dal repository personale:

```bash
cd "$LAB_REPO"
mkdir -p app/catalog-backend-cloud
rm -rf app/catalog-backend-cloud/*
cp -R "$COURSE_UD11/app/catalog-backend/." app/catalog-backend-cloud/
```

Verificare:

```bash
find app/catalog-backend-cloud -maxdepth 2 -type f | sort
```

Dovremmo vedere:

```text
Dockerfile
server.py
.dockerignore
```

---

# 7. Costruire e testare localmente v1 prima del push

Spostarsi:

```bash
cd "$LAB_REPO/app/catalog-backend-cloud"
```

Build:

```bash
docker build -t catalog-backend:ud11-v1 .
```

Avvio locale:

```bash
docker run \
  --detach \
  --rm \
  --name catalog-backend-ud11-v1 \
  --publish 127.0.0.1:18000:8000 \
  catalog-backend:ud11-v1
```

Test:

```bash
curl -s http://127.0.0.1:18000/health | python3 -m json.tool
```

Atteso:

```text
status = ok
version = v1
```

Solo dopo questo test ha senso pubblicare l'image.

Fermare:

```bash
docker stop catalog-backend-ud11-v1
```

---

# 8. Creare Azure Container Registry

Creiamo un registry Basic:

```bash
az acr create \
  --resource-group "$LAB_RG" \
  --name "$ACR" \
  --sku Basic \
  --location "$LAB_LOCATION" \
  --role-assignment-mode rbac \
  --output table
```

Se Azure segnala che il nome è già usato, generare un nuovo nome:

```bash
export ACR="acr$(date +%s)ud11"
```

poi ripetere `az acr create`.

Non abilitiamo l'admin user del registry.

Verifichiamo anche il modello di autorizzazione scelto:

```bash
az acr show \
  --name "$ACR" \
  --resource-group "$LAB_RG" \
  --query "{Name:name,RoleAssignmentMode:roleAssignmentMode,AdminUser:adminUserEnabled}" \
  --output table
```

Per questo laboratorio ci aspettiamo un registry in modalità RBAC classica e:

```text
AdminUser = false
```

La ragione è didattica: useremo `AcrPull` per la managed identity. In un registry configurato in modalità RBAC+ABAC i ruoli repository da usare sarebbero differenti.

Se il valore restituito non è coerente con la modalità RBAC classica, **non proseguire assegnando ruoli a tentativi**: ricontrollare il comando di creazione e il valore `roleAssignmentMode`.

---

# 9. Leggere il login server reale del registry

Recuperare:

```bash
export ACR_LOGIN=$(az acr show \
  --name "$ACR" \
  --resource-group "$LAB_RG" \
  --query loginServer \
  --output tsv)
```

Visualizzare:

```bash
echo "$ACR_LOGIN"
```

Questo è il prefisso che useremo nei riferimenti image. Non lo costruiamo manualmente.

---

# 10. Autenticarsi ad ACR con la propria identità Azure

Eseguire:

```bash
az acr login --name "$ACR"
```

Atteso:

```text
Login Succeeded
```

Qui stiamo autenticando il nostro workstation per il **push**. Questa non sarà l'identità usata da Container Apps per il pull.

---

# 11. Taggare e pubblicare v1

Costruiamo il riferimento completo:

```bash
export IMAGE_V1="$ACR_LOGIN/$IMAGE_REPO:v1"
```

Tag:

```bash
docker tag catalog-backend:ud11-v1 "$IMAGE_V1"
```

Push:

```bash
docker push "$IMAGE_V1"
```

Verificare che il repository esista:

```bash
az acr repository list \
  --name "$ACR" \
  --output table
```

Poi i tag:

```bash
az acr repository show-tags \
  --name "$ACR" \
  --repository "$IMAGE_REPO" \
  --output table
```

Dobbiamo vedere:

```text
v1
```

---

# 12. Creare il Container Apps Environment

Ora creiamo il boundary nel quale vivrà la Container App:

```bash
az containerapp env create \
  --name "$ACA_ENV" \
  --resource-group "$LAB_RG" \
  --location "$LAB_LOCATION"
```

La creazione può richiedere alcuni minuti.

Verificare:

```bash
az containerapp env show \
  --name "$ACA_ENV" \
  --resource-group "$LAB_RG" \
  --query "{Name:name,Location:location,State:properties.provisioningState}" \
  --output table
```

Atteso:

```text
Succeeded
```

---

# 13. Creare la Container App v1 con managed identity

Ora colleghiamo tutti i concetti:

```text
image privata in ACR
+
system-assigned managed identity
+
AcrPull
+
external ingress
+
target port 8000
```

Eseguire:

```bash
az containerapp create \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --environment "$ACA_ENV" \
  --image "$IMAGE_V1" \
  --registry-server "$ACR_LOGIN" \
  --registry-identity system \
  --ingress external \
  --target-port 8000 \
  --env-vars APP_VERSION=v1 LOW_STOCK_THRESHOLD=5 RUNTIME_DIR=/tmp/runtime \
  --min-replicas 0 \
  --max-replicas 1 \
  --revision-suffix v1
```

Leggere attentamente l'output/errori.

## Se il comando fallisce per RBAC

Se il messaggio cita autorizzazioni come `roleAssignments/write` o la creazione di `AcrPull`, non abilitare l'admin user ACR.


Il comando `az containerapp create --registry-identity system` può tentare di creare automaticamente l'assegnazione `AcrPull`. Per riuscirci, l'identità con cui stiamo operando deve avere anche il permesso di creare role assignment sullo scope richiesto.

Questo è un problema di **autorizzazione Azure**, non di Docker e non dell'image.

Annotare nella consegna:

```text
BLOCKED_BY_RBAC
```

Il problema è che l'identità corrente non può creare l'assegnazione richiesta. Va corretto il ruolo/permesso sullo scope appropriato.

Se il comando riesce, continuare.

---

# 14. Verificare identity e configurazione del registry

Identity:

```bash
az containerapp identity show \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --query "{Type:type}" \
  --output table
```

Atteso:

```text
SystemAssigned
```

Registry:

```bash
az containerapp registry list \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --output table
```

Dobbiamo riconoscere il login server ACR e l'uso dell'identità.

Non riportare PrincipalId o altri ID nella consegna.

---

# 15. Verificare ingress e leggere il FQDN

```bash
az containerapp ingress show \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --query "{External:external,TargetPort:targetPort,FQDN:fqdn}" \
  --output table
```

Verificare:

```text
External = true
TargetPort = 8000
```

Recuperare il FQDN:

```bash
export ACA_FQDN=$(az containerapp show \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --query properties.configuration.ingress.fqdn \
  --output tsv)
```

Visualizzare:

```bash
echo "$ACA_FQDN"
```

---

# 16. Testare v1 via HTTPS

Con `minReplicas=0`, il primo accesso può richiedere un cold start. Non serve un ciclo Bash complesso: proviamo manualmente.

```bash
curl -i "https://$ACA_FQDN/health"
```

Se la prima richiesta fallisce o impiega tempo, attendere 10–20 secondi e ripetere.

Quando risponde, visualizzare il JSON:

```bash
curl -s "https://$ACA_FQDN/health" | python3 -m json.tool
```

Atteso:

```text
status = ok
version = v1
```

Poi:

```bash
curl -s "https://$ACA_FQDN/api/products" | python3 -m json.tool
```

Atteso:

```text
count = 4
```

---

# 17. Leggere la revision v1 e i log

Revision:

```bash
az containerapp revision list \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --query "[].{Name:name,Active:properties.active,Health:properties.healthState,Replicas:properties.replicas}" \
  --output table
```

Annotare la revision attiva.

Log:

```bash
az containerapp logs show \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --tail 30
```

Cercare il messaggio del backend che indica la versione e la porta di ascolto.

---

# 18. Preparare v2 modificando intenzionalmente il Dockerfile

Aprire il Dockerfile in VS Code:

```bash
code "$LAB_REPO/app/catalog-backend-cloud/Dockerfile"
```

Individuare:

```dockerfile
APP_VERSION=v1
```

cambiarlo in:

```dockerfile
APP_VERSION=v2
```

Salvare.

Questa modifica rende evidente che stiamo costruendo una nuova image, non soltanto cambiando una variabile in Azure.

---

# 19. Build e test locale di v2

Dalla directory dell'app:

```bash
cd "$LAB_REPO/app/catalog-backend-cloud"
```

Build:

```bash
docker build -t catalog-backend:ud11-v2 .
```

Avvio:

```bash
docker run \
  --detach \
  --rm \
  --name catalog-backend-ud11-v2 \
  --publish 127.0.0.1:18001:8000 \
  catalog-backend:ud11-v2
```

Test:

```bash
curl -s http://127.0.0.1:18001/health | python3 -m json.tool
```

Atteso:

```text
version = v2
```

Fermare:

```bash
docker stop catalog-backend-ud11-v2
```

---

# 20. Pubblicare v2 in ACR

Definire:

```bash
export IMAGE_V2="$ACR_LOGIN/$IMAGE_REPO:v2"
```

Taggare:

```bash
docker tag catalog-backend:ud11-v2 "$IMAGE_V2"
```

Push:

```bash
docker push "$IMAGE_V2"
```

Verificare:

```bash
az acr repository show-tags \
  --name "$ACR" \
  --repository "$IMAGE_REPO" \
  --orderby time_desc \
  --output table
```

Ora dobbiamo vedere sia:

```text
v2
v1
```

---

# 21. Aggiornare manualmente la Container App a v2

Eseguire:

```bash
az containerapp update \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --image "$IMAGE_V2" \
  --set-env-vars APP_VERSION=v2 \
  --revision-suffix v2
```

Abbiamo cambiato la configurazione revision-scope, quindi Azure crea una nuova revision.

---

# 22. Verificare la nuova revision

```bash
az containerapp revision list \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --query "[].{Name:name,Active:properties.active,Health:properties.healthState,Created:properties.createdTime}" \
  --output table
```

In modalità Single ci aspettiamo che la nuova revision diventi quella attiva.

---

# 23. Verificare v2 dall'esterno

Provare:

```bash
curl -s "https://$ACA_FQDN/health" | python3 -m json.tool
```

Se durante il cambio revision la risposta non è ancora aggiornata, attendere alcuni secondi e ripetere.

Atteso:

```text
version = v2
```

Verificare anche:

```bash
curl -s "https://$ACA_FQDN/api/products" | python3 -m json.tool
```

---

# 24. Osservare la configurazione di scaling

```bash
az containerapp show \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --query properties.template.scale \
  --output jsonc
```

Dovremmo riconoscere:

```text
minReplicas = 0
maxReplicas = 1
```

Non è necessario attendere che la app scenda realmente a zero repliche. Vogliamo capire la configurazione, non passare tempo ad aspettare il timer di scaling.

---

# 25. Raccogliere le evidenze prima del LAB autonomo

Nel file `01_LAB_GUIDATO.md` riportare:

- nome ACR;
- login server;
- repository `catalog-backend`;
- tag `v1` e `v2`;
- Container Apps Environment;
- Container App;
- managed identity system-assigned;
- external ingress;
- target port 8000;
- FQDN;
- revision v1;
- revision v2;
- test v1;
- test v2;
- min/max replicas.

Non riportare ID, token o credenziali.

---

# 26. Non eliminare ancora il Resource Group

Prima del LAB autonomo fermiamoci sulla progressione:

| Operazione svolta manualmente in UD11 | Dove verrà automatizzata |
|---|---|
| test dell'applicazione | UD14 |
| `docker build` | UD14 |
| autenticazione/push verso ACR | UD14 |
| aggiornamento/deployment Container App | UD15 |
| verifica endpoint | UD15 |
| smoke test | UD15 |

Il LAB autonomo utilizzerà la Container App v2 per introdurre un errore controllato sul `targetPort`.

Passare quindi a:

```text
03_LAB_AUTONOMO.md
```

Il Resource Group deve restare disponibile anche durante la verifica individuale. Il cleanup completo verrà eseguito soltanto dopo la verifica.
