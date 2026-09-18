# UD10 — Laboratorio guidato
## Containerizzare il Catalogo prodotti e comprenderne il funzionamento

In UD08 il Catalogo prodotti veniva avviato direttamente con `python3 server.py`. Ora vogliamo ottenere lo stesso risultato facendo partire l'applicazione **dentro un container**, e successivamente separare frontend e backend in due servizi Docker Compose.

Non partiremo da uno script di automazione. Eseguiremo i comandi uno alla volta, osservando ogni risultato.

---

# 0. Preparare directory e consegne

Aprire **Ubuntu/WSL2**.

La struttura attesa è:

```text
~/workspace/
├── corso-azure-devops/
│   └── UD10/partecipanti/
└── azure-devops-lab/
    ├── app/
    │   └── catalogo-prodotti/
    └── consegne/UD10/
```

Impostare:

```bash
export COURSE_UD10="$HOME/workspace/corso-azure-devops/UD10/partecipanti"
export LAB_REPO="$HOME/workspace/azure-devops-lab"
export LAB_SUBMISSION="$LAB_REPO/consegne/UD10"
```

Verificare:

```bash
test -d "$COURSE_UD10" && echo "Materiali UD10 trovati"
test -d "$LAB_REPO/.git" && echo "Repository personale trovato"
```

Creare la directory delle consegne:

```bash
mkdir -p "$LAB_SUBMISSION"
```

Copiare i quattro modelli:

```bash
cp -n "$COURSE_UD10/modelli/00_DOMANDE_CONCETTI.md" "$LAB_SUBMISSION/00_DOMANDE_CONCETTI.md"
cp -n "$COURSE_UD10/modelli/01_LAB_GUIDATO.md"      "$LAB_SUBMISSION/01_LAB_GUIDATO.md"
cp -n "$COURSE_UD10/modelli/02_LAB_AUTONOMO.md"    "$LAB_SUBMISSION/02_LAB_AUTONOMO.md"
cp -n "$COURSE_UD10/modelli/03_VERIFICA.md"        "$LAB_SUBMISSION/03_VERIFICA.md"
```

Verificare:

```bash
find "$LAB_SUBMISSION" -maxdepth 1 -type f -printf '%f\n' | sort
```

---

# 1. Verificare Docker prima di iniziare il laboratorio

Eseguire manualmente:

```bash
docker version
```

Poi:

```bash
docker compose version
```

Infine:

```bash
docker info
```

Questi tre comandi rispondono a domande diverse:

```text
docker version
→ CLI e motore comunicano?

docker compose version
→ plugin Compose disponibile?

docker info
→ daemon raggiungibile e configurazione generale?
```

Se `docker` esiste ma `docker info` restituisce un errore di connessione, aprire **Docker Desktop su Windows** e attendere che il motore sia avviato.

Se continua a non funzionare, verificare in Docker Desktop:

```text
Settings
→ General
→ WSL 2 based engine
```

poi:

```text
Settings
→ Resources
→ WSL Integration
```

assicurandosi che Ubuntu sia integrata.

Da Windows PowerShell si può verificare la versione WSL con:

```powershell
wsl.exe -l -v
```

Ubuntu deve essere in versione `2`.

Non installare un secondo Docker Engine dentro Ubuntu per aggirare un problema di Docker Desktop: prima va corretta l'integrazione.

## Collegamento con l'Agent configurato in UD09

Oggi **non è necessario avviare una pipeline** e non è necessario tenere `run.sh` aperto durante il laboratorio Docker.

Il controllo che stiamo svolgendo ha però una conseguenza per le UD successive: quando useremo il pool self-hosted, sarà l'Agent ad eseguire nello stesso WSL2 comandi come `docker build`. Se `docker info` non funziona dalla shell WSL2, non funzionerà neppure un futuro Job self-hosted che tenti di usare Docker.

Per il Microsoft-hosted Agent non prepariamo invece Docker sulla nostra macchina: il Job userà l'ambiente Microsoft selezionato dalla pipeline e ne verificherà i tool disponibili.

Annotare nella consegna:

```text
Docker da WSL2: OK / KO
Self-hosted future Docker readiness: OK / KO
```

---

# 2. Portare nel repository gli asset Docker della UD10

I materiali UD10 contengono una nuova versione del Catalogo prodotti già separata in frontend e backend.

Dal repository personale:

```bash
cd "$LAB_REPO"
mkdir -p app
```

Sostituiamo la cartella dell'applicazione con quella della UD10:

```bash
rm -rf app/catalogo-prodotti
cp -R "$COURSE_UD10/app/catalogo-prodotti" app/
```

Questa operazione è esplicita: stiamo passando dalla versione locale monolitica della UD08 alla versione predisposta per Docker.

Verifichiamo:

