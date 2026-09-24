# UD14 — LAB autonomo
## Una modifica che la CI deve fermare

Questa attività conclude UD14 all'inizio della seconda giornata.

Il merge deve attivare la **singola pipeline CI scelta nel LAB guidato**.

---

# 1. Creare una branch

```bash
export LAB_REPO="$HOME/workspace/azure-devops-lab"
cd "$LAB_REPO"
```

```bash
git switch main
git pull --ff-only
git switch -c feature/ud14-ci-v2
```

---

# 2. Modificare soltanto l'applicazione

Aprire:

```text
app/catalog-backend-ci/server.py
```

Cambiare:

```python
APP_VERSION = os.getenv("APP_VERSION", "ci-v1")
```

in:

```python
APP_VERSION = os.getenv("APP_VERSION", "ci-v2")
```

Non modificare ancora il test.

Commit e push:

```bash
git add app/catalog-backend-ci/server.py
git commit -m "feat: bump catalog version to ci-v2"
git push -u origin feature/ud14-ci-v2
```

Aprire una PR.

---

# 3. Verificare che il test segnali l'incoerenza

Prima del merge, eseguire localmente:

```bash
python3 -m unittest discover \
  -s app/catalog-backend-ci/tests \
  -v
```

Il test:

```text
test_health_version
```

deve fallire.

Questo è il comportamento corretto.

La nuova versione dell'app non rispetta più il criterio definito dal test.

---

# 4. Aggiornare il test

Nel file:

```text
app/catalog-backend-ci/tests/test_backend.py
```

cambiare:

```python
self.assertEqual(payload["version"], "ci-v1")
```

in:

```python
self.assertEqual(payload["version"], "ci-v2")
```

Rieseguire:

```bash
python3 -m unittest discover \
  -s app/catalog-backend-ci/tests \
  -v
```

Atteso:

```text
OK
```

Commit:

```bash
git add app/catalog-backend-ci/tests/test_backend.py
git commit -m "test: align expected catalog version"
git push
```

---

# 5. PR e CI

Verificare il diff della PR.

Completare il merge secondo le policy del repository.

Il merge su `main` deve attivare la pipeline CI.

Ricordare:

```text
MICROSOFT_HOSTED
→ nessun run.sh locale necessario

SELF_HOSTED_FALLBACK
→ Agent locale Online
```

Seguire la nuova run:

```text
Test
→ BuildPush
```

---

# 6. Verificare il nuovo tag

Dopo la run:

```bash
export ACR_NAME=$(az acr list \
  --resource-group rg-ud13-15-delivery \
  --query "[0].name" \
  --output tsv)
```

```bash
az acr repository show-tags \
  --name "$ACR_NAME" \
  --repository catalog-backend \
  --orderby time_desc \
  --output table
```

Deve comparire il nuovo Build ID.

Annotarlo:

```text
UD14_FINAL_IMAGE_TAG=<Build ID>
```

Non è necessario esportarlo come variabile permanente: UD15 costruirà un nuovo tag nella pipeline integrata.

---

# 7. Nessun cleanup

Non eliminare:

```text
ACR
immagini
sc-acr-ud14
sc-azure-ud13-15
agent
pipeline CI
```

Passare direttamente alla verifica e poi a UD15.
