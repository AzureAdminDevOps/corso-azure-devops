# UD14 — Concetti
## Continuous Integration: dalla modifica del codice a un artefatto verificato e pubblicato

In UD13 abbiamo automatizzato la validazione e il deployment dell'Infrastructure as Code. Con UD14 spostiamo l'attenzione sul software applicativo e introduciamo una pipeline di **Continuous Integration** capace di verificare il codice, costruire una container image e pubblicarla nell'Azure Container Registry già predisposto.

Il punto centrale non è semplicemente “automatizzare una build”. Una pipeline CI serve a trasformare una modifica al repository in una sequenza di controlli ripetibili. Ogni commit che attraversa la pipeline deve essere sottoposto agli stessi passaggi, nello stesso ordine e con le stesse regole. In questo modo il risultato non dipende da chi esegue manualmente i comandi o dalla configurazione particolare di una workstation.

Nel nostro caso il flusso sarà:

```text
commit
  ↓
pipeline CI
  ↓
test
  ↓
build immagine Docker
  ↓
push in Azure Container Registry
```

Questa sequenza introduce un principio importante: **prima verifichiamo, poi produciamo l'artefatto**. Se i test non passano, non ha senso costruire e pubblicare una nuova immagine. Per questo lo stage di test precede lo stage di build e un suo fallimento impedisce alla pipeline di proseguire.

Una pipeline “verde” significa quindi che tutti i controlli automatizzati che abbiamo deciso di inserire sono stati superati. Non significa che il software sia privo di bug, che sia automaticamente sicuro o che possa essere distribuito in produzione senza ulteriori verifiche. La qualità della CI dipende sempre anche dalla qualità dei test e dei controlli che abbiamo scelto di eseguire.

---

# 1. Dal sorgente all'immagine: che cosa produce la CI

Il repository GitHub contiene il sorgente. La pipeline lo preleva, esegue i test e, se tutto è corretto, costruisce una **container image**. Quell'immagine diventa l'artefatto principale della UD14 e viene pubblicata nell'Azure Container Registry creato in precedenza.

La separazione fra sorgente e artefatto è importante:

```text
GitHub
→ contiene il codice sorgente

Azure Container Registry
→ contiene le immagini costruite dalla pipeline
```

Per identificare in modo univoco ogni immagine useremo:

```text
$(Build.BuildId)
```

come tag principale. Se, per esempio, una pipeline produce:

```text
catalog-backend:145
```

il numero `145` permette di risalire direttamente alla run Azure Pipelines che ha generato quell'immagine. È una scelta molto più utile di un tag generico come `latest`, perché rende più semplice capire quale versione è stata costruita, testata e successivamente distribuita.

In UD15 useremo proprio questa immagine come input del deployment. Per questo l'ACR e le immagini prodotte non verranno eliminate al termine della UD14: la CI prepara l'artefatto, mentre la UD successiva lo utilizzerà per la distribuzione.

---

# 2. Autenticazione: perché servono due service connection

Nelle UD precedenti abbiamo già utilizzato una Azure Resource Manager service connection per permettere alla pipeline di operare sulle risorse Azure. In UD14 compare un secondo tipo di connessione perché cambia il tipo di operazione da eseguire.

La service connection:

```text
sc-azure-ud13-15
```

serve per le operazioni di gestione delle risorse Azure.

La nuova:

```text
sc-acr-ud14
```

è invece una **Docker Registry service connection** e serve al task `Docker@2` per autenticarsi verso Azure Container Registry durante build e push.

Le due connessioni non sono quindi ridondanti: rappresentano due scopi differenti. Questa separazione rende anche più semplice il troubleshooting. Se fallisce un deployment Azure, il problema va cercato nella connessione ARM o nei permessi associati. Se invece la build riesce ma il push verso ACR restituisce un errore di autorizzazione, l'attenzione deve spostarsi sulla Docker Registry service connection e sui ruoli assegnati al registry.

Nel nostro laboratorio la connessione verso ACR utilizza **Workload Identity Federation**. Non salviamo quindi username e password del registry nel file YAML e l'admin user ACR rimane disabilitato. L'ACR proveniente da UD13 deve inoltre mantenere:

```text
LegacyRegistryPermissions
```

per restare coerente con il modello di autorizzazione utilizzato nel percorso.