```bash
find app/catalogo-prodotti -maxdepth 3 -type f | sort
```

Dovremmo riconoscere:

```text
backend/server.py
frontend/index.html
docker/backend.Dockerfile
docker/frontend.Dockerfile
docker/nginx.conf
compose.yaml
.dockerignore
```

---

# 3. Leggere il Dockerfile del backend prima di eseguirlo

Spostarsi:

```bash
cd "$LAB_REPO/app/catalogo-prodotti"
```

Aprire il Dockerfile:

```bash
cat docker/backend.Dockerfile
```

Individuare:

```text
FROM
WORKDIR
COPY
RUN
USER
ENV
EXPOSE
CMD
```

Prima della build, provare a descrivere verbalmente cosa farà il file.

Il punto non è eseguire subito `docker build`: vogliamo prima capire da quale base partiamo, quale file viene copiato e quale comando verrà eseguito nel container.

---

# 4. Costruire l'image backend

Ora eseguiamo:

```bash
docker build \
  --tag catalog-backend:ud10 \
  --file docker/backend.Dockerfile \
  .
```

Il punto finale è il build context.

Al termine verificare:

```bash
docker image ls catalog-backend:ud10
```

Dobbiamo vedere l'image appena costruita.

---

# 5. Osservare la history dell'image

Eseguire:

```bash
docker history catalog-backend:ud10
```

Non tutte le righe saranno identiche alle istruzioni del Dockerfile perché Docker le rappresenta in forma interna, ma dovremmo riconoscere il collegamento con:

```text
COPY
RUN
ENV
CMD
```

Annotare nella consegna quali passaggi del Dockerfile si riescono a riconoscere.

---

# 6. Avviare un singolo container backend

Prima di introdurre Compose vogliamo assicurarci che il backend funzioni da solo.

Eseguire:

```bash
docker run \
  --detach \
  --name catalog-backend-ud10 \
  --publish 127.0.0.1:8000:8000 \
  --env LOW_STOCK_THRESHOLD=5 \
  catalog-backend:ud10
```

Leggiamo il mapping:

```text
127.0.0.1:8000
→ porta 8000 del container
```

Il container viene eseguito in background grazie a `--detach`.

---

# 7. Controllare stato, log e API del container

Stato:

```bash
docker ps --filter name=catalog-backend-ud10
```

Log:

```bash
docker logs catalog-backend-ud10
```

Dovremmo vedere un messaggio che indica che il backend è in ascolto.

Test:

```bash
curl -i http://127.0.0.1:8000/health
```

Poi:

```bash
curl -s http://127.0.0.1:8000/api/products | python3 -m json.tool
```

Atteso:

```text
/health → 200
count   → 4
```

A questo punto sappiamo che image, container, porta e applicazione funzionano insieme.

---

# 8. Usare `inspect` per vedere la configurazione reale

Chiediamo a Docker come ha configurato le porte:

```bash
docker inspect catalog-backend-ud10 \
  --format 'Ports={{json .NetworkSettings.Ports}}'
```

Poi osserviamo le environment variable interessanti:

```bash
docker inspect catalog-backend-ud10 \
  --format '{{range .Config.Env}}{{println .}}{{end}}' \
  | grep -E 'APP_PORT|LOW_STOCK|RUNTIME_DIR'
```

Questo passaggio è importante perché `docker inspect` mostra **la configurazione effettiva del container**, non quella che pensiamo di aver impostato.

---

# 9. Fermare e rimuovere il container singolo

Ora che il test è concluso:

```bash
docker stop catalog-backend-ud10
```

poi:

```bash
docker rm catalog-backend-ud10
```

L'image rimane disponibile. Abbiamo rimosso soltanto l'istanza runtime.

Verificare:

```bash
docker image ls catalog-backend:ud10
```

---

# 10. Leggere `compose.yaml` prima di avviare due servizi

Aprire:

```bash
cat compose.yaml
```

Riconoscere due servizi:

```text
backend
frontend
```

Il backend:

- viene costruito dal Dockerfile Python;
- usa environment variable;
- usa un named volume;
- espone internamente la porta 8000;
- possiede un healthcheck.

Il frontend:

- viene costruito su Nginx;
- pubblica `127.0.0.1:8080:80`;
- dipende dal backend healthy;
- condivide la rete Docker con il backend.

Prima di avviare, validiamo il file:

```bash
docker compose config
```

Se il comando fallisce, correggere il YAML prima di procedere.

---

# 11. Costruire e avviare lo stack Compose

Build:

```bash
docker compose build
```

Avvio:

```bash
docker compose up -d
```

Controllare:

```bash
docker compose ps
```

Il backend può inizialmente comparire come:

```text
starting
```

Attendere alcuni secondi e ripetere.

L'obiettivo è vedere:

