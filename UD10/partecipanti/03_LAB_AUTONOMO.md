# UD10 — Laboratorio autonomo
## Errore di variabile, diagnosi e verifica del fix

## Obiettivo

Applicare:

```text
sintomo
→ ps
→ logs
→ inspect/config
→ causa
→ fix minimo
→ recreate
→ test
→ verifica individuale
→ cleanup finale
```

---

# 1. Riprendere il repository e verificare la baseline

Impostare nuovamente il percorso standard, così il LAB autonomo non dipende dal fatto che la shell del LAB guidato sia ancora aperta:

```bash
export LAB_REPO="$HOME/workspace/azure-devops-lab"
```

Verificare:

```bash
test -d "$LAB_REPO/.git" && echo "Repository personale trovato"
test -f "$LAB_REPO/app/catalogo-prodotti/compose.yaml" && echo "Compose UD10 trovato"
```

Se il repository personale è stato collocato in un percorso diverso nelle UD precedenti, modificare soltanto `LAB_REPO`.

Entrare nell'applicazione:

```bash
cd "$LAB_REPO/app/catalogo-prodotti"
```

Riavviare/verificare lo stack:

```bash
docker compose up -d
docker compose ps
```

Test:

```bash
curl -i http://127.0.0.1:8080/health
```

Deve rispondere `200`.

---

# 2. Creare branch

Dal repository:

```bash
cd "$(git rev-parse --show-toplevel)"
git switch main
git pull --ff-only
git switch -c fix/ud10-invalid-threshold
```

Tornare:

```bash
cd app/catalogo-prodotti
```

---

# 3. Introdurre errore

Nel `compose.yaml`, cambiare:

```yaml
LOW_STOCK_THRESHOLD: "5"
```

in:

```yaml
LOW_STOCK_THRESHOLD: "not-a-number"
```

---

# 4. Applicare

```bash
docker compose up -d
```

Poi:

```bash
docker compose ps -a
```

Non correggere subito.

---

# 5. Raccogliere evidenze

Backend:

```bash
docker compose logs --tail 50 backend
```

Domande:

1. il container backend è running?
2. è healthy?
3. quale eccezione compare?
4. quale variabile viene citata?

---

# 6. Verificare configurazione Compose

```bash
docker compose config
```

Cercare:

```text
LOW_STOCK_THRESHOLD
```

Non pubblicare l'intero environment se in futuro contiene segreti.

---

# 7. Formulare diagnosi

Compilare:

```text
Sintomo:
Risultato atteso:
Evidenza:
Ipotesi:
Causa:
```

---

# 8. Fix minimo

Ripristinare:

```yaml
LOW_STOCK_THRESHOLD: "5"
```

Non modificare Dockerfile, rete o porte.

---

# 9. Recreate

```bash
docker compose up -d
```

Verifica:

```bash
docker compose ps
```

Attendere:

```text
backend healthy
```

---

# 10. Test

```bash
curl -i http://127.0.0.1:8080/health
```

```bash
curl -s http://127.0.0.1:8080/api/products \
  | python3 -m json.tool
```

Browser:

```text
http://127.0.0.1:8080/
```

---

# 11. Verificare che non servisse rebuild

Rispondere:

```text
Era necessario `docker compose build`?
```

Motivare considerando che l'errore era in una variabile runtime del `compose.yaml`, non nel contenuto dell'immagine.

---

# 12. Modifica reale da conservare

Per lasciare una modifica utile nel branch, aggiungere nel servizio backend:

```yaml
environment:
  APP_ENV: "local-docker"
```

Il backend non richiede questa variabile: è una configurazione documentale runtime.

Verificare:

```bash
docker compose config
docker compose up -d
curl -i http://127.0.0.1:8080/health
```

---

# 13. Git

```bash
cd "$(git rev-parse --show-toplevel)"
git diff
```

Controllare che la modifica sia limitata al Compose.

Poi:

```bash
git add app/catalogo-prodotti/compose.yaml
git diff --cached
git commit -m "fix: validate Docker runtime configuration"
git push -u origin fix/ud10-invalid-threshold
```

Aprire PR:

```bash
gh pr create \
  --base main \
  --head fix/ud10-invalid-threshold \
  --title "UD10: validate Docker runtime configuration" \
  --body "Diagnosi di variabile runtime non valida, ripristino del threshold e verifica completa dello stack."
```

Auto-verificare:

```bash
gh pr diff
```

Poi:

```bash
gh pr merge --squash --delete-branch
```

Se policy impediscono il merge, rispettare la policy senza disabilitarla.

---


# 14. Conservare lo stack fino alla verifica individuale

Il troubleshooting è concluso e la configurazione corretta è di nuovo attiva.

**Non eseguire ancora il cleanup.**

La verifica individuale contiene domande su:

- stato `running` e `healthy`;
- named volume;
- `docker compose down` e `down -v`;
- troubleshooting dello stack.

Mantenere quindi lo stack disponibile e passare a:

```text
04_VERIFICA.md
```

Il cleanup completo è riportato alla fine della verifica.