Un punto da tenere distinto è il ruolo dell'Agent rispetto a quello della service connection: **l'Agent esegue i task**, mentre **la service connection fornisce l'identità con cui quei task accedono al servizio esterno**.

---

# 3. Dal merge su `main` alla pipeline

La pipeline CI viene collegata al branch `main` tramite:

```yaml
trigger:
- main
```

Questo significa che un nuovo commit su `main` può avviare automaticamente una nuova run.

Il flusso visto nelle UD precedenti acquista quindi una conseguenza operativa ulteriore:

```text
branch di lavoro
→ modifica
→ Pull Request
→ merge su main
→ pipeline CI
```

Git non serve soltanto a conservare versioni del codice: il repository diventa anche il punto di ingresso del processo di automazione. Una modifica integrata in `main` non viene considerata soltanto “salvata”, ma viene sottoposta ai controlli definiti dalla CI.

---

# 4. La novità della UD14: eseguire la CI su un Agent Microsoft-hosted

In UD13 abbiamo eseguito la prima pipeline sul self-hosted Agent `pool-ud09-wsl`. Quell'esperienza ci ha permesso di vedere in modo concreto che una pipeline non “esegue da sola” i comandi: i Job vengono sempre affidati a un Agent.

In UD14, se la disponibilità Microsoft-hosted è stata verificata nelle fasi precedenti, utilizziamo invece:

```yaml
pool:
  vmImage: ubuntu-latest
```

Il Job viene quindi assegnato a una macchina virtuale Linux predisposta da Microsoft.

Non è necessario ripetere qui tutta la distinzione hosted/self-hosted già affrontata nelle UD precedenti. È sufficiente ricordare il punto che ci interessa per capire il laboratorio: **con Microsoft-hosted è Microsoft a gestire il compute usato dall'Agent; con self-hosted è l'organizzazione a gestirlo**. Il fatto che nel laboratorio il self-hosted sia rappresentato da WSL2 sul PC del partecipante è una scelta didattica, non il modello tipico di una software house. In un ambiente reale, un pool self-hosted potrebbe essere formato da più build agent aziendali dedicati.

Questa differenza ha una conseguenza immediata: l'ambiente Microsoft-hosted è **temporaneo**. Ogni Job riceve un ambiente nuovo e non può fare affidamento sul filesystem lasciato da un Job precedente.

La nostra CI contiene, in modo semplificato, due Job:

```text
PythonTests
DockerBuild
```

Con Microsoft-hosted possono essere eseguiti su due VM temporanee differenti. Per questo entrambi effettuano:

```yaml
- checkout: self
```

Non stanno duplicando inutilmente un'operazione: ciascun Job deve ricostruire il proprio contesto di lavoro a partire dal repository.

Nel nostro caso non è necessario trasferire file prodotti dal Job di test al Job di build, perché entrambi lavorano sullo stesso commit. Se invece il primo Job producesse un file necessario al successivo, dovremmo pubblicarlo e trasferirlo esplicitamente come artifact o tramite un altro meccanismo della pipeline.

---

# 5. Che cosa deve essere disponibile sull'Agent

Sia nel modello hosted sia nel modello self-hosted, i task della pipeline vengono eseguiti da un Agent reale. Nel nostro caso servono almeno:

```text
python3
docker
git
```

Per questo la pipeline mostrerà alcune informazioni sull'Agent ed eseguirà controlli come:

```bash
python3 --version
docker --version
```

Questi passaggi non sono decorativi. Ci aiutano a distinguere rapidamente un problema applicativo da un problema dell'ambiente di esecuzione.

Se, per esempio, il Job non trova `docker`, non ha senso indagare immediatamente la service connection ACR: il task non è ancora arrivato al punto in cui dovrebbe autenticarsi al registry.

Lo stesso principio vale per il self-hosted Agent. Se la disponibilità Microsoft-hosted non fosse utilizzabile per motivi di grant, billing o policy esterne, la UD14 prevede un file YAML alternativo che usa il pool self-hosted già predisposto.

I due file sono:

```text
azure-pipelines-ci.yml
→ percorso Microsoft-hosted

azure-pipelines-ci-selfhosted.yml
→ fallback self-hosted
```

L'obiettivo della CI rimane identico; cambia soltanto il luogo in cui vengono eseguiti i Job.

Nel fallback self-hosted utilizziamo inoltre:

```yaml
workspace:
  clean: all
```

per ridurre il rischio che file rimasti da esecuzioni precedenti influenzino la nuova run.

---

# 6. `Docker@2`: costruire e pubblicare senza gestire manualmente le credenziali

Azure Pipelines mette a disposizione il task:

```text
Docker@2
```

che, con:

```yaml
command: buildAndPush
```

esegue in un'unica sequenza la build dell'immagine, l'applicazione del tag e il push verso ACR.

L'autenticazione non viene scritta manualmente nel file YAML con un `docker login` contenente username e password. Il task utilizza la Docker Registry service connection `sc-acr-ud14`.

Il flusso diventa quindi:

```text
Agent
→ esegue Docker@2
→ costruisce l'immagine
→ usa sc-acr-ud14 per autenticarsi
→ pubblica l'immagine in ACR
```

La distinzione fra esecuzione e identità è importante anche nel troubleshooting: Docker deve essere disponibile sull'Agent, mentre l'accesso al registry dipende dalla service connection e dai relativi permessi.

---

# 7. Leggere una pipeline che fallisce

Quando una pipeline fallisce, il log non deve essere letto come un'unica sequenza indistinta. È più utile individuare progressivamente:

```text
Stage
→ Job
→ Step
→ comando
→ messaggio di errore
```

Questo permette di restringere subito il campo di ricerca.

Se fallisce un test Python, non ha senso iniziare da ACR. Se fallisce la build Docker, bisogna analizzare Dockerfile, contesto di build e output del task. Se invece la build termina correttamente ma il push restituisce `401` o `403`, allora diventano rilevanti service connection, autorizzazione e ruoli sul registry.

Nel laboratorio autonomo introdurremo volutamente una modifica che rende temporaneamente incoerenti codice e test. La pipeline dovrà fermarsi. Correggeremo poi il problema e la eseguiremo nuovamente.

Questo esperimento serve a mostrare un limite fondamentale della CI: la pipeline non “sa” in senso assoluto se il software è corretto. Esegue i controlli che abbiamo definito. Se i test sono incompleti o sbagliati, anche una pipeline verde può dare un'indicazione insufficiente.

---

# 8. Continuità verso UD15

Alla fine della UD14 avremo quindi:

- codice sorgente su GitHub;
- test eseguiti automaticamente;
- container image costruita dalla pipeline;
- tag basato su `Build.BuildId`;
- immagine pubblicata in Azure Container Registry;
- log della pipeline utilizzabili per verificare e diagnosticare il processo.

Non effettuiamo cleanup dell'ACR o delle immagini perché l'output della CI è l'input della UD15.

Il percorso complessivo è:

```text
UD14
→ verifica e costruisce
→ pubblica l'immagine

UD15
→ prende quell'immagine
→ la distribuisce
```

La CI termina quindi nel punto esatto in cui inizierà la Continuous Delivery.

---

# 9. Domande di controllo

1. Qual è lo scopo principale della Continuous Integration?
2. Perché eseguiamo i test prima della build Docker?
3. Che cosa significa realmente una pipeline verde?
4. Perché `Build.BuildId` è più utile di `latest` come tag dell'immagine?
5. Qual è la differenza tra `sc-azure-ud13-15` e `sc-acr-ud14`?
6. Perché l'admin user dell'ACR rimane disabilitato?
7. Qual è l'effetto del trigger sul branch `main`?
8. Perché due Job Microsoft-hosted distinti effettuano entrambi il checkout del repository?
9. Che cosa significa che un Job Microsoft-hosted riceve un ambiente temporaneo?
10. Qual è la differenza fra responsabilità dell'Agent e responsabilità della service connection?
11. Perché verifichiamo `python3 --version` e `docker --version` nei Job?
12. Quando utilizziamo il file YAML self-hosted di fallback?
13. A cosa serve `workspace.clean: all` nel fallback self-hosted?
14. Che cosa fa `Docker@2` con `buildAndPush`?
15. In quale ordine conviene leggere i log quando una pipeline fallisce?
16. Perché un errore nei test non deve portarci immediatamente a controllare ACR?
17. Che cosa dimostra il test failure intenzionale del laboratorio autonomo?
18. Perché non eliminiamo ACR e immagini al termine della UD14?
19. In che modo la UD14 prepara direttamente il lavoro della UD15?
