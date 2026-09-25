# UD15 — Concetti
## Continuous Delivery con Terraform e una sola service connection Azure

La UD14 ha prodotto una pipeline CI capace di eseguire test, costruire una container image e pubblicarla in Azure Container Registry.

Prima di iniziare UD15 abbiamo analizzato quella soluzione con un Security Review.

La conclusione non è che OAuth o `Docker@2` siano tecnologie insicure.

La decisione è invece quella di utilizzare una sola Azure Resource Manager service connection per rendere il percorso più uniforme:

```text
sc-azure-ud13-15
```

La UD15 aggiunge la distribuzione dell'applicazione e utilizza Terraform come strumento Infrastructure as Code principale.

---

# 1. Dalla CI alla Continuous Delivery

La Continuous Integration risponde soprattutto a domande come:

```text
il codice supera i test?
l'immagine si costruisce?
l'immagine può essere pubblicata?
```

La Continuous Delivery aggiunge:

```text
l'artefatto può essere distribuito?
l'infrastruttura è coerente?
l'applicazione parte?
l'endpoint risponde?
la versione in esecuzione è quella attesa?
```

Il flusso UD15 è:

```text
Terraform plan
↓
Test
↓
BuildPush
↓
Terraform apply
↓
Smoke
```

---

# 2. Una sola service connection per la pipeline

La pipeline utilizza:

```text
sc-azure-ud13-15
```

La service connection è basata su Workload Identity Federation.

`AzureCLI@2` apre una sessione Azure con quell'identità.

All'interno della stessa sessione possiamo eseguire:

```text
az
Terraform
Docker
```

senza memorizzare password o client secret nel repository.

---

# 3. Perché non utilizziamo `Docker@2`

`Docker@2` rimane un task valido di Azure Pipelines.

Per accedere a un registry richiede però una Docker Registry service connection.

La nuova architettura utilizza soltanto la Azure Resource Manager service connection già disponibile.

Per questo il flusso diventa:

```text
AzureCLI@2
↓
sc-azure-ud13-15
↓
az acr login
↓
docker build
↓
docker push
```

L'identità associata a `sc-azure-ud13-15` riceve sul registry il ruolo:

```text
AcrPush
```

---

# 4. Perché Terraform usa uno state remoto

Terraform deve ricordare quali risorse gestisce.

Nelle prime esercitazioni abbiamo utilizzato uno state locale.

Nella pipeline finale questo sarebbe fragile perché ogni Job usa:

```yaml
workspace:
  clean: all
```

e una nuova run non deve dipendere dai file rimasti sul self-hosted Agent.

Per questo UD15 usa:

```text
Azure Storage
↓
container tfstate
↓
ud15.tfstate
```

Il backend `azurerm` conserva lo state in Blob Storage.

Per evitare differenze tra partecipanti, il laboratorio usa una versione precisa del provider AzureRM:

```text
5.4.0
```

La `.terraform.lock.hcl` generata da `terraform init` viene versionata insieme ai file `.tf`.

Questo permette a Job e run differenti di lavorare sulla stessa infrastruttura e offre anche il meccanismo di locking dello state.

---

# 5. Perché lo Storage dello state viene preparato prima

Terraform non può utilizzare come backend una risorsa che non esiste ancora.

Per questo lo Storage Account e il container dello state vengono preparati una volta nei controlli iniziali.

La pipeline vi accede con la stessa identità di:

```text
sc-azure-ud13-15
```

alla quale viene assegnato:

```text
Storage Blob Data Contributor
```

sul container `tfstate` dedicato allo state.

---

# 6. Autenticazione Terraform nella pipeline

I comandi Terraform vengono eseguiti dentro `AzureCLI@2`.

La service connection effettua l'autenticazione Azure tramite Workload Identity Federation.

Terraform riutilizza la sessione Azure CLI già autenticata.

Il modello è:

```text
Azure DevOps
↓
sc-azure-ud13-15
↓
Workload Identity Federation
↓
AzureCLI@2
↓
sessione Azure CLI
↓
Terraform
```

Non inseriamo credenziali nei file `.tf`.

---

# 7. Risorse esistenti e risorse gestite da Terraform

