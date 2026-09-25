# UD15 — Verifica finale

## Scenario 1

La pipeline mostra:

```text
IaC succeeded
Test succeeded
BuildPush succeeded
Deploy succeeded
Smoke failed
```

Terraform ha applicato:

```text
target_port = 9999
```

mentre l'applicazione ascolta sulla porta `8000`.

1. Qual è la causa più probabile?
2. Quali componenti non modificheresti?

## Scenario 2

Lo stage `IaC` fallisce durante `terraform init` con un errore 403 sul Blob Storage dello state.

3. Quale autorizzazione controlli?
4. Perché non devi spostare lo state nel repository come soluzione?

## Scenario 3

Lo stage `BuildPush` fallisce durante `az acr login` o `docker push`.

5. Quale service connection e quale ruolo controlli?
6. Perché non abiliti l'admin user dell'ACR?

## Scenario 4

`terraform apply` riesce, ma `/health` restituisce una versione differente dal Build ID atteso.

7. Quali elementi confronti per ricostruire la release?

## Concetti finali

8. Distingui Continuous Integration e Continuous Delivery.
9. Perché UD15 utilizza uno state remoto?
10. Perché lo Storage Account dello state viene preparato prima del laboratorio?
11. Come si autentica Terraform nella pipeline?
12. Quali risorse sono data source e quali sono gestite da Terraform?
13. Perché il piano viene eseguito anche prima della build?
14. Perché viene ricreato nello stage Deploy?
15. Perché la pipeline utilizza `AzureCLI@2` invece di `Docker@2`?
16. Quale ruolo ha la pipeline sull'ACR?
17. Quale ruolo ha la managed identity della Container App?
18. Perché `workspace: clean: all` non deve cancellare lo state della delivery?
19. Che cosa viene eliminato da `terraform destroy` alla fine?

---

# Cleanup finale

Eseguire questa parte soltanto dopo:

```text
LAB guidato completato
LAB autonomo completato
run di ripristino riuscita
verifica compilata
evidenze salvate
```

## 1. Creare la pipeline di cleanup

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
/pipelines/azure-pipelines-cleanup.yml
```

Autorizzare:

```text
sc-azure-ud13-15
```

soltanto per questa pipeline.

## 2. Eseguire `terraform destroy`

Avviare la pipeline di cleanup.

Nei log verificare:

```text
terraform init
terraform plan -destroy
terraform destroy
```

Terraform deve rimuovere:

```text
Container App
Container Apps Environment
```

senza eliminare:

```text
ACR
managed identity
Storage dello state
Resource Group
```

perché queste risorse non appartengono allo state UD15.

## 3. Eliminare le risorse condivise

Dopo il successo di `terraform destroy`:

```bash
az group delete   --name rg-ud13-15-delivery   --yes
```

Verificare:

```bash
az group exists   --name rg-ud13-15-delivery
```

Atteso:

```text
false
```

## 4. Rimuovere le service connection

In Azure DevOps:

```text
Project settings
→ Service connections
```

Rimuovere:

```text
sc-azure-ud13-15
```

Se è ancora presente dalla UD14, rimuovere anche:

```text
sc-acr-ud14
```

## 5. Rimuovere il self-hosted Agent

Fermare `run.sh`.

Poi:

```bash
cd "$HOME/azdo-agent"
./config.sh remove
```

Verificare in Azure DevOps che l'Agent non sia più registrato.

I file Terraform, YAML e le consegne rimangono nel repository.
