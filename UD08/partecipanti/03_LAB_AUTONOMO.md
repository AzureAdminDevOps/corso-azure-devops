# UD08 — Laboratorio autonomo
## Troubleshooting del Catalogo prodotti + workflow Git completo

## Obiettivo del laboratorio

In questo laboratorio non partiamo da un'applicazione realmente guasta: **introdurremo volontariamente un errore di configurazione** per esercitare un ciclo completo di troubleshooting e gestione Git.

L'applicazione Catalogo prodotti è composta da un backend e da un frontend che devono concordare sul prefisso utilizzato dalle API. Nella configurazione corretta entrambi lavorano con:

```text
/api
```

Durante il laboratorio modificheremo temporaneamente il backend affinché utilizzi:

```text
/api-v2
```

senza modificare il frontend.

Otterremo quindi intenzionalmente questa situazione:

```text
frontend
   │
   │ richiede /api/products
   ▼
backend
   │
   │ espone /api-v2/products
   ▼
404
```

L'obiettivo non è semplicemente "far tornare a funzionare l'applicazione", ma seguire un metodo completo:

```text
baseline funzionante
→ modifica controllata
→ osservazione del sintomo
→ raccolta delle evidenze
→ diagnosi
→ correzione
→ test
→ controllo Git
→ commit
→ push
→ Pull Request
→ verifica del diff
→ merge
```

Una particolarità importante: quando ripristineremo `/api`, il file tornerà identico alla versione presente in `main`. Git quindi potrebbe non avere più alcuna modifica da committare.

Per completare anche il ciclo Git aggiungeremo successivamente una piccola configurazione reale e innocua:

```json
"environment": "local"
```

Questa modifica non cambia il funzionamento dell'applicazione, ma ci permette di portare una modifica effettiva attraverso branch, commit, push, Pull Request e merge.

## Mappa delle attività

