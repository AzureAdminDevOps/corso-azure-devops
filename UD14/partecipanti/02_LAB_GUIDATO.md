# UD14 — LAB guidato
## Continuous Integration del Catalogo prodotti

UD14 è divisa in due blocchi temporali.

```text
Giornata 13 → preparazione CI
Giornata 14 → esecuzione, nuova modifica e verifica
```

Nessun cleanup Azure deve interrompere questa continuità.

UD14 è anche il primo confronto operativo tra i due modelli di Agent.

```text
MICROSOFT_HOSTED_READY
→ usare /pipelines/azure-pipelines-ci.yml

Microsoft-hosted non disponibile
→ usare /pipelines/azure-pipelines-ci-selfhosted.yml
```

Si crea **una sola pipeline CI**, scegliendo il file coerente con lo stato documentato in UD12.

---

# PARTE A — FINE GIORNATA 13

# 0. Preparare consegne e repository

```bash
export COURSE_UD14="$HOME/workspace/corso-azure-devops/UD14/partecipanti"
export LAB_REPO="$HOME/workspace/azure-devops-lab"
export LAB_SUBMISSION="$LAB_REPO/consegne/UD14"
```

```bash
mkdir -p "$LAB_SUBMISSION"
```

Copiare i modelli con `cp -n`.

Poi verificare:

```bash
az group exists --name rg-ud13-15-delivery
```

Atteso:

```text
true
```

Verificare ACR:

```bash
az acr list \
  --resource-group rg-ud13-15-delivery \
  --query "[].{Name:name,SKU:sku.name,Admin:adminUserEnabled}" \
  --output table
```

L'admin user deve essere:

```text
false
```

Recuperare il nome ACR:

```bash
export ACR_NAME=$(az acr list \
  --resource-group rg-ud13-15-delivery \
  --query "[0].name" \
  --output tsv)
```

Verificare:

```bash
az acr show \
  --name "$ACR_NAME" \
  --resource-group rg-ud13-15-delivery \
  --query roleAssignmentMode \
  --output tsv
```

La UD13 aggiornata deve produrre il modello equivalente a:

```text
LegacyRegistryPermissions
```

Se non è così, non cambiare il registry a tentativi: verificare di aver usato l'ultima release UD13.

---

# 1. Preparare l'applicazione CI

Copiare l'asset nel repository:

```bash
mkdir -p "$LAB_REPO/app/catalog-backend-ci"
cp -R "$COURSE_UD14/app/catalog-backend-ci/." \
      "$LAB_REPO/app/catalog-backend-ci/"
```

Eseguire localmente i test:

```bash
cd "$LAB_REPO"
python3 -m unittest discover \
  -s app/catalog-backend-ci/tests \
  -v
```

Attesi:

```text
3 test
OK
```

---

# 2. Build Docker locale

Prima della pipeline verifichiamo che il Dockerfile funzioni:

```bash
docker build \
  -t catalog-backend:ud14-local \
  app/catalog-backend-ci
```

Avviare:

```bash
docker run \
  --detach \
  --rm \
  --name catalog-ud14-local \
  --publish 127.0.0.1:18014:8000 \
  catalog-backend:ud14-local
```

Test:

```bash
curl -s http://127.0.0.1:18014/health \
  | python3 -m json.tool
```

Stop:

```bash
docker stop catalog-ud14-local
```

L'immagine locale può rimanere: non interferisce con la pipeline.

---

# 3. Creare la Docker Registry service connection

Recuperare il nome ACR:

```bash
export ACR_NAME=$(az acr list \
  --resource-group rg-ud13-15-delivery \
  --query "[0].name" \
  --output tsv)
```

Aprire Azure DevOps:

```text
Project settings
→ Service connections
→ New service connection
→ Docker Registry
→ Azure Container Registry
```

Authentication Type:

```text
Workload Identity federation
```

Selezionare:

```text
subscription del corso
ACR creato da UD13
```

Nome:

```text
sc-acr-ud14
```

Non concedere automaticamente l'accesso a tutte le pipeline.

Salvare.

La service connection autentica `Docker@2` verso ACR e non dipende dal tipo di Agent scelto.

Se la creazione WIF è bloccata da una policy o autorizzazione esterna, annotare:

```text
BLOCKED_BY_DOCKER_SERVICE_CONNECTION
```

Non abilitare l'admin user ACR e non inserire password nel YAML.

Il Gate verso UD15 richiede comunque che questo blocco venga risolto: senza una Docker Registry service connection valida, `Docker@2 buildAndPush` non può essere considerato riuscito.


---

## Come interpretare il fallback self-hosted

Nel laboratorio:

```text
SELF_HOSTED_FALLBACK
→ riavviamo run.sh nel WSL2 personale
```

In produzione lo stesso fallback potrebbe significare:

```text
Azure Pipelines
→ pool-linux-build
→ uno dei build Agent aziendali già Online
```

La CI del team non dovrebbe dipendere dal fatto che uno sviluppatore tenga acceso il proprio notebook.

# 4. Preparare i due YAML e scegliere il percorso

```bash
mkdir -p "$LAB_REPO/pipelines"
```

Copiare:

```bash
cp "$COURSE_UD14/pipeline/azure-pipelines-ci.yml" \
   "$LAB_REPO/pipelines/azure-pipelines-ci.yml"

cp "$COURSE_UD14/pipeline/azure-pipelines-ci-selfhosted.yml" \
   "$LAB_REPO/pipelines/azure-pipelines-ci-selfhosted.yml"
```

Nel file principale individuare:

```text
trigger main
vmImage ubuntu-latest
stage Test
stage BuildPush
Agent.Name
Agent.OS
Agent.MachineName
python3 --version
docker --version
Docker@2
Build.BuildId
sc-acr-ud14
```

Confrontare poi il fallback:

```text
pool-ud09-wsl
workspace clean all
```

## Scegliere il file

Se lo stato è:

```text
MICROSOFT_HOSTED_READY
```

usare:

```text
/pipelines/azure-pipelines-ci.yml
UD14_AGENT_MODE=MICROSOFT_HOSTED
```

Altrimenti usare:

```text
/pipelines/azure-pipelines-ci-selfhosted.yml
UD14_AGENT_MODE=SELF_HOSTED_FALLBACK
```

Nel secondo caso avviare l'Agent:

```bash
cd "$HOME/azdo-agent"
./run.sh
```

in un terminale dedicato.

---

# 5. Commit

```bash
cd "$LAB_REPO"
git status
```

Aggiungere:

```bash
git add \
  app/catalog-backend-ci \
  pipelines/azure-pipelines-ci.yml \
  pipelines/azure-pipelines-ci-selfhosted.yml
```

Commit:

```bash
git commit -m "feat: add catalog CI pipeline"
git push
```

---

# 6. Creare la pipeline

Azure DevOps:

```text
Pipelines
→ New pipeline
→ GitHub
→ repository
→ Existing Azure Pipelines YAML file
```

L'integrazione GitHub App è già stata introdotta in UD13: non creare nuove credenziali GitHub personali.

Se:

```text
UD14_AGENT_MODE=MICROSOFT_HOSTED
```

scegliere:

```text
/pipelines/azure-pipelines-ci.yml
```

Se:

```text
UD14_AGENT_MODE=SELF_HOSTED_FALLBACK
```

scegliere:

```text
/pipelines/azure-pipelines-ci-selfhosted.yml
```

Creare **una sola pipeline CI**.

Se viene richiesta l'autorizzazione a:

```text
sc-acr-ud14
```

autorizzare soltanto questa pipeline.

---

# 7. Prima run

Eseguire la pipeline.

Seguire:

```text
Test
↓
BuildPush
```

Se Test fallisce, BuildPush non deve partire.

## Percorso Microsoft-hosted

Nei log di `PythonTests` leggere:

```text
Agent.Name
Agent.OS
Agent.MachineName
python3 --version
```

Nei log di `DockerBuild` leggere:

```text
Agent.Name
Agent.OS
Agent.MachineName
docker --version
```

I due `Agent.MachineName` possono essere differenti: i due Job ricevono VM hosted separate.

## Fallback self-hosted

L'Agent deve risultare `Online`.

Verificare nel WSL2:

```bash
docker info
```

Il YAML pulisce il workspace prima di ciascun Job.

---

# FINE GIORNATA 13

A fine giornata **non fare cleanup**.

Se stai usando il fallback self-hosted, puoi fermare `run.sh` per liberare il terminale.

Se stai usando Microsoft-hosted, `run.sh` locale non è coinvolto.

Non eliminare:

```text
agent configurato
ACR
service connections
pipeline
immagini
```

---

# PARTE B — INIZIO GIORNATA 14

# 8. Verificare l'ambiente scelto

Se:

```text
UD14_AGENT_MODE=MICROSOFT_HOSTED
```

non avviare il self-hosted Agent locale: non viene usato dalla pipeline.

Se:

```text
UD14_AGENT_MODE=SELF_HOSTED_FALLBACK
```

avviare:

```bash
cd "$HOME/azdo-agent"
./run.sh
```

e verificare `Online`.

---

# 9. Verificare la run CI

Se la run del giorno precedente non era stata completata, eseguirla ora.

Poi verificare ACR:

```bash
export ACR_NAME=$(az acr list \
  --resource-group rg-ud13-15-delivery \
  --query "[0].name" \
  --output tsv)
```

```bash
az acr repository show-tags \
  --name "$ACR_NAME" \
  --repository catalog-backend \
  --orderby time_desc \
  --output table
```

Deve comparire almeno un tag numerico corrispondente a una Build ID.

---

# 10. Leggere i log

Nel Portale Azure DevOps aprire la run.

Individuare:

```text
Stage Test
→ Job PythonTests
→ Run Python tests

Stage BuildPush
→ Job DockerBuild
→ Docker@2
```

Nella consegna indicare:

- `UD14_AGENT_MODE`;
- `Agent.Name` e `Agent.OS` osservati;
- quale step ha eseguito i test;
- quale step ha costruito l'immagine;
- il tag pubblicato.

---

# 11. Passare al LAB autonomo

Il LAB autonomo introduce un fallimento controllato dei test e usa branch/PR.

Non eseguire cleanup.
