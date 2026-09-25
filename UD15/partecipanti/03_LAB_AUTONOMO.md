# UD15 — LAB autonomo
## Errore di target port e diagnosi end-to-end

Il laboratorio guidato ha distribuito correttamente la Container App tramite Terraform.

Ora introduciamo un errore controllato.

Non modificare:

```text
service connection
AcrPush
managed identity
AcrPull
Storage dello state
Agent
```

---

# 1. Verificare la situazione iniziale

```bash
curl -s "https://$ACA_FQDN/health"   | python3 -m json.tool
```

La versione deve corrispondere all'ultima pipeline riuscita.

---

# 2. Creare una branch

```bash
cd "$LAB_REPO"
git switch main
git pull --ff-only
git switch -c fix/ud15-target-port
```

---

# 3. Introdurre l'errore

Nel file:

```text
pipelines/azure-pipelines-delivery.yml
```

cambiare:

```yaml
targetPort: '8000'
```

in:

```yaml
targetPort: '9999'
```

Commit:

```bash
git add pipelines/azure-pipelines-delivery.yml
git commit -m "test: introduce wrong target port"
git push -u origin fix/ud15-target-port
```

Aprire la Pull Request e completare il merge su `main`.

---

# 4. Osservare la pipeline

Seguire:

```text
IaC
Test
BuildPush
Deploy
Smoke
```

Nel piano Terraform deve comparire la modifica della configurazione della Container App.

Lo stage `Deploy` può concludersi correttamente.

Lo stage `Smoke` deve invece rilevare il problema di raggiungibilità.

---

# 5. Raccogliere le evidenze

Verificare l'ingress:

```bash
az containerapp ingress show   --name catalog-api-ud15   --resource-group rg-ud13-15-delivery   --query "{External:external,TargetPort:targetPort,FQDN:fqdn}"   --output table
```

Verificare le revision:

```bash
az containerapp revision list   --name catalog-api-ud15   --resource-group rg-ud13-15-delivery   --output table
```

Verificare i log:

```bash
az containerapp logs show   --name catalog-api-ud15   --resource-group rg-ud13-15-delivery   --tail 30
```

Confrontare:

```text
targetPort = 9999
porta applicazione = 8000
```

---

# 6. Formulare la diagnosi

Compilare:

```text
Sintomo:
Stage riusciti:
Stage fallito:
Modifica Terraform prevista:
Evidenza ingress:
Evidenza log:
Causa:
Correzione minima:
```

---

# 7. Correggere

```bash
git switch main
git pull --ff-only
git switch -c fix/ud15-target-port-correct
```

Ripristinare:

```yaml
targetPort: '8000'
```

Commit:

```bash
git add pipelines/azure-pipelines-delivery.yml
git commit -m "fix: restore container app target port"
git push -u origin fix/ud15-target-port-correct
```

Aprire la Pull Request e completare il merge.

---

# 8. Verificare il ripristino

La nuova run deve arrivare a:

```text
Smoke → succeeded
```

Recuperare nuovamente FQDN e verificare `/health`.

Annotare nella consegna il Build ID della run di ripristino.

---

# 9. Non eseguire ancora il cleanup

Passare a:

```text
04_VERIFICA.md
```
