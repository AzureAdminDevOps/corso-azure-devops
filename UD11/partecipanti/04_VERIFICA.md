# UD11 — Verifica individuale

## Parte A — Scelta singola

### 1. In `myacr.example/catalog-backend:v2`, `catalog-backend` è:

- A. registry
- B. repository
- C. revision
- D. environment

### 2. Per ottenere il login server ACR corretto è preferibile:

- A. costruirlo sempre come `<name>.azurecr.io`
- B. leggerlo con `az acr show --query loginServer`
- C. usare `localhost`
- D. usare l'ID subscription

### 3. `az acr login --name` richiede:

- A. il nome della risorsa ACR
- B. sempre il login server completo
- C. la password admin
- D. il nome della revision

### 4. Una Container Apps revision è:

- A. una VM
- B. uno snapshot immutabile di una versione/configurazione della app
- C. una replica
- D. un repository ACR

### 5. Una replica è:

- A. una istanza in esecuzione di una revision
- B. un tag ACR
- C. un Resource Group
- D. una service connection

### 6. Per permettere a una Container App di leggere un ACR privato senza password si può usare:

- A. managed identity
- B. tag Git
- C. public IP
- D. Log Analytics

### 7. `AcrPull` fornisce:

- A. autorizzazione a eliminare subscription
- B. pull delle immagini dal registry nel modello RBAC appropriato
- C. RDP
- D. gestione DNS

### 8. Con `minReplicas=0`:

- A. la app viene eliminata
- B. la app può scalare a zero repliche quando non necessarie
- C. ACR viene eliminato
- D. non esiste ingress

---

## Parte B — Risposte brevi

### 9. Distingui tag e digest.

### 10. Distingui Container Apps Environment, Container App, revision e replica.

### 11. Perché il corso usa managed identity invece di ACR admin credentials?

### 12. Perché una nuova image normalmente produce una nuova revision?

### 13. Che cosa deve coincidere tra backend e ingress target port?

### 14. Elenca almeno cinque controlli per una Container App non raggiungibile.


### 15. Perché il laboratorio UD11 esegue manualmente build, push e deployment invece di partire subito da una pipeline?

### 16. Se un registry è configurato in modalità RBAC+ABAC, perché non puoi dare per scontato che `AcrPull` sia il ruolo corretto?

### 17. In che modo il lavoro manuale di UD11 prepara UD14 e UD15?

### 18. Distingui system-assigned e user-assigned managed identity.

---

## Parte C — Scenario

> ACR contiene `catalog-backend:v2`. La revision corrente è Healthy. I log mostrano `listening on 0.0.0.0:8000`. L'ingress è external ma `targetPort=9000`. Il FQDN restituisce errore.

### 15. Qual è la causa più probabile e qual è la correzione minima?

### 16. Quali verifiche eseguiresti dopo la correzione prima di dichiarare risolto il problema?

---

# Dopo la verifica — Cleanup finale della UD11

Questa sezione va eseguita soltanto dopo aver completato e salvato la verifica individuale.

ACR Basic e le altre risorse Azure continuano a esistere finché il Resource Group non viene eliminato, quindi il cleanup finale è parte integrante del laboratorio.

## 1. Reimpostare il nome del Resource Group

Da WSL2:

```bash
export LAB_RG="rg-ud11-containers"
```

Verificare di essere nella subscription corretta:

```bash
az account show \
  --query "{Subscription:name,User:user.name}" \
  --output table
```

## 2. Controllare le risorse che stiamo per eliminare

```bash
az resource list \
  --resource-group "$LAB_RG" \
  --query "[].{Name:name,Type:type,Location:location}" \
  --output table
```

Il controllo serve a evitare di eliminare un Resource Group diverso da quello del laboratorio.

## 3. Eliminare il Resource Group UD11

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

## 4. Pulire le immagini Docker locali della UD11

Tornare al repository:

```bash
export LAB_REPO="$HOME/workspace/azure-devops-lab"
cd "$LAB_REPO/app/catalog-backend-cloud"
```

Le immagini locali usate nella UD sono:

```text
catalog-backend:ud11-v1
catalog-backend:ud11-v2
```

Rimuoverle:

```bash
docker image rm \
  catalog-backend:ud11-v1 \
  catalog-backend:ud11-v2
```

Le immagini taggate con il login server ACR possono essere individuate con:

```bash
docker image ls
```

Se sono ancora presenti, rimuovere soltanto i tag relativi al registry creato nella UD.

Non usare un `docker system prune` globale.

Il cleanup della UD11 è ora completo.