| Step | Che cosa facciamo | Perché lo facciamo | Che cosa dobbiamo ottenere/verificare |
|---:|---|---|---|
| **1. Baseline Git** | Torniamo su `main`, eseguiamo `git pull --ff-only` e controlliamo `git status`. | Prima di introdurre un errore dobbiamo essere certi di partire dalla versione aggiornata e pulita del repository. | `main` aggiornata, working tree pulita e presenza di `app/catalogo-prodotti/server.py`. |
| **2. Baseline applicativa** | Avviamo `python3 server.py` e interroghiamo `/health` e `/api/products`. | Prima di diagnosticare un problema dobbiamo dimostrare che l'applicazione funziona correttamente. Questa è la nostra baseline di confronto. | `/health` → HTTP 200 e `/api/products` → HTTP 200. |
| **3. Feature branch** | Creiamo `fix/ud08-api-prefix`. | L'esperimento non deve essere effettuato direttamente su `main`. Tutto il lavoro viene isolato in una branch dedicata. | La branch corrente deve essere `fix/ud08-api-prefix`. |
| **4. Errore controllato** | Modifichiamo in `config.json` il prefisso da `/api` a `/api-v2`, lasciando invariato il frontend. | Creiamo intenzionalmente un'incoerenza tra il contratto atteso dal frontend e quello esposto dal backend. | Backend configurato su `/api-v2`, frontend ancora configurato per usare `/api`. |
| **5. Osservazione del sintomo** | Avviamo nuovamente il server e testiamo sia `/api-v2/products` sia `/api/products`. Apriamo anche il frontend nel browser. | Prima di correggere dobbiamo osservare il comportamento reale e raccogliere evidenze. | `/api-v2/products` → 200, `/api/products` → 404, frontend in errore. |
| **6. Diagnosi** | Confrontiamo health check, endpoint funzionante, endpoint non funzionante e URL richiesto dal frontend. | Dobbiamo distinguere un problema di rete o di processo da un problema di configurazione/contratto applicativo. | Conclusione: backend attivo e raggiungibile, ma frontend e backend usano prefissi API differenti. |
| **7. Fix** | Ripristiniamo `"api_prefix": "/api"` in `config.json`. | La correzione minima consiste nel ristabilire il contratto originario condiviso da frontend e backend. | Frontend e backend utilizzano nuovamente `/api`. |
| **8. Test del fix** | Ripetiamo i test su `/health`, `/api/products`, `/api/products/P001`, un prodotto inesistente e il frontend. | Una correzione non è conclusa finché non viene verificata. Controlliamo sia i casi positivi sia un caso negativo. | Health → 200, products → 200, P001 → 200, prodotto inesistente → 404, frontend funzionante. |
| **9. Controllo del diff** | Eseguiamo `git diff`. Dopo il ripristino di `/api` il diff può essere vuoto. | Abbiamo introdotto e poi corretto l'errore tornando esattamente allo stato di `main`. Git quindi può non avere più nulla da committare. | Comprendere perché un fix può lasciare `git diff` vuoto. |
| **10. Modifica reale da versionare** | Aggiungiamo `"environment": "local"` a `config.json`. | Serve una modifica effettiva, innocua e coerente da far attraversare al workflow Git. Il server ignora questa chiave aggiuntiva. | `config.json` contiene `/api` corretto più `environment=local`. |
| **11. Retest dopo la modifica reale** | Riavviamo il server e ripetiamo almeno `/health` e `/api/products`. | Anche una modifica apparentemente innocua deve essere verificata prima del commit. | Entrambi gli endpoint continuano a restituire HTTP 200. |
| **12. Revisione del diff** | Eseguiamo `git diff`. | Prima dello staging dobbiamo controllare esattamente che cosa stiamo per versionare. | Deve comparire soltanto la modifica prevista a `config.json`. |
| **13. Staging e commit** | Eseguiamo `git add`, controlliamo `git diff --cached` e creiamo il commit. | Il controllo dello staged diff evita di includere accidentalmente file o modifiche non pertinenti. | Un commit contenente soltanto la modifica prevista. |
| **14. Push** | Pubblichiamo la branch con `git push -u origin fix/ud08-api-prefix`. | La branch deve esistere anche su GitHub prima di poter creare una Pull Request. | Branch remota creata e associata alla branch locale. |
| **15. Pull Request** | Creiamo la PR verso `main` con `gh pr create`. | La modifica passa attraverso lo stesso meccanismo di integrazione utilizzato nel lavoro collaborativo, anche se questa volta il lavoro è individuale. | PR aperta da `fix/ud08-api-prefix` verso `main`. |
| **16. Auto-verifica della PR** | Eseguiamo `gh pr diff` e controlliamo file, contenuto e assenza di segreti. | Non possiamo parlare di review indipendente perché autore e revisore coincidono; possiamo però effettuare una verifica consapevole del diff prima del merge. | Un solo file modificato, modifica attesa, test già eseguiti, nessun dato sensibile. |
| **17. Squash merge** | Eseguiamo `gh pr merge --squash --delete-branch`, se le regole del repository lo consentono. | Lo squash integra il lavoro mantenendo `main` con un singolo commit logico e rimuove la branch ormai conclusa. | PR merged e branch remota eliminata. |
| **18. Sincronizzazione finale** | Torniamo su `main`, eseguiamo `git pull --ff-only` e controlliamo `git log --oneline -5`. | La copia locale deve essere riallineata allo stato finale presente su GitHub. | `main` contiene il commit risultante dallo squash merge. |
| **19. Consegna** | Documentiamo sintomo, causa, fix, test, branch, commit, PR e merge. | L'attività non deve dimostrare soltanto che "alla fine funziona", ma anche il percorso diagnostico e Git seguito per arrivarci. | Evidenza completa del ciclo troubleshooting → Git → PR → merge. |

## Risultato finale atteso

Al termine del laboratorio:

```text
main
└── app/catalogo-prodotti/config.json
    ├── api_prefix = /api
    └── environment = local
```

L'applicazione deve funzionare normalmente e la cronologia Git deve mostrare l'integrazione della modifica tramite Pull Request e squash merge.

È inoltre importante distinguere i due casi affrontati nella UD08:

```text
LAB guidato
→ PR collaborativa
→ una seconda persona effettua una vera review

LAB autonomo
→ PR individuale
→ l'autore controlla il proprio diff
→ non deve dichiarare di aver ricevuto una review indipendente
```

---

# 1. Riprendere il repository personale e verificare la baseline

Il percorso standard usato nella UD è:

```bash
export LAB_REPO="$HOME/workspace/azure-devops-lab"
```

Verificare che sia realmente il repository personale:

```bash
test -d "$LAB_REPO/.git" && echo "Repository personale trovato"
```

Se il repository è stato collocato in un percorso diverso durante le UD precedenti, modificare soltanto il valore di `LAB_REPO` con quel percorso effettivo.

Entrare nel repository:

```bash
cd "$LAB_REPO"
```

Ora riallineiamo `main` prima di creare una nuova branch:

```bash
git switch main
git pull --ff-only
git status
```

Verificare che esista:

```bash
test -f app/catalogo-prodotti/server.py
```

---

# 2. Avviare baseline

