# UD10 — Concetti Docker
## Dal programma locale a un ambiente ripetibile con container

Nella UD08 abbiamo eseguito il Catalogo prodotti direttamente con Python sul nostro ambiente WSL2. Quel metodo funziona, ma dipende dal fatto che sulla macchina siano presenti la versione corretta di Python, i file giusti e una configurazione compatibile.

In questa UD introduciamo Docker per rendere più ripetibile l'ambiente di esecuzione.

L'idea fondamentale è:

```text
codice + runtime + configurazione di base
                ↓
              image
                ↓
             container
```

Non useremo ancora Azure Container Registry o servizi cloud. Prima vogliamo capire che cosa succede **localmente**, perché nelle UD successive le stesse immagini verranno pubblicate e distribuite in Azure.

---

# 1. Il problema che i container cercano di risolvere

Un'applicazione non dipende soltanto dal proprio codice. Dipende anche da:

- runtime;
- librerie;
- filesystem;
- variabili d'ambiente;
- porte;
- configurazione;
- sistema operativo e tool disponibili.

Questo spiega la frase classica:

```text
"sul mio computer funziona"
```

Un container non elimina tutti i problemi di compatibilità, ma ci permette di definire in modo molto più esplicito l'ambiente nel quale l'applicazione deve partire.

---

# 2. Image e container: progetto ed esecuzione

Una **image** è un artefatto immutabile utilizzato per creare container.

Esempi:

```text
python:3.13-slim
nginx:alpine
catalog-backend:ud10
```

Una image non è un processo in esecuzione.

Un **container** è invece una istanza runtime creata a partire da un'image.

```text
catalog-backend:ud10
      |
      +── container 1
      +── container 2
      +── container 3
```

La stessa image può quindi essere utilizzata per avviare più container.

---

# 3. Container e VM non sono la stessa cosa

Una macchina virtuale virtualizza un computer e normalmente esegue un sistema operativo guest completo.

```text
hardware
→ hypervisor
→ guest OS
→ applicazione
```

Un container usa un modello differente:

```text
host / kernel Linux
→ runtime container
→ processi isolati
```

Per questo dire semplicemente "un container è una VM più leggera" è impreciso. I due strumenti risolvono alcuni problemi simili, ma con un'architettura diversa.

---

# 4. Docker Desktop e WSL2 nel nostro laboratorio

Su Windows useremo:

```text
Windows 10/11
→ WSL2 Ubuntu
→ Docker Desktop
→ Docker Engine
→ Docker CLI da Ubuntu
```

Docker Desktop integra il motore Docker con WSL2. Quando l'integrazione è abilitata, nella shell Ubuntu possiamo eseguire:

```bash
docker version
```

senza installare un secondo Docker Engine dentro la distribuzione.

Questo è importante: installare contemporaneamente Docker Desktop e un'altra installazione Docker Engine nella stessa distribuzione WSL può creare confusione e conflitti.

## 4.1 Perché Docker in WSL2 è collegato agli Agent di Azure Pipelines

Nella UD09 abbiamo definito l'**Agent** come l'esecutore materiale dei Job di una pipeline. In UD10 non eseguiamo ancora una pipeline Docker: lavoriamo manualmente per capire build, run, rete, volumi e troubleshooting. Tuttavia stiamo preparando una capacità che sarà usata più avanti dall'automazione.

Con il nostro **self-hosted Agent**, l'esecuzione avviene nello stesso ambiente WSL2 del partecipante. Se una pipeline futura contiene:

```bash
docker build ...
docker push ...
```

l'Agent deve poter raggiungere realmente Docker dal proprio ambiente. Per questo oggi verifichiamo:

```bash
docker version
docker compose version
docker info
```

Il rapporto è quindi:

```text
Pipeline YAML
    ↓
Job
    ↓
self-hosted Agent
    ↓
WSL2
    ↓
Docker CLI → Docker Engine
```

Con un **Microsoft-hosted Agent** il principio non cambia, ma cambia chi prepara la macchina. L'ambiente del Job viene predisposto da Microsoft a partire dall'immagine scelta, ad esempio `ubuntu-latest`. La pipeline deve comunque verificare che il tool necessario sia disponibile e compatibile; non deve affidarsi alla memoria di ciò che era installato in un Job precedente.

Questa distinzione sarà utilizzata nelle UD di pipeline:

```text
self-hosted
→ tool e configurazione sotto il nostro controllo
→ ambiente persistente tra una esecuzione e l'altra

Microsoft-hosted
→ ambiente gestito da Microsoft
→ ambiente nuovo per il Job
→ tool disponibili in base all'immagine hosted
```

