# UD08 — Laboratorio guidato
## Dalla collaborazione GitHub al Catalogo prodotti locale

In questo laboratorio faremo due cose strettamente collegate. Prima useremo GitHub come vero strumento di collaborazione: un altro partecipante entrerà temporaneamente nel nostro repository, proporrà una modifica attraverso una Pull Request e riceverà una review. Successivamente porteremo nel repository l'applicazione `Catalogo prodotti` e la eseguiremo localmente.

Non utilizzeremo ancora pipeline o Docker. Prima vogliamo che il flusso manuale sia perfettamente comprensibile.

---

# 0. Preparare le directory e le consegne

Aprire **Ubuntu/WSL2**. I comandi Git, GitHub CLI, Bash e Python della giornata vanno eseguiti qui.

La struttura che useremo è:

```text
~/workspace/
├── corso-azure-devops/
│   └── UD08/
│       └── partecipanti/
└── azure-devops-lab/
    ├── app/
    ├── docs/
    └── consegne/
        └── UD08/
```

Impostiamo i percorsi:

```bash
export COURSE_UD08="$HOME/workspace/corso-azure-devops/UD08/partecipanti"
export LAB_REPO="$HOME/workspace/azure-devops-lab"
export LAB_SUBMISSION="$LAB_REPO/consegne/UD08"
```

Se il repository personale è in un'altra posizione, correggere soltanto `LAB_REPO`.

Verificare:

```bash
test -d "$COURSE_UD08" && echo "Materiali UD08 trovati"
test -d "$LAB_REPO/.git" && echo "Repository personale trovato"
```

Creare la directory di consegna:

```bash
mkdir -p "$LAB_SUBMISSION"
```

Copiare i modelli senza sovrascrivere eventuale lavoro già svolto:

```bash
cp -n "$COURSE_UD08/modelli/00_DOMANDE_CONCETTI.md" "$LAB_SUBMISSION/00_DOMANDE_CONCETTI.md"
cp -n "$COURSE_UD08/modelli/01_LAB_GUIDATO.md"      "$LAB_SUBMISSION/01_LAB_GUIDATO.md"
cp -n "$COURSE_UD08/modelli/02_LAB_AUTONOMO.md"    "$LAB_SUBMISSION/02_LAB_AUTONOMO.md"
cp -n "$COURSE_UD08/modelli/03_VERIFICA.md"        "$LAB_SUBMISSION/03_VERIFICA.md"
```

Controllare:

```bash
find "$LAB_SUBMISSION" -maxdepth 1 -type f -printf '%f\n' | sort
```

Devono comparire i quattro file previsti.

---

# 1. Verificare lo stato del repository prima di collaborare

Spostarsi nel repository personale:

```bash
cd "$LAB_REPO"
```

Controllare Git:

```bash
git status
git remote -v
```

Controllare GitHub CLI:

```bash
gh auth status
```

Infine chiediamo a GitHub qual è il repository corrente:

```bash
gh repo view --json nameWithOwner,url
```

Prima di creare branch nuove, riportiamo `main` allo stato corrente del remote:

```bash
git switch main
git pull --ff-only
git status
```

Il risultato ideale è:

```text
working tree clean
```

Se `git status` mostra file modificati appartenenti a una UD precedente, salvarli correttamente prima di continuare. Non usare `git reset --hard` come scorciatoia.

---

# 2. Organizzare una collaborazione reale A ↔ B

Per questa parte servono due partecipanti. Indichiamo:

```text
A = proprietario del repository A
B = proprietario del repository B
```

La collaborazione verrà eseguita in entrambe le direzioni:

```text
prima: B contribuisce nel repository di A
poi:   A contribuisce nel repository di B
```

Questo è importante perché ciascuno deve vivere entrambi i ruoli:

```text
contributor
+
repository owner / reviewer
```

Scambiare soltanto gli **username GitHub**. Non condividere password, PAT o chiavi SSH.

---

# 3. A concede temporaneamente accesso a B

A apre su GitHub il proprio repository e segue:

```text
Settings
→ Collaborators
→ Add people
```

Cerca lo username di B e invia l'invito.

B apre la notifica GitHub e accetta.

Questo passaggio concede a B la possibilità di lavorare direttamente su branch del repository personale di A. È un accesso intenzionalmente temporaneo: alla fine verrà rimosso.

---

# 4. B clona il repository di A in una directory separata

B non deve confondere il repository personale con quello sul quale sta collaborando. Creiamo quindi una directory dedicata:

```bash
mkdir -p "$HOME/workspace/ud08-collab"
cd "$HOME/workspace/ud08-collab"
```

Dal repository GitHub di A, B copia l'URL HTTPS, per esempio:

```text
https://github.com/utenteA/nome-repo.git
```

Poi esegue:

```bash
git clone https://github.com/<A>/<repo>.git repo-a
cd repo-a
```

Sostituire `<A>` e `<repo>` con i valori reali.

Verificare:

```bash
git remote -v
git status
```

Il remote `origin` deve puntare al repository di A.

---

# 5. B crea una branch dedicata alla modifica

Prima aggiorniamo `main`:

```bash
git switch main
git pull --ff-only
```

Recuperiamo il nostro username GitHub:

```bash
gh api user --jq .login
```

Usiamo quello username nel nome della branch. Per esempio, se il comando restituisce `mariorossi`:

```bash
git switch -c feature/ud08-collab-mariorossi
```

La branch deve avere un nome riconoscibile e non deve modificare direttamente `main`.

---

# 6. B crea una piccola modifica leggibile

Creiamo la directory:

```bash
mkdir -p docs
```

Aprire il repository in VS Code:

```bash
code .
```

Creare:

```text
docs/ud08-collaboration.md
```

con questo contenuto, sostituendo lo username:

```markdown
# UD08 — Collaborazione

## Contributor

mariorossi

## Modifica

Contributo creato su feature branch e sottoposto a Pull Request.

## Verifica

- branch separato
- commit
- push
- Pull Request
- review
```

Usiamo l'editor invece di generare il file con un lungo comando Bash: il contenuto deve essere visibile e comprensibile.

---

# 7. Prima del commit, leggere esattamente ciò che stiamo registrando

Da WSL:

```bash
git diff
```

Dovremmo vedere solo il nuovo file.

Aggiungiamolo alla staging area:

```bash
git add docs/ud08-collaboration.md
```

Ora:

```bash
git diff --cached
```

Questa è la vista più importante prima del commit: mostra esattamente ciò che entrerà nella cronologia.

Se il diff contiene file non previsti, fermarsi e capire perché.

---

# 8. Commit e push della branch

Creiamo il commit:

```bash
git commit -m "docs: add UD08 collaboration evidence"
```

Pubblicare la branch:

```bash
git push -u origin feature/ud08-collab-<USERNAME>
```

Sostituire `<USERNAME>` con lo stesso valore usato nella branch.

L'opzione `-u` collega la branch locale alla branch remota; dai push successivi basterà `git push`.

---

# 9. B apre la Pull Request

Possiamo usare GitHub CLI:

```bash
gh pr create \
  --base main \
  --head feature/ud08-collab-<USERNAME> \
  --title "UD08: collaboration evidence" \
  --body "Aggiunge evidenza della collaborazione GitHub svolta in UD08."
```

La PR propone:

```text
feature/ud08-collab-<USERNAME>
→ main
```

Annotare nella consegna:

- numero PR;
- URL;
- head branch;
- base branch.

---

# 10. A legge il diff prima di esprimere una review

A apre la PR e seleziona:

```text
Files changed
```

Non deve limitarsi a controllare che il file esista. Deve verificare:

- il contributor è corretto?
- il file è quello richiesto?
- sono presenti file estranei?
- ci sono token o altri dati che non dovrebbero essere pubblicati?
- il contenuto risponde al requisito?

A questo punto A usa:

```text
Review changes
→ Request changes
```

con la richiesta:

```text
Aggiungi una sezione "## Esito" con la frase:
Review completata e modifica corretta.
```

La richiesta è deliberatamente semplice: ci interessa vedere il ciclo di feedback, non inventare un problema complesso.

---

# 11. B corregge la stessa Pull Request

B torna in VS Code e aggiunge al file:

```markdown
## Esito

Review completata e modifica corretta.
```

Poi verifica:

```bash
git diff
```

Registra la correzione:

```bash
git add docs/ud08-collaboration.md
git commit -m "docs: address UD08 review"
git push
```

Non viene creata una nuova Pull Request. La PR esistente punta alla branch e quindi mostra automaticamente anche il nuovo commit.

---

# 12. A completa la review e integra la modifica

A rilegge `Files changed`.

Se tutto è corretto usa:

```text
Review changes
→ Approve
```

Se l'interfaccia/account non consente `Approve`, lascia un `Comment` finale che dichiari esplicitamente che la modifica è stata verificata.

Poi esegue:

```text
Squash and merge
```

Per questa esercitazione lo squash mantiene una cronologia finale semplice.

---

# 13. A sincronizza il repository locale e rimuove l'accesso temporaneo

Nel repository personale di A:

```bash
cd "$LAB_REPO"
git switch main
git pull --ff-only
```

Verificare che il file ricevuto dal collaboratore sia presente:

```bash
cat docs/ud08-collaboration.md
```

Ora A torna su GitHub:

```text
Settings
→ Collaborators
→ utente B
→ Remove
```

La collaborazione è terminata e il permesso non è più necessario.

Ripetere poi lo stesso processo a ruoli invertiti, in modo che A contribuisca nel repository di B.

---

# 14. Provocare un conflitto semplice e risolverlo comprendendo la causa

Torniamo al repository personale:

```bash
cd "$LAB_REPO"
git switch main
git pull --ff-only
```

Creiamo un piccolo file temporaneo:

```bash
echo "PORT=8000" > ud08-conflict.txt
git add ud08-conflict.txt
git commit -m "chore: add temporary conflict exercise"
```

Creiamo la prima branch:

```bash
git switch -c lab/conflict-a
echo "PORT=9000" > ud08-conflict.txt
git add ud08-conflict.txt
git commit -m "lab: change port to 9000"
```

