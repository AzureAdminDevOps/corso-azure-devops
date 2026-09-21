# UD11 — ACR + Azure Container Apps

## Risultato finale

Al termine avrai completato:

```text
build
→ tag
→ ACR login
→ push v1
→ ACA environment
→ Container App
→ HTTPS
→ v2 build/push
→ nuova revision
→ troubleshooting
→ cleanup
```

## Prerequisiti

### Azure

```bash
az login
az account show --output table
```

### Docker

```bash
docker version
docker info
```

### Azure Container Apps CLI

```bash
az containerapp --help
```

Il Lab guidato contiene la procedura di installazione/aggiornamento dell'estensione se necessario.

### Catalogo prodotti

Il backend della UD10 deve essere nel repository personale.

Verifica:

```bash
cd ~/workspace/azure-devops-lab 2>/dev/null || true
test -f app/catalogo-prodotti/backend/server.py \
  && echo "Backend UD10 presente"
```

Se manca, il Lab contiene una procedura di recupero dagli asset inclusi in UD11.

## Preparazione obbligatoria del LAB

Il `02_LAB_GUIDATO.md` crea manualmente la struttura `consegne/UD11/` e svolge i controlli Azure/Docker uno alla volta. Non viene usato un preflight script: ogni controllo deve essere leggibile e interpretabile dal partecipante.

## Ordine finale della giornata

Le risorse Azure devono rimanere disponibili fino al termine della verifica individuale.

```text
02_LAB_GUIDATO.md
→ 03_LAB_AUTONOMO.md
→ 04_VERIFICA.md
→ cleanup finale
```

Il cleanup completo del Resource Group è riportato alla fine di `04_VERIFICA.md`.

## Consegne

```text
consegne/UD11/
├── 00_DOMANDE_CONCETTI.md
├── 01_LAB_GUIDATO.md
├── 02_LAB_AUTONOMO.md
└── 03_VERIFICA.md
```

## Regola di sicurezza

Non inserire nelle consegne:

- subscription ID;
- tenant ID;
- object ID;
- access token;
- password ACR;
- output `az acr login --expose-token`;
- credenziali Docker.

## Regola RBAC

Il percorso sicuro richiede che l'identità corrente possa creare l'assegnazione:

```text
AcrPull
```

per la managed identity della Container App.

Se Azure restituisce un errore di autorizzazione sull'assegnazione ruolo:

```text
BLOCKED_BY_RBAC
```

Non abilitare l'admin user ACR come workaround.


## Collegamento con la pipeline DevOps

UD11 resta volutamente manuale.

```text
UD11
persona → build → push → deploy → verify

UD14
Agent → test → build → push

UD15
Agent → deploy → smoke test
```

Il self-hosted Agent configurato in UD09 non deve essere avviato per forza durante UD11.

## Nota ACR RBAC/ABAC

Il laboratorio crea il registry con:

```bash
--role-assignment-mode rbac
```

per usare in modo deterministico il ruolo:

```text
AcrPull
```

e mantenere il focus sul concetto di least privilege.

In un registry RBAC+ABAC i ruoli repository sono differenti: non sostituire i ruoli a tentativi.
