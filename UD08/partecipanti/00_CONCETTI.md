# UD08 — Concetti
## Dal versionamento individuale alla collaborazione DevOps

Nelle prime unità abbiamo utilizzato Git soprattutto per salvare e pubblicare il nostro lavoro. In questa UD cambia il punto di vista: il repository non è più soltanto un luogo nel quale conservare file, ma diventa **uno spazio di collaborazione** nel quale una modifica viene proposta, letta da un'altra persona, corretta e infine integrata.

Questo passaggio è centrale nel lavoro DevOps. DevOps non significa semplicemente installare Azure DevOps, Docker o una pipeline. Significa costruire un flusso nel quale sviluppo, verifica, rilascio e feedback siano collegati e ripetibili.

Durante la giornata useremo GitHub per rendere concreto questo flusso e, nella seconda parte, introdurremo l'applicazione `Catalogo prodotti`, che verrà riutilizzata nelle UD successive.

Il percorso concettuale è:

```text
modifica locale
    ↓
branch
    ↓
commit
    ↓
push
    ↓
Pull Request
    ↓
review
    ↓
eventuale correzione
    ↓
merge
```

Successivamente questo processo sarà automatizzato da una pipeline. Oggi vogliamo prima comprenderlo **senza nasconderlo dietro l'automazione**.

---

# 1. DevOps: prima di tutto un modo di lavorare

DevOps nasce dal problema storico della separazione rigida tra chi sviluppa software e chi lo mette in esercizio. Se i due gruppi lavorano con obiettivi, strumenti e tempi completamente separati, ogni rilascio diventa un passaggio rischioso.

DevOps cerca quindi di creare continuità tra:

```text
PLAN → CODE → BUILD → TEST → RELEASE → DEPLOY → OPERATE → MONITOR
 ↑                                                            |
 └──────────────────────── feedback ────────────────────────────┘
```

Gli strumenti possono cambiare. Il principio rimane: una modifica dovrebbe poter essere **piccola, osservabile, verificabile e ripetibile**.

Per questo Git, Pull Request, test e pipeline non sono attività isolate: sono parti dello stesso ciclo.

---

# 2. Continuous Integration: integrare spesso, non aspettare la fine

Continuous Integration, o CI, significa integrare frequentemente modifiche relativamente piccole nella base comune del progetto e verificarle rapidamente.

Immaginiamo due scenari.

Nel primo, un partecipante lavora per due settimane in una branch senza confrontarsi con nessuno. Nel frattempo `main` cambia. Quando prova a integrare il lavoro, i conflitti e le differenze sono numerosi.

Nel secondo, le modifiche sono più piccole e vengono integrate più spesso:

```text
branch breve
→ commit comprensibile
→ push
→ PR
→ verifica
→ merge
```

Il secondo scenario riduce il rischio perché ogni modifica è più facile da leggere, testare e correggere.

In UD08 la CI è ancora **manuale**: non abbiamo una pipeline che esegue automaticamente i test. Prepariamo però esattamente il flusso che una pipeline automatizzerà più avanti.

---

# 3. Continuous Delivery e Continuous Deployment non sono sinonimi

Con **Continuous Delivery** il software viene mantenuto in uno stato che consente il rilascio. I controlli sono automatizzati quanto possibile, ma il passaggio in produzione può ancora richiedere una decisione esplicita.

Con **Continuous Deployment**, invece, una modifica che supera tutti i controlli previsti può essere distribuita automaticamente.

Possiamo rappresentare la differenza così:

```text
Continuous Delivery
modifica → test OK → artefatto pronto → decisione → produzione
```

```text
Continuous Deployment
modifica → test OK → produzione automatica
```

Questa distinzione diventerà più concreta quando costruiremo le pipeline.

---

# 4. Git: tre aree da non confondere

Quando modifichiamo un file, Git non lo registra immediatamente nella cronologia.

Il percorso è:

```text
Working tree
    |
 git add
    v
Staging area
    |
git commit
    v
Repository locale
    |
 git push
    v
Repository remoto GitHub
```

La **working tree** contiene i file sui quali stiamo lavorando. La **staging area** contiene le modifiche che abbiamo scelto per il prossimo commit. Il **commit** registra uno snapshot nella cronologia locale. Il **push** pubblica commit già creati verso il remote.

Questo spiega perché:

```bash
git add file.md
```

non pubblica nulla su GitHub, e perché:

```bash
git commit -m "..."
```

non implica automaticamente `git push`.