UD15 non deve ricreare tutto.

Sono già presenti:

```text
Resource Group
Azure Container Registry
user-assigned managed identity
```

Terraform li legge tramite data source.

Terraform gestisce invece:

```text
Container Apps Environment
Container App
```

Questa distinzione evita di importare nello state UD15 risorse create nelle unità precedenti.

---

# 8. Identità della pipeline e identità dell'applicazione

La pipeline deve pubblicare immagini:

```text
sc-azure-ud13-15
+
AcrPush
```

La Container App deve soltanto leggere l'immagine:

```text
id-ud15-acrpull
+
AcrPull
```

Quindi:

```text
identità di delivery
≠
identità di runtime
```

e:

```text
permesso di scrittura
≠
permesso di lettura
```

---

# 9. Azure Container Apps con Terraform

La configurazione Terraform contiene:

```text
azurerm_container_app_environment
azurerm_container_app
```

La Container App utilizza:

```text
registry privato ACR
user-assigned managed identity
ingress esterno
target port 8000
```

L'immagine viene costruita durante la stessa run della pipeline.

Il tag è:

```text
$(Build.BuildId)
```

---

# 10. Terraform plan prima della build

Il primo stage esegue:

```text
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Il piano può descrivere l'immagine con il nuovo Build ID anche se quella immagine non è ancora stata pubblicata.

Il piano non distribuisce la Container App.

Lo stage `BuildPush` pubblica l'immagine.

Lo stage `Deploy` crea un nuovo piano sullo stato aggiornato e applica il risultato.

---

# 11. Tracciabilità della release

Il Build ID viene usato come:

```text
tag immagine
APP_VERSION
```

Possiamo quindi collegare:

```text
run Azure DevOps
↓
Build ID
↓
tag ACR
↓
Container App
↓
/health
```

---

# 12. Smoke test

Un `terraform apply` riuscito significa che Azure ha accettato la configurazione prevista.

Non dimostra automaticamente che l'applicazione risponda correttamente.

Lo smoke test verifica:

```text
FQDN
/health
HTTP riuscito
versione attesa
```

---

# 13. Laboratorio autonomo

Nel laboratorio autonomo modifichiamo intenzionalmente:

```yaml
targetPort: '8000'
```

in:

```yaml
targetPort: '9999'
```

Terraform applicherà la nuova configurazione.

La pipeline potrà arrivare correttamente fino al deployment mentre lo smoke test evidenzierà il problema.

Lo scopo è distinguere:

```text
infrastruttura applicata
```

da:

```text
servizio funzionante
```

---

# 14. Cleanup

Prima di eliminare il Resource Group, una pipeline dedicata esegue:

```text
terraform destroy
```

sulle risorse gestite dallo state UD15.

Successivamente vengono rimosse le risorse condivise provenienti dalle unità precedenti.

---

# 15. Domande di controllo

1. Qual è la differenza tra CI e Continuous Delivery?
2. Quale service connection utilizza la pipeline UD15?
3. Perché non utilizziamo `Docker@2` nella nuova pipeline?
4. Quale ruolo deve avere l'identità della pipeline sull'ACR?
5. Perché Terraform usa uno state remoto?
6. Perché lo Storage dello state deve esistere prima di `terraform init`?
7. Quale ruolo permette alla pipeline di leggere e scrivere lo state Blob?
8. Come si autentica Terraform durante `AzureCLI@2`?
9. Quali risorse UD15 vengono lette come esistenti?
10. Quali risorse vengono gestite dallo state Terraform UD15?
11. Perché la Container App usa una managed identity differente dalla pipeline?
12. Quale ruolo ha la managed identity sull'ACR?
13. Perché eseguiamo `terraform plan` prima del build?
14. Perché il piano viene ricreato nello stage Deploy?
15. Che relazione esiste tra Build ID, tag immagine e `APP_VERSION`?
16. Perché uno smoke test può fallire dopo un `terraform apply` riuscito?
17. Perché `workspace: clean: all` rende importante lo state remoto?
18. Che cosa dimostra l'errore controllato sulla target port?
19. Quando viene eseguito `terraform destroy`?