## 4.2 Oggi manuale, più avanti automatizzato

In UD10 il partecipante esegue direttamente:

```text
docker build
docker run
docker compose up
docker logs
docker inspect
```

Questo è intenzionale. Prima di affidare queste azioni a una pipeline dobbiamo saperle eseguire e diagnosticare manualmente. Nelle UD finali sarà un Agent a eseguire parte delle stesse operazioni.

---

# 5. Dal codice sorgente all'image: che cosa significa davvero "costruire un'immagine Docker"

Prima di parlare delle singole istruzioni del Dockerfile è importante capire **il processo complessivo**.

Nel nostro repository abbiamo, tra gli altri, questi file:

```text
catalogo-prodotti/
├── backend/
│   └── server.py
├── frontend/
│   └── index.html
├── docker/
│   ├── backend.Dockerfile
│   ├── frontend.Dockerfile
│   └── nginx.conf
├── compose.yaml
└── .dockerignore
```

Il file Python:

```text
backend/server.py
```

da solo **non è un'immagine Docker**.

È semplicemente codice sorgente.

Per ottenere un'image dobbiamo combinare:

```text
un'immagine di partenza
+
il nostro codice
+
eventuali file di configurazione
+
istruzioni di costruzione
```

Il risultato è un nuovo artefatto locale che Docker può usare per creare container.

Nel nostro caso:

```text
python:3.13-slim
        +
backend/server.py
        +
backend.Dockerfile
        ↓
docker build
        ↓
catalog-backend:ud10
```

Questa trasformazione è la **build dell'image**.

È importante distinguere subito tre momenti:

```text
CODICE
→ file del progetto

BUILD
→ Docker costruisce un'image

RUN
→ Docker crea un container a partire dall'image
```

Quindi:

> `docker build` non avvia la nostra applicazione.

Costruisce l'artefatto da cui, successivamente, potremo avviarla.

---

# 6. Il Dockerfile è la ricetta della build

Il Dockerfile descrive **come ottenere l'image**.

Il Dockerfile reale del backend della UD10 è:

```dockerfile
FROM python:3.13-slim

WORKDIR /app

COPY backend/server.py /app/server.py

RUN useradd --create-home --uid 10001 appuser \
    && mkdir -p /runtime \
    && chown -R appuser:appuser /app /runtime

USER appuser

ENV APP_HOST=0.0.0.0 \
    APP_PORT=8000 \
    LOW_STOCK_THRESHOLD=5 \
    RUNTIME_DIR=/runtime

EXPOSE 8000

CMD ["python", "/app/server.py"]
```

Non dobbiamo leggerlo come un insieme di parole chiave da memorizzare.

Dobbiamo leggerlo come una sequenza logica:

```text
1. parti da un ambiente che contiene Python
2. usa /app come directory di lavoro
3. copia il nostro programma nell'image
4. crea un utente non privilegiato e la directory runtime
5. esegui l'applicazione come utente non root
6. definisci valori di configurazione predefiniti
7. documenta che l'app usa la porta 8000
8. definisci il comando da eseguire quando nascerà il container
```

Il Dockerfile è quindi una **descrizione ripetibile della costruzione dell'ambiente applicativo**.

Se un altro computer dispone di Docker e degli stessi file di progetto, può eseguire la stessa build senza dover configurare manualmente Python nello stesso modo.

---

# 7. Che cosa succede quando eseguiamo `docker build`

Nel laboratorio useremo:

```bash
docker build \
  --tag catalog-backend:ud10 \
  --file docker/backend.Dockerfile \
  .
```

Vediamolo come un processo, non soltanto come un comando.

## 7.1 Docker individua il Dockerfile

Con:

```text
--file docker/backend.Dockerfile
```

stiamo dicendo quale ricetta usare.

Non è obbligatorio chiamare il file semplicemente `Dockerfile`: in questa UD usiamo due Dockerfile distinti, uno per il backend e uno per il frontend.

---

## 7.2 Docker determina il build context

Il punto finale:

```text
.
```

significa:

```text
usa la directory corrente come build context
```

Il **build context** è l'insieme dei file che il builder può utilizzare durante la costruzione.

Nel nostro caso, trovandoci in:

```text
app/catalogo-prodotti/
```

il context contiene, salvo esclusioni di `.dockerignore`:

```text
backend/
frontend/
docker/
compose.yaml
...
```

Questo spiega perché nel Dockerfile possiamo scrivere:

```dockerfile
COPY backend/server.py /app/server.py
```

Docker può copiare quel file perché:

```text
backend/server.py
```

si trova dentro il build context.