Creiamo la seconda branch partendo da `main`:

```bash
git switch main
git switch -c lab/conflict-b
echo "PORT=7000" > ud08-conflict.txt
git add ud08-conflict.txt
git commit -m "lab: change port to 7000"
```

Ora proviamo a integrare A dentro B:

```bash
git merge lab/conflict-a
```

Git non può scegliere tra `7000` e `9000`, quindi segnala un conflitto.

Leggiamo:

```bash
git status
cat ud08-conflict.txt
```

Il requisito dell'esercizio stabilisce che il valore finale debba essere:

```text
PORT=8000
```

Aprire il file, eliminare i marker di conflitto e lasciare una sola riga con quel valore. Poi:

```bash
git add ud08-conflict.txt
git commit -m "lab: resolve port conflict"
```

Il punto dell'esercizio non è il numero della porta: è capire che **risolvere un conflitto significa decidere il contenuto corretto**, non scegliere automaticamente una delle due versioni.

---

# 15. Pulire l'esercizio sul conflitto

Torniamo a `main`:

```bash
git switch main
```

Il file temporaneo era stato creato su `main`, quindi lo eliminiamo:

```bash
git rm ud08-conflict.txt
git commit -m "chore: remove temporary conflict exercise"
```

Eliminare le branch locali dell'esercizio:

```bash
git branch -D lab/conflict-a
git branch -D lab/conflict-b
```

Se il repository consente push diretto su `main`, sincronizzare. Se `main` è protetta, usare il normale flusso branch + PR anziché disabilitare la protezione.

---

# 16. Portare il Catalogo prodotti nel repository personale

I materiali UD08 contengono già l'applicazione completa.

Dal repository personale:

```bash
cd "$LAB_REPO"
mkdir -p app
```

Copiamo:

```bash
rm -rf app/catalogo-prodotti
cp -R "$COURSE_UD08/app/catalogo-prodotti" app/
```

Verifichiamo la struttura:

```bash
find app/catalogo-prodotti -maxdepth 3 -type f | sort
```

Dovrebbero comparire almeno:

```text
server.py
config.json
data/products.json
static/index.html
```

Prima di avviare l'applicazione, aprire questi file in VS Code e riconoscere:

```text
frontend
backend/API
configurazione
dati
```

---

# 17. Avviare l'applicazione locale

Spostarsi nella directory:

```bash
cd "$LAB_REPO/app/catalogo-prodotti"
```

Avviare:

```bash
python3 server.py
```

Il terminale resta occupato dal server e dovrebbe mostrare:

```text
Catalogo prodotti in ascolto su http://127.0.0.1:8000
```

Lasciarlo aperto e usare **un secondo terminale WSL2** per i test.

---

# 18. Verificare il servizio con `curl`

Nel secondo terminale:

```bash
curl -i http://127.0.0.1:8000/health
```

Dobbiamo vedere HTTP `200` e uno stato `ok`.

Poi:

```bash
curl -s http://127.0.0.1:8000/api/products | python3 -m json.tool
```

Verificare:

```text
count = 4
```

Provare un prodotto esistente:

```bash
curl -i http://127.0.0.1:8000/api/products/P001
```

Atteso:

```text
200
```

Provare un prodotto inesistente:

```bash
curl -i http://127.0.0.1:8000/api/products/XXX
```

Atteso:

```text
404
```

Qui `404` è corretto: abbiamo chiesto una risorsa che non esiste.

---

# 19. Verificare il frontend dal browser

Aprire:

```text
http://127.0.0.1:8000/
```

Dovrebbero comparire quattro prodotti con prezzo, stock e stato `LOW`/`OK`.

Se il browser mostra un errore ma `/health` funziona, il problema non è necessariamente che il server sia spento. Dovremo distinguere frontend, API e configurazione: sarà proprio il tipo di ragionamento usato nel LAB autonomo.

---

# 20. Registrare nel repository la baseline dell'applicazione

Fermare il server con:

```text
Ctrl+C
```

Tornare alla root del repository:

```bash
cd "$LAB_REPO"
```

Controllare:

```bash
git status
git diff
```

Aggiungere soltanto l'applicazione:

```bash
git add app/catalogo-prodotti
git diff --cached
```

Dopo aver verificato il diff:

```bash
git commit -m "feat: add local product catalog"
```

Sincronizzare secondo le regole del repository. Se `main` richiede PR, usare una feature branch; non disabilitare le protezioni.

---

# 21. Chiudere la parte guidata verificando le evidenze

Nel file di consegna `01_LAB_GUIDATO.md` devono risultare documentati almeno:

- repository e branch;
- Pull Request collaborativa ricevuta;
- review e correzione;
- merge;
- rimozione del collaboratore;
- collaborazione eseguita sul repository altrui;
- conflitto e sua risoluzione;
- struttura del Catalogo prodotti;
- test `/health`, `/api/products`, prodotto esistente e `404` atteso;
- commit della baseline applicativa.

Prima di passare al LAB autonomo, verificare infine:

```bash
cd "$LAB_REPO"
git status
```

Il repository deve essere in uno stato comprensibile e controllato.
