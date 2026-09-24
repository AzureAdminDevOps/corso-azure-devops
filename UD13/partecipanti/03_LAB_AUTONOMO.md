# UD13 — LAB autonomo
## Diagnosticare un errore semplice di pipeline

Questa attività è breve perché UD14 deve iniziare nella stessa giornata.

L'obiettivo non è introdurre nuova infrastruttura, ma dimostrare che sai localizzare un errore.

---

# 1. Introdurre un errore di percorso controllato

Nel file:

```text
pipelines/azure-pipelines-iac.yml
```

cambiare temporaneamente:

```text
infra/bicep/delivery.bicep
```

in:

```text
infra/bicep/delivery-NON-ESISTE.bicep
```

Commit su una branch:

```bash
git switch -c fix/ud13-pipeline-path
git add pipelines/azure-pipelines-iac.yml
git commit -m "test: introduce UD13 pipeline path error"
git push -u origin fix/ud13-pipeline-path
```

Per questa esercitazione eseguire manualmente la pipeline indicando la branch appena pubblicata.

---

# 2. Leggere il fallimento

Non correggere immediatamente.

Individuare:

```text
stage
job
step
messaggio
path cercato
```

La domanda è:

```text
l'errore riguarda Azure?
il pool?
l'Agent?
l'autenticazione GitHub?
la service connection Azure?
oppure il filesystem/path del repository?
```

Controllare inoltre nei log:

```text
Agent.Name
Agent.OS
Build.SourcesDirectory
```

per ricordare **dove** il Job è stato realmente eseguito.

---

# 3. Correggere soltanto la causa

Ripristinare:

```text
infra/bicep/delivery.bicep
```

Commit:

```bash
git add pipelines/azure-pipelines-iac.yml
git commit -m "fix: restore Bicep pipeline path"
git push
```

Rieseguire la pipeline sulla stessa branch.

Il risultato atteso è:

```text
Validate → succeeded
Deploy → succeeded
```

---

# 4. Chiudere la branch

Aprire una PR verso `main`, verificare il diff e completare il merge secondo le policy del repository.

Non eliminare risorse Azure.

Il Resource Group e l'ACR sono già la base della UD14.