Se il file fosse fuori dal context, il `COPY` non potrebbe usarlo.

---

## 7.3 `.dockerignore` riduce ciò che entra nel context

Prima della build Docker considera anche:

```text
.dockerignore
```

Il suo scopo è evitare di mandare al builder file inutili o sensibili.

Per esempio:

```text
.git
__pycache__
*.log
.env
consegne
```

La logica è:

```text
directory del progetto
        ↓
.dockerignore
        ↓
build context effettivo
        ↓
Docker builder
```

Questo migliora efficienza e riduce il rischio che materiale non necessario venga considerato nella build.

`.dockerignore` non è la stessa cosa di `.gitignore`:

```text
.gitignore
→ cosa Git non deve versionare

.dockerignore
→ cosa Docker non deve inserire nel build context
```

---

# 8. La prima istruzione: `FROM`

La build comincia da:

```dockerfile
FROM python:3.13-slim
```

Docker cerca l'image base:

```text
python:3.13-slim
```

Se è già disponibile localmente può riutilizzarla.

Se non lo è, deve recuperarla da un registry configurato, normalmente Docker Hub nel nostro scenario.

Quindi il processo può essere:

```text
Dockerfile
   ↓
FROM python:3.13-slim
   ↓
image già locale?
   ├─ sì → riuso
   └─ no → pull dal registry
```

La nostra image non nasce quindi dal nulla.

È costruita **sopra un'image base** che contiene già filesystem e runtime Python.

---

# 9. `WORKDIR`: stabilire dove lavoreranno i passaggi successivi

Con:

```dockerfile
WORKDIR /app
```

creiamo/impostiamo una directory di lavoro nell'image.

Le istruzioni successive possono riferirsi a quella posizione come directory corrente.

Concettualmente:

```text
filesystem image
/
└── app/
```

Non significa che `/app` esista sul nostro Windows o nel repository.

È un percorso **dentro l'image e poi dentro il container**.

---

# 10. `COPY`: incorporare il codice nell'image

La riga:

```dockerfile
COPY backend/server.py /app/server.py
```

prende:

```text
backend/server.py
```

dal build context e lo inserisce nel filesystem dell'image come:

```text
/app/server.py
```

Dopo questo passaggio possiamo immaginare:

```text
IMAGE IN COSTRUZIONE

/
└── app/
    └── server.py
```

Questo è un passaggio fondamentale.

Il container non eseguirà direttamente il file presente nella directory Git del partecipante.

Eseguirà **la copia inserita nell'image durante la build**.

Di conseguenza, se modifichiamo `server.py` dopo avere costruito l'image:

```text
file sorgente modificato
≠
image automaticamente modificata
```

Per incorporare la nuova versione normalmente dovremo ricostruire l'image.

---

# 11. `RUN`: eseguire operazioni durante la costruzione

Nel nostro Dockerfile troviamo:

```dockerfile
RUN useradd --create-home --uid 10001 appuser \
    && mkdir -p /runtime \
    && chown -R appuser:appuser /app /runtime
```

`RUN` viene eseguito **durante `docker build`**.

Non va confuso con `CMD`.

Qui stiamo preparando il filesystem e l'utente dell'image:

```text
crea appuser
→ crea /runtime
→ assegna i permessi
```

Queste modifiche entrano nell'image finale.

La distinzione importante è:

```text
RUN
→ eseguito durante la BUILD

CMD
→ eseguito quando parte il CONTAINER
```

---

# 12. `USER`: non eseguire l'applicazione come root

Dopo avere creato:

```text
appuser
```

il Dockerfile contiene:

```dockerfile
USER appuser
```

Da questo punto il comando applicativo verrà eseguito con quell'utente.

Nel nostro laboratorio non serve entrare in tutti i dettagli della sicurezza Linux, ma è importante capire il principio:

> se l'applicazione non ha bisogno dei privilegi di root, è preferibile non eseguirla come root.

Questa impostazione è già incorporata nell'image e verrà quindi riutilizzata ogni volta che nascerà un container da quell'image.

---

# 13. `ENV`: valori predefiniti incorporati nell'image

Il backend definisce:

```dockerfile
ENV APP_HOST=0.0.0.0 \
    APP_PORT=8000 \
    LOW_STOCK_THRESHOLD=5 \
    RUNTIME_DIR=/runtime
```

Sono valori predefiniti disponibili quando il container parte.

Ma non sono necessariamente valori immutabili.

Possiamo sovrascriverli al runtime, per esempio:

```bash
docker run \
  --env LOW_STOCK_THRESHOLD=10 \
  ...
```

Questo ci permette di usare:

```text
stessa image
+
configurazioni runtime diverse
```

