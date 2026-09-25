# UD15 — LAB guidato
## Pipeline integrata con Terraform, ACR e Azure Container Apps

I controlli iniziali sono già stati completati.

La UD14 rimane invariata.

Da questo momento la pipeline utilizza:

```text
sc-azure-ud13-15
```

come unica service connection Azure.

La pipeline utilizza Terraform per descrivere e distribuire Azure Container Apps.

---

# 0. Preparare la consegna

Definire:

```bash
export COURSE_UD15="$HOME/workspace/corso-azure-devops/UD15/partecipanti"
export LAB_REPO="$HOME/workspace/azure-devops-lab"
export LAB_SUBMISSION="$LAB_REPO/consegne/UD15"
```

Creare la directory:

```bash
mkdir -p "$LAB_SUBMISSION"
```

Copiare i modelli:

```bash
cp -n "$COURSE_UD15/modelli/00_DOMANDE_CONCETTI.md"       "$LAB_SUBMISSION/00_DOMANDE_CONCETTI.md"

cp -n "$COURSE_UD15/modelli/01_LAB_GUIDATO.md"       "$LAB_SUBMISSION/01_LAB_GUIDATO.md"

cp -n "$COURSE_UD15/modelli/02_LAB_AUTONOMO.md"       "$LAB_SUBMISSION/02_LAB_AUTONOMO.md"

cp -n "$COURSE_UD15/modelli/03_VERIFICA.md"       "$LAB_SUBMISSION/03_VERIFICA.md"
```

Verificare:

```bash
find "$LAB_SUBMISSION"   -maxdepth 1   -type f   -printf '%f\n'   | sort
```

---

# 1. Copiare la configurazione Terraform UD15

Creare la directory:

```bash
mkdir -p "$LAB_REPO/infra/terraform/ud15"
```

Copiare:

```bash
cp "$COURSE_UD15/infra/terraform/ud15/versions.tf"    "$LAB_REPO/infra/terraform/ud15/versions.tf"

cp "$COURSE_UD15/infra/terraform/ud15/providers.tf"    "$LAB_REPO/infra/terraform/ud15/providers.tf"

cp "$COURSE_UD15/infra/terraform/ud15/variables.tf"    "$LAB_REPO/infra/terraform/ud15/variables.tf"

cp "$COURSE_UD15/infra/terraform/ud15/main.tf"    "$LAB_REPO/infra/terraform/ud15/main.tf"

cp "$COURSE_UD15/infra/terraform/ud15/outputs.tf"    "$LAB_REPO/infra/terraform/ud15/outputs.tf"
```

La configurazione è separata dai file Terraform delle unità precedenti.

Il percorso è:

```text
infra/terraform/ud15
```

---

# 2. Leggere `versions.tf`

Il file utilizza una versione precisa del provider AzureRM:

```text
hashicorp/azurerm
5.4.0
```

La versione è fissata per evitare che partecipanti diversi eseguano il laboratorio con release differenti del provider.

La novità è:

```hcl
backend "azurerm"
```

Lo state viene quindi conservato nello Storage Account preparato nei controlli iniziali.

Il backend utilizza:

```text
Azure CLI authentication
Microsoft Entra authentication
```

La sessione Azure CLI verrà aperta da `AzureCLI@2` tramite `sc-azure-ud13-15`.

---

# 3. Leggere `main.tf`

Terraform legge tre oggetti esistenti:

```text
Resource Group
Azure Container Registry
user-assigned managed identity
```

e gestisce due risorse:

```text
Container Apps Environment
Container App
```

La Container App utilizza:

```text
immagine ACR
managed identity
AcrPull
ingress esterno
target port
```

Terraform non crea role assignment nella pipeline.

Le autorizzazioni sono state preparate nei controlli iniziali.

---

# 4. Verificare localmente la configurazione

Entrare nella directory:

```bash
cd "$LAB_REPO/infra/terraform/ud15"
```

Per la sola verifica sintattica inizializzare senza backend:

```bash
terraform init   -backend=false
```

Poi:

```bash
terraform fmt
terraform fmt -check
terraform validate
```

Atteso:

```text
Success! The configuration is valid.
```

Non eseguire ancora `terraform apply` localmente.

Il deployment verrà eseguito dalla pipeline.

---

# 5. Copiare le pipeline

Creare la directory:

```bash
mkdir -p "$LAB_REPO/pipelines"
```

Copiare la pipeline di delivery:

```bash
cp "$COURSE_UD15/pipeline/azure-pipelines-delivery.yml"    "$LAB_REPO/pipelines/azure-pipelines-delivery.yml"
```

Copiare anche la pipeline che verrà utilizzata solo alla fine:

```bash
cp "$COURSE_UD15/pipeline/azure-pipelines-cleanup.yml"    "$LAB_REPO/pipelines/azure-pipelines-cleanup.yml"
```

La pipeline principale esegue:

```text
IaC
↓
Test
↓
BuildPush
↓
Deploy
↓
Smoke
```

---

# 6. Leggere lo stage `IaC`

Lo stage viene eseguito con:

