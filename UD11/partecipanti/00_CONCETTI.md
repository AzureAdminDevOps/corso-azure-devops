# UD11 — Concetti
## Dall'image locale al deployment manuale in Azure

In UD10 abbiamo costruito ed eseguito le immagini Docker sul nostro computer. Ora facciamo il passo successivo: spostiamo un'image in un **registry privato Azure** e chiediamo ad **Azure Container Apps** di eseguirla.

Il percorso che vogliamo comprendere è:

```text
Dockerfile
   ↓
image locale
   ↓
Azure Container Registry
   ↓
pull autenticato
   ↓
Azure Container App
   ↓
revision
   ↓
HTTPS endpoint
```

Questo percorso verrà automatizzato più avanti da pipeline. In UD11 lo eseguiamo manualmente proprio per vedere tutte le responsabilità: chi fa push, chi fa pull, quale identità viene usata, quale porta deve essere esposta e che cosa succede quando cambia l'image.


## Perché oggi facciamo tutto manualmente

Questa scelta è deliberata.

Prima di automatizzare una procedura dobbiamo capire **quali operazioni stiamo automatizzando**.

In UD11 il partecipante esegue manualmente:

```text
Docker build
→ autenticazione ad ACR
→ tag
→ push
→ creazione Container Apps Environment
→ creazione Container App
→ configurazione identity
→ pull dell'image privata
→ ingress
→ aggiornamento v1 → v2
→ verifica
```

Nelle UD successive una parte crescente di queste operazioni verrà eseguita da una pipeline.

La progressione è quindi:

```text
UD11
operazioni manuali e osservabili
        ↓
UD14
Agent della pipeline
→ test
→ Docker build
→ push ACR
        ↓
UD15
Agent della pipeline
→ deployment
→ aggiornamento Container App
→ smoke test
```

Il principio è importante:

> **automazione non significa saltare la comprensione del processo manuale; significa codificare e rendere ripetibile un processo che abbiamo già compreso.**

In UD11 i comandi vengono eseguiti direttamente nel terminale WSL2 del partecipante.

Il self-hosted Agent configurato in UD09 **non è necessario per svolgere questo laboratorio**. Tuttavia lo stesso ambiente WSL2 e lo stesso Docker saranno poi utilizzabili dall'Agent quando le operazioni entreranno nelle pipeline.

Con un Microsoft-hosted Agent, invece, i comandi verranno eseguiti nell'ambiente temporaneo fornito da Microsoft.

---

# 1. Dal registry locale a un registry condiviso

Un'image Docker costruita sul nostro computer esiste soltanto sul nostro ambiente locale. Un servizio Azure non può eseguirla finché non è disponibile in un registry raggiungibile.

Azure Container Registry, o ACR, fornisce un registry privato nel quale possiamo pubblicare immagini.

```text
workstation
   |
 docker push
   v
ACR
   |
 image pull
   v
Container Apps
```

Push e pull sono due operazioni diverse e possono essere eseguite da identità diverse.

---

# 2. Registry, repository e tag

Consideriamo un riferimento come:

```text
myregistry.azurecr.io/catalog-backend:v1
```

Possiamo scomporlo:

```text
registry/login server
→ myregistry.azurecr.io

repository
→ catalog-backend

tag
→ v1
```

Il registry è il servizio che ospita le immagini. Il repository raggruppa logicamente le versioni della stessa image. Il tag è un'etichetta leggibile associata a un contenuto.

---

# 3. Tag e digest: leggibilità contro identificazione del contenuto

Un tag come:

```text
v1
```

è facile da leggere, ma può essere riutilizzato e quindi puntare in futuro a un contenuto differente.

Un digest:

```text
sha256:...
```

identifica invece il contenuto in modo content-addressed.

Nel laboratorio useremo `v1` e `v2` perché vogliamo vedere chiaramente l'evoluzione. In contesti di release rigorosi, il digest è un riferimento più forte quando serve immutabilità.

---

# 4. Perché non usiamo `latest`

`latest` è semplicemente un tag. Non significa che Docker o Azure abbiano verificato quale sia la versione cronologicamente più recente o approvata.

Con:

```text
catalog-backend:v1
catalog-backend:v2
```

possiamo capire quale versione intendiamo distribuire.

La tracciabilità è importante soprattutto quando dobbiamo rispondere a una domanda operativa:

```text
quale image sta eseguendo questa revision?
```

---

# 5. Azure Container Registry

ACR è una risorsa Azure che fornisce un registry privato.

Nel laboratorio useremo lo SKU `Basic`, sufficiente per una piccola esercitazione.

Creeremo:

```text
ACR
└── repository catalog-backend
    ├── v1
    └── v2
```

A fine giornata elimineremo il Resource Group per evitare di lasciare risorse a pagamento inutilizzate.

---

# 6. Nome ACR e login server non sono esattamente la stessa cosa

L'ACR ha un nome risorsa, per esempio:

```text
acr12345ud11
```

ma l'image usa il **login server** del registry.

Per questo non conviene costruirlo manualmente. Lo leggiamo dalla risorsa:

```bash
az acr show \
  --name <acr> \
  --query loginServer \
  --output tsv
```