senza dover ricostruire l'image per ogni valore.

---

# 14. `EXPOSE`: documentare una porta, non pubblicarla

Il Dockerfile contiene:

```dockerfile
EXPOSE 8000
```

Questa riga comunica che l'applicazione è progettata per ascoltare sulla porta 8000.

Non crea però automaticamente questo collegamento:

```text
PC → container
```

Per rendere una porta del container raggiungibile dall'host dovremo configurare la pubblicazione al runtime.

Per esempio:

```bash
docker run \
  --publish 127.0.0.1:8000:8000 \
  ...
```

La differenza è:

```text
EXPOSE 8000
→ informazione nell'image

-p 127.0.0.1:8000:8000
→ pubblicazione reale della porta quando nasce il container
```

---

# 15. `CMD`: che cosa deve partire nel container

Il Dockerfile termina con:

```dockerfile
CMD ["python", "/app/server.py"]
```

Questa istruzione non viene eseguita durante la build.

Definisce invece il comando predefinito che verrà eseguito quando Docker creerà un container da quell'image.

Quindi:

```text
docker build
→ costruisce catalog-backend:ud10
→ NON avvia server.py

docker run catalog-backend:ud10
→ crea un container
→ esegue python /app/server.py
```

Questa distinzione deve essere molto chiara.

---

# 16. Layer e cache: come Docker evita di rifare tutto

Durante la build Docker organizza il risultato in layer.

Senza entrare nei dettagli interni del formato OCI, possiamo pensare:

```text
python:3.13-slim
        ↓
WORKDIR /app
        ↓
COPY server.py
        ↓
RUN useradd...
        ↓
USER appuser
        ↓
ENV ...
        ↓
image finale
```

Quando ricostruiamo l'image, Docker può riutilizzare passaggi che non sono cambiati.

Per questo nei log possiamo vedere:

```text
CACHED
```

Se invece modifichiamo:

```text
backend/server.py
```

il passaggio:

```dockerfile
COPY backend/server.py /app/server.py
```

non potrà più riutilizzare esattamente il risultato precedente e anche i passaggi successivi potrebbero dover essere ricostruiti.

L'ordine del Dockerfile ha quindi effetti pratici sulla cache e sui tempi di build.

---

# 17. `--tag`: dare un nome all'image costruita

Il comando:

```bash
docker build \
  --tag catalog-backend:ud10 \
  ...
```

assegna:

```text
catalog-backend
```

come nome del repository locale dell'image e:

```text
ud10
```

come tag.

Possiamo leggerlo come:

```text
catalog-backend : ud10
      nome       versione/etichetta
```

Il tag non è necessariamente una vera versione semantica.

È un'etichetta che permette di riferirci a quell'image.

Anche:

```text
latest
```

è soltanto un tag convenzionale: non significa automaticamente "la versione più nuova esistente".

---

# 18. Il risultato della build: l'image locale

Quando la build termina con successo:

```text
Dockerfile
+
build context
+
image base
        ↓
Docker builder
        ↓
catalog-backend:ud10
```

possiamo verificare:

```bash
docker image ls catalog-backend:ud10
```

A questo punto abbiamo un'image.

Non abbiamo ancora necessariamente un container.

Possiamo anche esaminare la cronologia di costruzione:

```bash
docker history catalog-backend:ud10
```

e riconoscere il rapporto fra Dockerfile e image risultante.

---

# 19. Dall'image al container: `docker run`

Ora possiamo eseguire:

```bash
docker run \
  --detach \
  --name catalog-backend-ud10 \
  --publish 127.0.0.1:8000:8000 \
  --env LOW_STOCK_THRESHOLD=5 \
  catalog-backend:ud10
```

Qui cambia completamente la fase.

Non stiamo più costruendo.

Stiamo chiedendo:

```text
prendi catalog-backend:ud10
        ↓
crea un container
        ↓
applica configurazione runtime
        ↓
esegui CMD
```

Il risultato è:

```text
IMAGE
catalog-backend:ud10
        ↓ docker run
CONTAINER
catalog-backend-ud10
        ↓
python /app/server.py
```

Una stessa image può generare più container:

```text
catalog-backend:ud10
      ├── container A
      ├── container B
      └── container C
```

Quindi:

```text
image
→ artefatto riutilizzabile

container
→ istanza in esecuzione di quell'artefatto
```

---

# 20. Porte: host e container sono due spazi diversi

Il backend ascolta dentro il container sulla porta:

```text
8000
```

Con:

```text
--publish 127.0.0.1:8000:8000
```

costruiamo questa relazione:

