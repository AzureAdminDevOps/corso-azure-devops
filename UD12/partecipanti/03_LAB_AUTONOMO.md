# UD12 — Laboratorio autonomo
## Leggere un piano, modificare l'infrastruttura, diagnosticare un errore e ripulire

Il LAB guidato ha lasciato intenzionalmente disponibili:

```text
infra/terraform/
rg-ud12-tf
Storage Account Terraform
terraform.tfstate
```

Li useremo per completare autonomamente un piccolo ciclo di modifica.

---

# 1. Ripristinare il contesto

Da WSL2:

```bash
export LAB_REPO="$HOME/workspace/azure-devops-lab"
cd "$LAB_REPO/infra/terraform"
```

Verificare:

```bash
terraform version
az account show \
  --query "{Subscription:name,User:user.name}" \
  --output table
```

Ripristinare il Subscription ID per AzureRM:

```bash
export ARM_SUBSCRIPTION_ID=$(az account show \
  --query id \
  --output tsv)
```

Il nome Storage utilizzato dal LAB guidato può essere ricavato dallo state/output:

```bash
export TF_VAR_storage_account_name=$(terraform output \
  -raw storage_account_name)
```

Verificare:

```bash
echo "$TF_VAR_storage_account_name"
```

---

# 2. Controllare la baseline

```bash
terraform plan
```

Se nessuno ha modificato le risorse manualmente, il risultato atteso è:

```text
No changes.
```

Questo è un checkpoint importante.

Prima di modificare il codice vogliamo sapere che:

```text
codice
state
Azure
```

sono coerenti.

---

# 3. Modificare un tag

Aprire:

```text
infra/terraform/main.tf
```

Nel blocco dei tag dello Storage Account aggiungere:

```hcl
Environment = "Training"
```

Il blocco deve diventare simile a:

```hcl
tags = {
  Course      = "AZ104"
  UD          = "12"
  ManagedBy   = "Terraform"
  Environment = "Training"
}
```

Salvare.

---

# 4. Formattare e validare

```bash
terraform fmt
```

```bash
terraform validate
```

Se la configurazione è valida, passare al piano.

---

# 5. Leggere il piano di modifica

```bash
terraform plan \
  -out=ud12-change.tfplan
```

Questa volta non ci aspettiamo nuove risorse.

Il riepilogo dovrebbe essere:

```text
0 to add
1 to change
0 to destroy
```

Leggere quale proprietà cambierà.

Nella consegna spiegare:

```text
Perché Terraform propone una modifica e non la ricreazione dello Storage Account?
```

---

# 6. Applicare la modifica

```bash
terraform apply \
  ud12-change.tfplan
```

Verificare con Azure CLI:

```bash
az storage account show \
  --resource-group rg-ud12-tf \
  --name "$TF_VAR_storage_account_name" \
  --query tags \
  --output jsonc
```

Deve comparire:

```text
Environment = Training
```

---

# 7. Introdurre un errore controllato

Ora vogliamo verificare che `terraform validate` possa fermarci **prima** di eseguire un deployment.

Aprire:

```text
main.tf
```

Nel blocco Storage Account cambiare temporaneamente:

```hcl
location = azurerm_resource_group.lab.location
```

in:

```hcl
location = azurerm_resource_group.training.location
```

Non eseguire `apply`.

Eseguire:

```bash
terraform validate
```

Dovrebbe comparire un errore che segnala il riferimento a una risorsa non dichiarata.

Leggere il messaggio e individuare:

```text
resource type
resource name
riferimento errato
```

---

# 8. Correggere l'errore

Ripristinare:

```hcl
location = azurerm_resource_group.lab.location
```

Poi:

```bash
terraform fmt
terraform validate
```

Atteso:

```text
Success!
```

Infine:

```bash
terraform plan
```

Dopo la correzione non devono comparire modifiche inattese.

---

# 9. Commit dei file IaC prima del destroy

Le risorse Azure sono temporanee, ma il codice deve sopravvivere.

Tornare alla root:

```bash
cd "$LAB_REPO"
```

Controllare:

```bash
git status
```

Assicurarsi che NON vengano aggiunti:

```text
infra/terraform/.terraform/
infra/terraform/terraform.tfstate
infra/terraform/terraform.tfstate.backup
infra/terraform/*.tfplan
```

Aggiungere queste regole a `.gitignore` se non sono già presenti:

```text
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
```

Poi:

```bash
git add \
  .gitignore \
  infra/bicep \
  infra/terraform/*.tf \
  infra/terraform/.terraform.lock.hcl
```

Controllare:

```bash
git diff --cached
```

Non deve comparire alcun file di state.

Commit:

```bash
git commit \
  -m "feat: add Bicep and Terraform infrastructure baseline"
```

Push:

```bash
git push
```

Se il repository richiede una branch/PR, applicare il flusso Git già utilizzato nelle UD precedenti senza disabilitare le policy.

---

# 10. Ora possiamo distruggere le risorse Terraform

Le risorse di `rg-ud12-tf` non sono necessarie in UD13.

UD13 riutilizzerà:

```text
codice Terraform
codice Bicep
strumenti
agent
```

ma creerà nuovamente le risorse necessarie.

Tornare:

```bash
cd "$LAB_REPO/infra/terraform"
```

Visualizzare prima il piano di distruzione:

```bash
terraform plan \
  -destroy
```

Verificare che il piano riguardi soltanto:

```text
azurerm_storage_account.lab
azurerm_resource_group.lab
```

Poi:

```bash
terraform destroy
```

Leggere il piano proposto da Terraform.

Confermare digitando:

```text
yes
```

solo se le due risorse sono quelle attese.

---

# 11. Verifica cleanup Terraform

```bash
az group exists \
  --name rg-ud12-tf
```

Atteso:

```text
false
```

Controllare lo state:

```bash
terraform state list
```

Dopo il destroy non devono comparire le due risorse precedenti.

Non eliminare:

```text
main.tf
versions.tf
providers.tf
variables.tf
outputs.tf
.terraform.lock.hcl
```

---

# 12. Prepararsi al Gate 2

Terraform e Bicep sono ora disponibili nell'ambiente.

La verifica finale dell'agent viene svolta dopo la verifica individuale.

Non:

```text
rimuovere Terraform
rimuovere Bicep
eliminare ~/azdo-agent
rieseguire ./config.sh
creare un nuovo PAT
```

Questi elementi servono alle due giornate finali.