In questo modo usiamo il valore effettivo restituito da Azure.

---

# 7. Push manuale: chi siamo quando pubblichiamo l'image?

Dal workstation eseguiamo:

```bash
az acr login --name <acr>
```

Azure CLI usa l'identità con la quale abbiamo eseguito `az login` e ottiene l'autorizzazione necessaria per Docker.

Poi:

```bash
docker push <login-server>/catalog-backend:v1
```

In questa fase **noi**, con la nostra identità, siamo il soggetto che pubblica l'image.

Questo va distinto dal soggetto che farà il pull più avanti.

---

# 8. Azure Container Apps: eseguire container senza gestire direttamente VM o Kubernetes

Azure Container Apps fornisce un ambiente gestito per eseguire applicazioni containerizzate.

I concetti principali che useremo sono:

```text
Container Apps Environment
Container App
Revision
Replica
Ingress
Scaling
```

Non dobbiamo confondere questi livelli.

---

# 9. Container Apps Environment

L'Environment è un boundary condiviso nel quale possono vivere una o più Container App.

```text
Container Apps Environment
├── App A
├── App B
└── App C
```

Non è l'applicazione stessa. È l'ambiente infrastrutturale nel quale le app vengono eseguite.

In UD11 creeremo un Environment e una sola Container App per mantenere chiaro il flusso.

---

# 10. Container App

La Container App descrive l'applicazione che vogliamo eseguire:

- image;
- variabili d'ambiente;
- CPU/memoria;
- ingress;
- scaling;
- identità;
- modalità revision.

Nel laboratorio distribuiremo soltanto il backend del Catalogo prodotti. Questo riduce la complessità e ci permette di concentrarci su ACR, identity, revision e ingress.

---

# 11. Revision: uno snapshot della configurazione applicativa

Una revision rappresenta una versione immutabile della configurazione revision-scope della Container App.

Quando cambiamo elementi come:

```text
image
environment variable
CPU/memory
scale rule
```

Azure può creare una nuova revision.

Questo ci permette di distinguere chiaramente:

```text
v1
→ revision v1

v2
→ revision v2
```

---

# 12. Replica: l'istanza runtime di una revision

La revision è una configurazione/versione. La replica è invece una istanza in esecuzione.

```text
Revision v2
├── Replica 1
└── Replica 2
```

Se `minReplicas=0`, una revision può non avere repliche quando non c'è lavoro da eseguire.

---

# 13. Ingress: portare traffico HTTP verso il container

Per rendere raggiungibile il backend abilitiamo **external ingress**.

Il flusso è:

```text
Internet
   ↓
HTTPS FQDN di Container Apps
   ↓
Ingress
   ↓
target port
   ↓
processo nel container
```

Per traffico HTTP l'endpoint esterno è HTTPS; il `targetPort` indica invece la porta interna sulla quale l'applicazione ascolta.

---

# 14. Target port: deve corrispondere alla porta reale dell'app

Il nostro backend Python ascolta sulla porta:

```text
8000
```

Quindi configureremo:

```text
target port = 8000
```

Se impostiamo `9999`, Azure può avere una Container App esistente e una revision apparentemente presente, ma l'ingress inoltra il traffico verso una porta sulla quale nessun processo sta ascoltando.

Questo sarà il guasto del LAB autonomo.

---

# 15. FQDN: non costruiamo a mano l'URL

Container Apps fornisce un FQDN per l'ingress esterno.

Non dobbiamo indovinare il nome completo. Lo leggiamo dalla risorsa:

```bash
az containerapp show ... \
  --query properties.configuration.ingress.fqdn
```

Questo principio è lo stesso già applicato al login server ACR: quando Azure espone una proprietà, leggiamo il valore reale invece di costruirlo per assunzione.

---

# 16. Environment variable in Container Apps

La configurazione runtime può essere passata alla Container App:

```text
APP_VERSION=v1
LOW_STOCK_THRESHOLD=5
RUNTIME_DIR=/tmp/runtime
```

Se cambiamo `APP_VERSION` o altre variabili revision-scope, viene creata una nuova configurazione/revision.

Questo ci permette di separare:

```text
contenuto dell'image
```

da:

```text
configurazione dell'esecuzione
```

---

# 17. ACR privato: la Container App deve autenticarsi per il pull

Il registry è privato. Quindi la Container App non può semplicemente scaricare l'image come se fosse pubblica.

Potremmo usare username/password del registry, ma questo introdurrebbe credenziali statiche.

Nel corso preferiamo:

```text
Managed Identity
```

perché permette di usare identità e RBAC Azure.

---

# 18. Managed Identity: un'identità legata alla risorsa

Una system-assigned managed identity viene creata e gestita da Azure per la risorsa.

```text
Container App
   |
   +── system-assigned identity
```

Quando la Container App viene eliminata, anche questa identità viene rimossa.


In UD11 usiamo una **system-assigned managed identity** perché rende molto visibile il legame:

```text
Container App
↔
identità della stessa risorsa
```

Più avanti, nella pipeline finale, useremo anche una **user-assigned managed identity**.