```text
AzureCLI@2
↓
sc-azure-ud13-15
```

All'interno della sessione vengono eseguiti:

```text
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Il backend utilizza:

```text
Storage Account dello state
container tfstate
ud15.tfstate
```

Il piano viene mostrato nei log ma non viene ancora applicato.

---

# 7. Leggere lo stage `BuildPush`

Il percorso è:

```text
AzureCLI@2
↓
az acr login
↓
docker build
↓
docker push
```

Verificare che il file contenga:

```bash
grep -nE   'AzureCLI@2|az acr login|docker build|docker push|Build.BuildId'   "$LAB_REPO/pipelines/azure-pipelines-delivery.yml"
```

La pipeline non deve utilizzare:

```text
Docker@2
sc-acr-ud14
```

Verificare:

```bash
if grep -nE   'Docker@2|sc-acr-ud14'   "$LAB_REPO/pipelines/azure-pipelines-delivery.yml"
then
  echo "Configurazione non coerente"
else
  echo "Configurazione coerente"
fi
```

Atteso:

```text
Configurazione coerente
```

---

# 8. Leggere lo stage `Deploy`

Dopo il push dell'immagine, lo stage `Deploy` esegue nuovamente:

```text
terraform init
terraform plan
terraform apply
```

Il secondo piano viene creato perché lo stato reale potrebbe essere cambiato rispetto allo stage iniziale.

Il tag passato a Terraform è:

```text
$(Build.BuildId)
```

Terraform configura la Container App con:

```text
catalog-backend:<Build ID>
```

e imposta:

```text
APP_VERSION=<Build ID>
```

---

# 9. Commit

Tornare al repository:

```bash
cd "$LAB_REPO"
git status
```

Aggiungere:

```bash
git add   infra/terraform/ud15   pipelines/azure-pipelines-delivery.yml   pipelines/azure-pipelines-cleanup.yml
```

Controllare:

```bash
git diff --cached
```

Commit:

```bash
git commit -m "feat: add terraform delivery pipeline"
git push
```

---

# 10. Creare la pipeline finale

Azure DevOps:

```text
Pipelines
→ New pipeline
→ GitHub
→ repository del laboratorio
→ Existing Azure Pipelines YAML file
```

Selezionare:

```text
/pipelines/azure-pipelines-delivery.yml
```

Salvare.

Se Azure DevOps richiede l'autorizzazione all'uso di:

```text
sc-azure-ud13-15
```

autorizzare soltanto questa pipeline.

---

# 11. Prima run

Avviare la pipeline.

Seguire gli stage:

```text
IaC
Test
BuildPush
Deploy
Smoke
```

Nel log dello stage `IaC` individuare:

```text
terraform init
terraform validate
terraform plan
```

Nel log di `BuildPush` individuare:

```text
az acr login
docker build
docker push
```

Nel log di `Deploy` individuare:

```text
terraform plan
terraform apply
```

---

# 12. Verificare lo state remoto

Dopo `Deploy`, aprire nel Portale Azure:

```text
Storage Account dello state
→ Containers
→ tfstate
```

Deve essere presente:

```text
ud15.tfstate
```

Non scaricare, modificare o versionare manualmente il file.

Terraform lo gestisce tramite il backend AzureRM.

---

# 13. Verificare le risorse

Da WSL2:

```bash
az containerapp env show   --name acaenv-ud15   --resource-group rg-ud13-15-delivery   --query "{Name:name,Location:location,State:properties.provisioningState}"   --output table
```

Poi:

```bash
az containerapp show   --name catalog-api-ud15   --resource-group rg-ud13-15-delivery   --query "{Name:name,State:properties.provisioningState,FQDN:properties.configuration.ingress.fqdn}"   --output table
```

---

# 14. Verificare immagine e versione

Recuperare ACR:

```bash
export ACR_NAME=$(az acr list   --resource-group rg-ud13-15-delivery   --query "[0].name"   --output tsv)
```

Elencare i tag:

```bash
az acr repository show-tags   --name "$ACR_NAME"   --repository catalog-backend   --orderby time_desc   --output table
```

Recuperare FQDN:

```bash
export ACA_FQDN=$(az containerapp show   --name catalog-api-ud15   --resource-group rg-ud13-15-delivery   --query properties.configuration.ingress.fqdn   --output tsv)
```

Verificare:

```bash
curl -s "https://$ACA_FQDN/health"   | python3 -m json.tool
```

Il campo:

```text
version
```

deve corrispondere al Build ID della pipeline.

---

# 15. Verificare la revision

```bash
az containerapp revision list   --name catalog-api-ud15   --resource-group rg-ud13-15-delivery   --query "[].{Name:name,Active:properties.active,Health:properties.healthState,Replicas:properties.replicas}"   --output table
```

Registrare nella consegna:

```text
Build ID
image tag
APP_VERSION
FQDN
revision
risultato /health
```

---

# 16. Concludere il laboratorio guidato

Non eseguire ancora il cleanup.

Passare a:

```text
03_LAB_AUTONOMO.md
```