---

# 5. Branch: isolare una modifica prima di integrarla

Una branch ci permette di lavorare su una modifica senza cambiare immediatamente `main`.

```text
main        A────B────────────E
                  \          /
feature              C────D
```

La feature nasce da `main`, evolve separatamente e viene integrata quando è pronta.

Per questo prima di creare una nuova branch eseguiamo normalmente:

```bash
git switch main
git pull --ff-only
```

Il primo comando ci riporta sulla branch principale. Il secondo aggiorna `main` rispetto al remote senza creare implicitamente un merge commit.

Poi creiamo la feature:

```bash
git switch -c feature/nome-modifica
```

L'obiettivo non è creare molte branch per complicare il lavoro. È mantenere separato ciò che è **stabile** da ciò che è **in corso di modifica**.

---

# 6. Commit: una modifica comprensibile alla volta

Un buon commit dovrebbe poter rispondere alla domanda:

```text
che cosa cambia e perché?
```

Un messaggio come:

```text
fix: correct product stock status
```

è più utile di:

```text
varie modifiche
```

Anche la dimensione conta. Un commit che modifica decine di file non correlati è difficile da revisionare e da annullare. Il principio utile è:

```text
una modifica logica coerente
→ un commit comprensibile
```

Prima del commit useremo:

```bash
git diff
```

per vedere le modifiche non ancora in staging, e:

```bash
git diff --cached
```

per vedere esattamente ciò che entrerà nel commit.

---

# 7. Pull Request: proporre una modifica, non soltanto copiarla in main

Una Pull Request mette a confronto due branch.

Se abbiamo:

```text
feature/catalog-ui → main
```

allora:

- `feature/catalog-ui` è la **head branch**, quella che contiene la proposta;
- `main` è la **base branch**, quella che dovrebbe ricevere la modifica.

La Pull Request raccoglie in un unico punto:

- descrizione della modifica;
- commit;
- diff;
- commenti;
- review;
- eventuali check automatici;
- decisione di merge.

Il vantaggio è che l'integrazione diventa una decisione visibile e verificabile, non un'operazione nascosta.

---

# 8. Review: leggere il cambiamento con occhi diversi

Una review utile non si limita a dire:

```text
"funziona"
```

Il reviewer dovrebbe chiedersi almeno:

- la modifica risponde al requisito?
- il diff contiene soltanto ciò che serve?
- sono stati aggiunti file estranei?
- sono presenti token, password o altri segreti?
- il codice o la documentazione sono leggibili?
- esistono test o verifiche coerenti?
- la modifica può introdurre regressioni?

GitHub permette tre esiti principali:

```text
Comment
Approve
Request changes
```

`Request changes` non significa che il lavoro è sbagliato in modo definitivo. Significa che la proposta necessita di una correzione prima di essere considerata pronta.

Quando il contributor corregge il file, esegue un nuovo commit e fa push **sulla stessa branch**. La Pull Request si aggiorna automaticamente.

---

# 9. Merge: integrare la modifica dopo la verifica

Quando la proposta è pronta, la branch può essere integrata nella base.

GitHub supporta più strategie, tra cui:

```text
merge commit
squash merge
rebase merge
```

Nel laboratorio useremo prevalentemente **Squash and merge** per le piccole esercitazioni. I diversi commit della PR vengono rappresentati nella branch base da un singolo commit finale, rendendo semplice la cronologia del laboratorio.

Dopo il merge è buona pratica aggiornare il repository locale:

```bash
git switch main
git pull --ff-only
```

La branch di lavoro può poi essere eliminata se non serve più.

---

# 10. Collaboratore temporaneo e least privilege

Per rendere reale la collaborazione, un altro partecipante riceverà temporaneamente accesso al nostro repository personale.

Il flusso sarà:

```text
owner invita collaborator
→ collaborator accetta
→ crea branch
→ push
→ PR
→ review
→ merge
→ owner rimuove collaborator
```

La rimozione finale non è un dettaglio amministrativo. Applica il principio del **least privilege**:

```text
accesso necessario
+
solo alla risorsa necessaria
+
solo per il tempo necessario
```

Se una collaborazione è terminata, mantenere l'accesso indefinitamente aumenta inutilmente la superficie di rischio.

---

# 11. Conflitti Git: quando Git non può scegliere da solo

Git riesce spesso a unire automaticamente modifiche provenienti da branch diverse. Un conflitto nasce quando le modifiche sono incompatibili e Git non può decidere quale contenuto mantenere.