```text
HOST
127.0.0.1:8000
        ↓
CONTAINER
porta 8000
```

Il primo `8000` appartiene all'host.

Il secondo appartiene al container.

In UD10 usiamo:

```text
127.0.0.1
```

perché vogliamo che il servizio sia raggiungibile soltanto localmente.

---

# 21. Il frontend ha una propria image

La UD non contiene soltanto il backend.

Abbiamo anche:

```text
frontend/index.html
docker/frontend.Dockerfile
docker/nginx.conf
```

Il Dockerfile frontend parte da:

```dockerfile
FROM nginx:alpine
```

poi copia:

```text
nginx.conf
→ configurazione Nginx

index.html
→ contenuto web
```

Il risultato sarà una seconda image:

```text
catalog-frontend:ud10
```

Quindi l'applicazione complessiva non è:

```text
un solo container
```

ma:

```text
frontend
+
backend
```

ed è proprio qui che diventa utile Docker Compose.

---

# 22. Perché molti `docker run` diventano scomodi

Senza Compose potremmo gestire tutto manualmente.

Dovremmo, concettualmente:

```text
1. costruire image backend
2. costruire image frontend
3. creare una rete Docker
4. creare un volume
5. avviare backend
6. collegarlo alla rete
7. montare il volume
8. impostare environment variable
9. avviare frontend
10. collegarlo alla stessa rete
11. pubblicare 127.0.0.1:8080
12. assicurarci che il backend sia pronto
```

Potremmo farlo con molti comandi `docker build`, `docker network`, `docker volume` e `docker run`.

Ma più aumenta il numero di componenti, più aumenta il rischio di:

```text
dimenticare un parametro
usare una porta diversa
usare una rete sbagliata
dimenticare un volume
avviare i servizi nell'ordine errato
```

Docker Compose nasce per descrivere questo insieme in modo dichiarativo.

---

# 23. Che cos'è Docker Compose, in generale

**Docker Compose** è uno strumento per definire e gestire un'applicazione composta da più container usando un file YAML.

Nel file descriviamo lo **stato desiderato**:

```text
quali servizi esistono
quali image usare o costruire
quali variabili d'ambiente
quali porte pubblicare
quali reti creare
quali volumi usare
quali dipendenze esistono
quali healthcheck eseguire
```

Invece di ripetere manualmente molti comandi:

```bash
docker run ...
docker run ...
docker network create ...
docker volume create ...
```

scriviamo una configurazione:

```yaml
services:
  backend:
    ...

  frontend:
    ...
```

e poi chiediamo a Compose:

```bash
docker compose up
```

di realizzare quella configurazione.

È utile distinguere:

```text
Dockerfile
→ descrive COME costruire UNA image

Compose
→ descrive COME far funzionare INSIEME più servizi/container
```

Questa distinzione è fondamentale.

Compose **non sostituisce il Dockerfile**.

Può usare uno o più Dockerfile per costruire le image dei servizi.

---

# 24. Docker Compose non è un orchestratore di cluster

Compose è molto utile:

```text
sul computer dello sviluppatore
nei laboratori
nei test locali
in semplici ambienti single-host
```

Non va però confuso con piattaforme di orchestrazione distribuita come Kubernetes.

Nel nostro corso Compose serve a gestire più container **sullo stesso Docker Engine locale**.

Quindi:

```text
Docker Compose
→ multi-container su un host Docker

Kubernetes
→ orchestrazione di workload su un cluster
```

Non approfondiremo Kubernetes in questa UD, ma la distinzione evita di attribuire a Compose un ruolo che non ha.

---

# 25. Il nostro `compose.yaml`: leggere prima l'architettura

Il file reale della UD10 definisce:

```yaml
services:
  backend:
    ...
  frontend:
    ...

networks:
  catalog-net:
    driver: bridge

volumes:
  catalog-runtime:
```

Possiamo quindi dedurre già l'architettura:

```text
due servizi
+
una rete
+
un volume
```

Più precisamente:

```text
Browser / curl
        |
        v
127.0.0.1:8080
        |
        v
frontend
Nginx :80
        |
        | rete catalog-net
        v
backend
Python :8000
        |
        v
volume catalog-runtime
```

---

# 26. `services`: ogni servizio descrive un componente

Nel Compose troviamo:

```yaml
services:
  backend:
    ...
  frontend:
    ...
```

Un servizio Compose non è esattamente "il container già esistente".

È la **descrizione di come quel componente deve essere eseguito**.

Da un servizio Compose Docker creerà normalmente uno o più container.

Nel nostro laboratorio avremo un container backend e un container frontend.

---

# 27. `build`: Compose può costruire le image