```bash
cd "$LAB_REPO/app/catalogo-prodotti"
python3 server.py
```

In un secondo terminale:

```bash
curl -i http://127.0.0.1:8000/health
curl -s http://127.0.0.1:8000/api/products | python3 -m json.tool
```

Entrambi devono funzionare.

Arrestare:

```text
Ctrl+C
```

---

# 3. Creare feature branch

```bash
cd "$LAB_REPO"
git switch -c fix/ud08-api-prefix
```

---

# 4. Introdurre errore controllato

Aprire:

```text
app/catalogo-prodotti/config.json
```

Modificare:

```json
"api_prefix": "/api"
```

in:

```json
"api_prefix": "/api-v2"
```

Non modificare `index.html`.

---

# 5. Osservare il problema

Avviare:

```bash
cd "$LAB_REPO/app/catalogo-prodotti"
python3 server.py
```

Test API nuovo prefisso:

```bash
curl -i http://127.0.0.1:8000/api-v2/products
```

Atteso:

```text
200
```

Test endpoint usato dal frontend:

```bash
curl -i http://127.0.0.1:8000/api/products
```

Atteso:

```text
404
```

Aprire:

```text
http://127.0.0.1:8000/
```

Il frontend segnala errore.

---

# 6. Diagnosi

Rispondere:

1. il backend è avviato?
2. `/health` funziona?
3. quale endpoint prodotti funziona?
4. quale endpoint usa il frontend?
5. il problema è di rete, backend spento o contratto/configurazione incoerente?

---

# 7. Fix

Obiettivo:

```text
frontend e backend devono usare /api
```

Ripristinare in:

```text
config.json
```

il valore:

```json
"api_prefix": "/api"
```

---

# 8. Test

Riavviare server.

Verificare:

```bash
curl -i http://127.0.0.1:8000/health
```

```bash
curl -i http://127.0.0.1:8000/api/products
```

```bash
curl -i http://127.0.0.1:8000/api/products/P001
```

```bash
curl -i http://127.0.0.1:8000/api/products/XXX
```

Atteso:

```text
health       → 200
products     → 200
P001         → 200
XXX          → 404
```

Verificare anche browser.

Arrestare server.

---

# 9. Problema: il fix torna identico a main

Il branch contiene ora una modifica introdotta e poi ripristinata.

Quindi:

```bash
git diff
```

potrebbe risultare vuoto.

Per produrre una modifica reale e utile, aggiungere in `config.json`:

```json
"environment": "local"
```

Il file deve diventare:

```json
{
  "host": "127.0.0.1",
  "port": 8000,
  "api_prefix": "/api",
  "low_stock_threshold": 5,
  "environment": "local"
}
```

Il server ignora le chiavi aggiuntive e continua a funzionare.

---

# 10. Verifica dopo modifica reale

Riavviare:

```bash
python3 server.py
```

Ripetere:

```bash
curl -i http://127.0.0.1:8000/health
curl -i http://127.0.0.1:8000/api/products
```

Arrestare server.

---

# 11. Diff

```bash
cd "$LAB_REPO"
git diff
```

Deve comparire soltanto la modifica attesa a `config.json`.

---

# 12. Commit

```bash
git add app/catalogo-prodotti/config.json
git diff --cached
```

Commit:

```bash
git commit -m "fix: restore API contract and mark local environment"
```

---

# 13. Push

```bash
git push -u origin fix/ud08-api-prefix
```

---

# 14. Pull Request individuale

```bash
gh pr create \
  --base main \
  --head fix/ud08-api-prefix \
  --title "UD08: restore catalog API contract" \
  --body "Verifica il contratto /api, esegue i test HTTP e aggiunge la configurazione environment=local."
```

---

# 15. Auto-verifica PR

```bash
gh pr diff
```

Controllare:

- un solo file modificato;
- nessun segreto;
- modifica coerente;
- test completati.

---

# 16. Merge

Poiché questa è una PR individuale, non dichiarare che è stata revisionata da una seconda persona.

Eseguire:

```bash
gh pr merge \
  --squash \
  --delete-branch
```

Se GitHub impedisce il merge per regole del repository:

```bash
gh pr view --web
```

leggere il requisito mancante e soddisfarlo senza disabilitare protezioni.

---

# 17. Sincronizzare

```bash
git switch main
git pull --ff-only
```

Verificare:

```bash
git log --oneline -5
```

---

# 18. Consegna

Documentare:

```text
sintomo
causa
fix
test
branch
commit
PR
merge
```

Distinguere chiaramente:

```text
PR collaborativa → review reale
PR individuale   → auto-verifica del diff
```