Per esempio, se due branch cambiano la stessa riga:

```text
branch A → PORT=9000
branch B → PORT=7000
```

Git può inserire marker come:

```text
<<<<<<< HEAD
PORT=7000
=======
PORT=9000
>>>>>>> lab/conflict-a
```

Questi marker **non sono la soluzione**. Sono la rappresentazione del problema.

La risoluzione richiede una decisione umana:

```text
leggere entrambe le versioni
→ capire il requisito
→ scrivere il contenuto finale corretto
→ git add
→ commit
```

Non dobbiamo scegliere automaticamente "ours" o "theirs" senza comprendere quale valore sia corretto.

---

# 12. Il Catalogo prodotti: un'applicazione semplice ma completa

Nella seconda parte della UD introduciamo una piccola applicazione che useremo anche nelle giornate successive.

L'architettura iniziale è volutamente semplice:

```text
Browser / curl
      |
      v
Python backend/API
      |
      +── /health
      +── /api/products
      +── /api/products/<id>
      |
      +── config.json
      +── products.json
      +── frontend statico
```

L'applicazione funziona con la **Python standard library** e non richiede installazione di framework esterni. Questo ci permette di concentrarci sulla struttura dell'applicazione e sul flusso Git senza introdurre altre dipendenze.

---

# 13. Frontend, backend, configurazione e dati

Il frontend è il file:

```text
static/index.html
```

Il browser lo visualizza e il JavaScript richiama l'API per ottenere i prodotti.

Il backend è:

```text
server.py
```

ed è responsabile di:

- avviare il server HTTP;
- leggere la configurazione;
- leggere i dati;
- rispondere agli endpoint;
- restituire JSON.

La configurazione è separata nel file:

```text
config.json
```

mentre i prodotti sono memorizzati in:

```text
data/products.json
```

Separare questi elementi rende più semplice capire cosa stiamo modificando. Cambiare una soglia di configurazione non è la stessa cosa che cambiare il codice dell'API; cambiare un prodotto non è la stessa cosa che cambiare il frontend.

---

# 14. Endpoint e contratto API

L'applicazione espone:

```text
GET /health
GET /api/products
GET /api/products/<id>
GET /
```

`/health` indica se il servizio HTTP risponde.

`/api/products` restituisce la collezione dei prodotti.

`/api/products/P001` restituisce un prodotto specifico.

Una richiesta a un prodotto inesistente deve restituire:

```text
404 Not Found
```

Il fatto che un `404` sia un errore HTTP non significa che il sistema sia necessariamente guasto: se chiediamo una risorsa che non esiste, `404` è il comportamento corretto.

---

# 15. Dal test locale alla futura automazione

Prima di committare una modifica all'applicazione useremo una sequenza semplice:

```text
modifica
→ avvio applicazione
→ curl/browser
→ git diff
→ commit
```

Nelle UD successive parte di questa verifica verrà automatizzata.

È importante però conoscere prima il processo manuale: una pipeline non deve essere una "scatola nera" che esegue comandi che nessuno sa riprodurre localmente.

---

# 16. Quadro complessivo della UD

La giornata collega due idee:

```text
COLLABORAZIONE
branch → PR → review → merge
```

con:

```text
APPLICAZIONE
frontend → API → configurazione → test
```

Da qui in avanti potremo collegare questi due flussi:

```text
modifica applicazione
→ Git
→ Pull Request
→ pipeline
→ container
→ Azure
```

UD08 costruisce quindi la base organizzativa e applicativa delle giornate successive.

---

# 17. Domande di controllo

1. Perché DevOps non coincide con Azure DevOps?
2. Distingui Continuous Integration, Continuous Delivery e Continuous Deployment.
3. Che differenza c'è tra working tree, staging area e commit?
4. Perché conviene creare un feature branch da `main` aggiornata?
5. Che cosa rappresentano base branch e head branch in una Pull Request?
6. Perché una review non dovrebbe limitarsi a controllare che il codice "funzioni"?
7. Che cosa succede a una Pull Request quando il contributor aggiunge un nuovo commit allo stesso branch?
8. Che cosa provoca tipicamente un merge conflict?
9. Perché l'accesso del collaboratore deve essere rimosso al termine?
10. Distingui frontend, backend/API, configurazione e dati nel Catalogo prodotti.
11. Quali endpoint principali espone l'applicazione?
12. Perché è utile eseguire `git diff` prima del commit?