Per il backend troviamo:

```yaml
build:
  context: .
  dockerfile: docker/backend.Dockerfile
```

Questo significa che Compose deve eseguire concettualmente una build equivalente a:

```bash
docker build \
  --file docker/backend.Dockerfile \
  .
```

Il file contiene anche:

```yaml
image: catalog-backend:ud10
```

quindi l'image risultante avrà quel nome/tag.

Il frontend ha una configurazione analoga e produce:

```text
catalog-frontend:ud10
```

Quindi:

```text
docker compose up --build
```

può:

```text
leggere compose.yaml
→ trovare i servizi che hanno build:
→ leggere i relativi Dockerfile
→ costruire le image
→ creare i container
```

Compose non "inventa" l'image.

Coordina la build usando le istruzioni definite nei Dockerfile.

---

# 28. Che cosa significa `docker compose up -d --build`

Nel laboratorio useremo:

```bash
docker compose up -d --build
```

Possiamo leggerlo in tre parti.

## `docker compose`

Usa il progetto Compose della directory corrente.

## `up`

Porta lo stack nello stato descritto dal file:

```text
rete presente
volume presente
container presenti
servizi avviati
```

## `-d`

Avvia i container in background:

```text
detached mode
```

## `--build`

Chiede di eseguire/rieseguire la build delle image prima dell'avvio quando necessario.

Concettualmente:

```text
compose.yaml
      ↓
analisi servizi
      ↓
build image backend
build image frontend
      ↓
creazione rete catalog-net
creazione volume catalog-runtime
      ↓
creazione container backend
      ↓
healthcheck backend
      ↓
creazione/avvio frontend
      ↓
stack disponibile
```

Questa è la sequenza che il partecipante deve avere in mente quando esegue un solo comando Compose.

---

# 29. Environment: configurazione runtime del backend

Nel servizio backend troviamo:

```yaml
environment:
  APP_PORT: "8000"
  LOW_STOCK_THRESHOLD: "5"
  RUNTIME_DIR: "/runtime"
```

Questi valori vengono applicati **quando nasce il container**, non durante la build.

Quindi:

```text
Dockerfile ENV
→ default nell'image

Compose environment
→ configurazione del container
→ può sovrascrivere il default
```

Questo è molto importante nel LAB autonomo.

Quando imposteremo intenzionalmente:

```text
LOW_STOCK_THRESHOLD=not-a-number
```

non staremo creando una cattiva image.

Staremo avviando la stessa image con una configurazione runtime errata.

Perciò il troubleshooting deve distinguere:

```text
problema di build?
oppure
problema di configurazione runtime?
```

---

# 30. `volumes`: persistenza indipendente dal container

Il backend usa:

```yaml
volumes:
  - catalog-runtime:/runtime
```

e in fondo al file troviamo:

```yaml
volumes:
  catalog-runtime:
```

Compose crea/gestisce un **named volume**.

Il mapping è:

```text
volume Docker catalog-runtime
        ↓
/runtime nel container backend
```

Questo permette ai dati scritti in `/runtime` di vivere indipendentemente dal singolo container.

Quindi:

```text
rimuovo/recreo il container
≠
devo necessariamente perdere il volume
```

Per eliminare esplicitamente anche i volumi useremo:

```bash
docker compose down -v
```

solo quando vogliamo davvero rimuovere i dati.

---

# 31. `networks`: creare una rete privata fra i servizi

Il Compose definisce:

```yaml
networks:
  catalog-net:
    driver: bridge
```

e collega sia backend sia frontend a:

```text
catalog-net
```

Questo permette:

```text
frontend
↔
backend
```

senza dover conoscere gli IP interni.

Docker offre DNS interno sulla rete e il frontend può raggiungere il backend usando il nome del servizio:

```text
backend
```

Per questo nel file Nginx troviamo:

```nginx
proxy_pass http://backend:8000;
```

`backend` qui non è un hostname configurato nel DNS aziendale.

È il **nome del servizio Compose**, risolvibile nella rete Docker.

---

# 32. Perché `localhost` non funzionerebbe fra frontend e backend

Dentro il container frontend:

```text
localhost
```

significa:

```text
il container frontend stesso
```

Non significa:

```text
container backend
```

e non significa nemmeno automaticamente:

```text
Windows / WSL2 host
```

Quindi questa configurazione sarebbe concettualmente errata:

```text
frontend → http://localhost:8000
```

perché il backend è un altro container.

La configurazione corretta sfrutta il DNS della rete Compose:

```text
frontend → http://backend:8000
```

---

# 33. `expose` e `ports`: backend interno, frontend pubblico