La differenza concettuale è:

```text
system-assigned
→ lifecycle legato alla risorsa

user-assigned
→ risorsa identità autonoma
→ può essere preparata e riutilizzata separatamente
```

Entrambe evitano di inserire username/password ACR nel codice applicativo.

L'identità può ricevere ruoli Azure, per esempio il diritto di leggere immagini dal registry.

---

# 19. Prima di `AcrPull`: il modello di autorizzazione del registry

Azure Container Registry supporta oggi due modalità principali per le autorizzazioni ai repository:

```text
RBAC Registry Permissions
```

e:

```text
RBAC Registry + ABAC Repository Permissions
```

Nel secondo modello i ruoli legacy:

```text
AcrPull
AcrPush
AcrDelete
```

non vengono utilizzati per l'accesso repository. Si usano ruoli più recenti come:

```text
Container Registry Repository Reader
Container Registry Repository Writer
```

Nel nostro laboratorio vogliamo concentrarci prima sui concetti base:

```text
identity
→ ruolo minimo
→ pull dell'image
```

Per questo creeremo intenzionalmente ACR in modalità:

```text
RBAC Registry Permissions
```

e useremo:

```text
AcrPull
```

Questa non è una affermazione che RBAC+ABAC sia "sbagliato": è una **scelta didattica controllata**.

Più avanti sarà importante sapere che il ruolo corretto dipende sempre dal modello di autorizzazione configurato sul registry.

---

# 26. `AcrPull`: concedere il minimo necessario

Per eseguire l'applicazione, la Container App deve **leggere** l'image. Non deve pubblicarla.

Quindi il permesso appropriato è:

```text
AcrPull
```

Il principio è:

```text
Container App identity
→ AcrPull sul registry
→ image pull
```

Non serve `AcrPush` alla Container App.

Il push viene eseguito da noi durante il laboratorio; il pull viene eseguito dalla risorsa runtime.

---

# 26. Perché non abilitiamo l'admin user ACR come scorciatoia

ACR può supportare credenziali amministrative, ma abilitarle soltanto perché un role assignment non funziona nasconde il problema e introduce segreti statici.

Se la nostra identità non può creare il ruolo necessario, il problema è di autorizzazione RBAC.

La risposta corretta è:

```text
capire/correggere il permesso
```

non:

```text
bypassare RBAC con password amministrativa
```

---

# 26. Single revision mode

Container Apps può gestire più revision attive oppure una sola revision attiva.

Nel laboratorio useremo un flusso semplice:

```text
v1 attiva
→ update image
→ v2 attiva
```

Questo rende evidente che una nuova image produce una nuova revision senza introdurre ancora il traffic splitting.

---

# 26. Log e revision list come strumenti di verifica

Quando il deployment non funziona, vogliamo poter rispondere a domande come:

```text
quale revision è attiva?
è healthy?
quale image usa?
quanti replica ci sono?
che cosa scrive l'applicazione nei log?
```

Useremo:

```bash
az containerapp revision list
```

per le revision e:

```bash
az containerapp logs show
```

per l'output applicativo.

---

# 26. Scale-to-zero

Configurando:

```text
min replicas = 0
```

la Container App può arrivare a zero repliche quando non deve servire traffico.

Questo riduce il compute inutilizzato, ma non significa che l'intero ambiente Azure sia gratuito o eliminato.

ACR e altre risorse continuano a esistere. Per un laboratorio temporaneo il vero cleanup è:

```text
eliminare il Resource Group
```

---

# 26. Troubleshooting: seguire il percorso della richiesta

Se il FQDN non risponde, non cambiamo subito l'image.

Seguiamo il percorso:

```text
FQDN
↓
ingress external?
↓
target port corretto?
↓
revision attiva/healthy?
↓
replica?
↓
log applicativi?
↓
image/tag presente in ACR?
↓
managed identity / AcrPull?
↓
environment variables?
```

Questa sequenza riduce il numero di modifiche casuali.

---

# 26. Domande di controllo

1. Distingui registry, repository, tag e digest.
2. Perché non conviene basare una release solo sul tag `latest`?
3. Perché il login server ACR va letto dalla risorsa invece di costruirlo manualmente?
4. Qual è la differenza tra Container Apps Environment e Container App?
5. Distingui revision e replica.
6. A che cosa serve ingress?
7. Perché target port deve coincidere con la porta di ascolto dell'applicazione?
8. Perché usare managed identity per il pull da ACR?
9. A che cosa serve `AcrPull`?
10. Che cosa succede tipicamente quando aggiorni l'image di una Container App?
11. Perché in UD11 eseguiamo manualmente operazioni che verranno automatizzate in UD14–UD15?
12. Qual è la differenza fra RBAC Registry Permissions e RBAC+ABAC rispetto ai ruoli `AcrPull`/`AcrPush`?
13. Perché il self-hosted Agent di UD09 non è necessario per svolgere UD11, pur essendo collegato alla progressione del corso?
14. Distingui system-assigned e user-assigned managed identity.
11. Che cosa significa scale-to-zero?
12. Quali controlli eseguiresti se il FQDN restituisce errore dopo una nuova revision?
