# UD08 — Laboratorio autonomo
## Fix configurazione + test + Pull Request

## Obiettivo

Applicare un ciclo completo:

```text
errore
→ diagnosi
→ branch
→ fix
→ test
→ diff
→ commit
→ push
→ PR
→ verifica
```

Non serve un secondo collaboratore.

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