Il backend contiene:

```yaml
expose:
  - "8000"
```

ma non contiene:

```yaml
ports:
```

Il frontend invece contiene:

```yaml
ports:
  - "127.0.0.1:8080:80"
```

Il risultato è intenzionale:

```text
HOST
127.0.0.1:8080
        ↓
frontend:80
        ↓
catalog-net
        ↓
backend:8000
```

Il backend non deve essere raggiunto direttamente dall'host nell'architettura Compose.

Il browser entra dal frontend e Nginx inoltra:

```text
/api/*
/health
```

verso il backend.

Questo è diverso dal primo test con `docker run`, dove avevamo pubblicato direttamente la porta 8000 per verificare il backend isolatamente.

---

# 34. Nginx come frontend e reverse proxy

La nostra image frontend usa Nginx.

Nginx svolge due ruoli:

```text
1. serve index.html
2. inoltra alcune richieste al backend
```

Nel file:

```text
docker/nginx.conf
```

troviamo, per esempio:

```nginx
location /api/ {
    proxy_pass http://backend:8000;
}
```

Il browser quindi non deve conoscere la topologia Docker interna.

Chiama:

```text
http://127.0.0.1:8080/api/products
```

e il percorso reale diventa:

```text
Browser
  ↓
frontend Nginx :80
  ↓
backend:8000
```

Questo rende l'architettura più comprensibile e più simile a una separazione reale fra livello web e API.

---

# 35. Healthcheck: processo avviato non significa servizio pronto

Il backend definisce un healthcheck Compose:

```yaml
healthcheck:
  test:
    [
      "CMD",
      "python",
      "-c",
      "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2)"
    ]
```

Docker esegue periodicamente questo controllo **dentro il contesto del container backend**.

Lo stato può essere:

```text
starting
healthy
unhealthy
```

Quindi:

```text
container running
```

significa che il processo esiste.

```text
container healthy
```

significa che il controllo applicativo definito ha avuto successo.

Sono due livelli differenti.

---

# 36. `depends_on`: attendere che il backend sia healthy

Il frontend contiene:

```yaml
depends_on:
  backend:
    condition: service_healthy
```

La logica è:

```text
backend avviato
        ↓
healthcheck passa
        ↓
backend = healthy
        ↓
frontend può essere avviato secondo la dipendenza
```

Questo non sostituisce tutta la resilienza che una vera applicazione dovrebbe avere, ma nel nostro laboratorio rende esplicito il rapporto fra:

```text
ordine di avvio
e
prontezza applicativa
```

---

# 37. Compose come descrizione dichiarativa dello stack

La cosa più importante non è memorizzare tutte le chiavi YAML.

È capire il cambio di modello.

Con i comandi manuali descriviamo **azioni**:

```text
crea rete
crea volume
avvia backend
avvia frontend
pubblica porta
```

Con Compose descriviamo **lo stato desiderato**:

```text
esistono backend e frontend
sono sulla stessa rete
backend usa un volume
frontend pubblica 8080
frontend dipende dal backend healthy
```

Poi:

```bash
docker compose up
```

chiede a Docker di realizzare quello stato.

È un primo esempio molto semplice di approccio dichiarativo, concetto che ritroveremo anche nell'Infrastructure as Code.

---

# 38. `docker compose ps`, `logs`, `config`: osservare prima di modificare

Quando lo stack non funziona, non dobbiamo modificare immediatamente Dockerfile o YAML.

Prima raccogliamo evidenze.

```bash
docker compose ps
```

mostra:

```text
quali container esistono
stato
porte
health
```

```bash
docker compose logs backend
```

mostra ciò che l'applicazione backend ha scritto su stdout/stderr.

```bash
docker compose config
```

mostra la configurazione Compose risultante dopo il parsing del file.

Questi strumenti rispondono a domande diverse:

```text
ps
→ cosa sta girando?

logs
→ cosa sta dicendo il processo?

config
→ che configurazione ha interpretato Compose?
```

---

# 39. `docker inspect`: vedere la configurazione effettiva

`docker inspect` lavora a livello di oggetto Docker e permette di vedere:

```text
environment
mount
rete
porte
health
stato
```

È utile quando vogliamo distinguere:

```text
quello che pensavamo di avere configurato
```

da:

```text
quello che Docker ha realmente applicato
```

Questa distinzione è centrale nel troubleshooting.

---

# 40. Recreate e rebuild non sono la stessa cosa

Durante il laboratorio dobbiamo distinguere due classi di modifica.

## Cambia il codice o il Dockerfile

Per esempio:

```text
server.py
backend.Dockerfile
frontend.Dockerfile
nginx.conf copiato nell'image
```