```text
backend  running / healthy
frontend running
```

Se il backend diventa `unhealthy`, non rilanciare continuamente `up`: leggere prima:

```bash
docker compose logs backend
```

---

# 12. Verificare il frontend e l'API attraverso Nginx

Aprire nel browser:

```text
http://127.0.0.1:8080/
```

Il frontend dovrebbe mostrare i prodotti.

Dal terminale:

```bash
curl -i http://127.0.0.1:8080/health
```

```bash
curl -s http://127.0.0.1:8080/api/products | python3 -m json.tool
```

```bash
curl -i http://127.0.0.1:8080/api/products/P001
```

```bash
curl -i http://127.0.0.1:8080/api/products/XXX
```

Attesi:

```text
health   → 200
products → 200
P001     → 200
XXX      → 404
```

Il browser non parla direttamente con il container backend. Le richieste `/api/...` passano dal frontend Nginx, che le inoltra al backend sulla rete Docker.

---

# 13. DNS interno di Docker

Dalla shell host possiamo chiedere al container frontend di risolvere il nome `backend`:

```bash
docker compose exec frontend getent hosts backend
```

Dovremmo ottenere un indirizzo IP interno associato al nome.

Ora testiamo direttamente dal frontend:

```bash
docker compose exec frontend \
  sh -c 'wget -qO- http://backend:8000/health'
```

Deve funzionare.

Proviamo invece:

```bash
docker compose exec frontend \
  sh -c 'wget -qO- http://localhost:8000/health'
```

Questo deve fallire perché `localhost`, dentro il frontend, indica il frontend stesso.

Annotare nella consegna questa differenza: è uno dei concetti più importanti della giornata.

---

# 14. Cambiare una configurazione runtime senza ricostruire l'image

Nel `compose.yaml` il backend contiene:

```yaml
LOW_STOCK_THRESHOLD: "5"
```

Aprire il file in VS Code e cambiare temporaneamente il valore in:

```yaml
LOW_STOCK_THRESHOLD: "10"
```

Applicare:

```bash
docker compose up -d
```

Non abbiamo cambiato il Dockerfile né il codice. Compose deve ricreare il container con la nuova configurazione runtime.

Verificare:

```bash
curl -s http://127.0.0.1:8080/api/products | python3 -m json.tool
```

Con soglia 10 anche un prodotto con stock 8 risulta `LOW`.

Ripristinare poi:

```yaml
LOW_STOCK_THRESHOLD: "5"
```

ed eseguire nuovamente:

```bash
docker compose up -d
```

---

# 15. Dimostrare la persistenza con il named volume

L'endpoint:

```text
/api/counter
```

incrementa un valore memorizzato nel volume `catalog-runtime`.

Chiamarlo alcune volte:

```bash
curl -s http://127.0.0.1:8080/api/counter
curl -s http://127.0.0.1:8080/api/counter
curl -s http://127.0.0.1:8080/api/counter
```

Annotare il valore più alto.

Ora rimuoviamo container e rete senza cancellare il volume:

```bash
docker compose down
```

Riavviamo:

```bash
docker compose up -d
```

Aspettiamo che il backend sia healthy e richiamiamo:

```bash
curl -s http://127.0.0.1:8080/api/counter
```

Il contatore deve continuare dal valore precedente, non ripartire da zero.

Questa è la dimostrazione concreta che il dato non vive soltanto nel filesystem effimero del container.

---

# 16. Leggere log e provare un restart controllato

Log backend:

```bash
docker compose logs --tail 30 backend
```

Log frontend:

```bash
docker compose logs --tail 30 frontend
```

Riavviare soltanto il backend:

```bash
docker compose restart backend
```

Poi verificare:

```bash
docker compose ps
curl -i http://127.0.0.1:8080/health
```

Questo ci mostra che possiamo operare sul singolo servizio senza ricreare l'intero stack.

---

# 17. Registrare la baseline Docker nel repository

Tornare alla root:

```bash
cd "$LAB_REPO"
```

Controllare:

```bash
git status
git diff
```

Aggiungere:

```bash
git add app/catalogo-prodotti
git diff --cached
```

Prima del commit verificare che non siano presenti:

- file runtime;
- `.env` contenenti segreti;
- token;
- log inutili.

Commit:

```bash
git commit -m "feat: containerize product catalog with Docker Compose"
```

Sincronizzare rispettando eventuali branch protection.

---

# 18. Non eseguire ancora il cleanup completo

Il LAB autonomo utilizzerà questo stack per introdurre un errore controllato sulla variabile `LOW_STOCK_THRESHOLD`.

Lasciare quindi il Compose funzionante e passare al file:

```text
03_LAB_AUTONOMO.md
```

Il cleanup completo verrà eseguito soltanto dopo il LAB autonomo e la verifica individuale.