La image potrebbe dover essere ricostruita:

```bash
docker compose up -d --build
```

## Cambia soltanto una configurazione runtime

Per esempio:

```yaml
LOW_STOCK_THRESHOLD: "10"
```

La stessa image può essere riutilizzata, ma il container deve essere ricreato con la nuova configurazione.

Questa distinzione evita rebuild inutili.

---

# 41. Lifecycle Compose

I comandi principali sono:

```bash
docker compose up -d
docker compose ps
docker compose logs
docker compose stop
docker compose start
docker compose restart
docker compose down
```

Possiamo interpretarli così:

```text
up
→ crea ciò che manca e avvia

stop
→ ferma i container senza rimuoverli

start
→ riavvia container esistenti fermati

restart
→ riavvia

down
→ rimuove container e rete del progetto
```

I named volume non vengono necessariamente eliminati con:

```bash
docker compose down
```

Per rimuoverli esplicitamente:

```bash
docker compose down -v
```

Per questo `-v` deve essere una scelta consapevole.

---

# 42. Che cosa abbiamo imparato costruendo prima un container singolo e poi Compose

La sequenza della UD10 è intenzionale.

Prima:

```text
Dockerfile backend
→ docker build
→ image backend
→ docker run
→ container backend
→ porta
→ curl
```

Così capiamo ogni elemento separatamente.

Dopo:

```text
backend + frontend
→ Compose
→ due image
→ due container
→ rete
→ volume
→ healthcheck
→ reverse proxy
```

Se iniziassimo direttamente con:

```bash
docker compose up -d --build
```

potremmo vedere funzionare l'applicazione senza capire quali oggetti Docker sono stati creati.

La UD procede invece dal semplice al composto.

---

# 43. Collegamento con le UD successive

Il percorso completo diventa:

```text
UD10
Docker locale
→ image
→ container
→ Compose

UD11
image
→ Azure Container Registry
→ Azure Container Apps

UD14
pipeline CI
→ test
→ docker build
→ push ACR

UD15
pipeline CD
→ image versionata
→ deployment
→ smoke test
```

Quindi l'image che oggi costruiamo manualmente è lo stesso concetto che, più avanti, verrà prodotto automaticamente da un Agent di pipeline.

---

# 44. Metodo di troubleshooting Docker/Compose

Quando qualcosa non funziona useremo un ordine ragionato:

```text
1. docker compose ps
2. docker compose logs <servizio>
3. docker compose config
4. verificare health
5. verificare environment
6. verificare porte
7. verificare rete e nomi DNS
8. verificare mount/volume
9. decidere se serve recreate o rebuild
10. fare una modifica minima
11. ripetere il test
```

Il principio è:

> prima osserviamo, poi formuliamo un'ipotesi, infine modifichiamo.

Non ricostruiamo l'image "per tentativi" se il problema è soltanto una variabile d'ambiente.

---

# 45. Domande di controllo

1. Qual è la differenza fra codice sorgente, image e container?
2. Che cosa fa `docker build` e che cosa **non** fa?
3. Che ruolo hanno Dockerfile, build context e `.dockerignore` nella creazione di un'image?
4. Che cosa succede se l'image indicata da `FROM` non è disponibile localmente?
5. Distingui `RUN` e `CMD`.
6. Perché una modifica a `server.py` non modifica automaticamente un'image già costruita?
7. A che cosa serve il tag `catalog-backend:ud10`?
8. Che cosa succede, in ordine, quando eseguiamo `docker run catalog-backend:ud10`?
9. Distingui `EXPOSE 8000` e `--publish 127.0.0.1:8000:8000`.
10. Che problema risolve Docker Compose rispetto a molti comandi `docker run` manuali?
11. Distingui il ruolo di un Dockerfile dal ruolo di `compose.yaml`.
12. Che cosa crea/gestisce Compose nella nostra UD10?
13. Perché `docker compose up -d --build` può costruire sia backend sia frontend?
14. Perché il backend non viene pubblicato direttamente sull'host nello stack Compose?
15. Perché Nginx usa `http://backend:8000` e non `http://localhost:8000`?
16. Che funzione ha `catalog-net`?
17. Che funzione ha `catalog-runtime`?
18. Perché `running` e `healthy` non significano la stessa cosa?
19. Che cosa fa `depends_on: condition: service_healthy` nel nostro stack?
20. Distingui rebuild e recreate.
21. Quale ordine useresti per diagnosticare uno stack Compose che non risponde?
22. In che modo ciò che facciamo manualmente in UD10 verrà riutilizzato nelle pipeline successive?
