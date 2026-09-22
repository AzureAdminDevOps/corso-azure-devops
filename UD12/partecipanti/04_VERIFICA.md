# UD12 — Verifica individuale

## Parte A — Scelta singola

### 1. In un approccio dichiarativo si descrive principalmente:

- A. la sequenza esatta di click
- B. lo stato desiderato
- C. soltanto il comando di cleanup
- D. il log della VM

### 2. Bicep viene distribuito tramite:

- A. Azure Resource Manager
- B. GitHub Pages
- C. Docker Engine
- D. DNS

### 3. `az deployment group what-if` serve principalmente a:

- A. eliminare il Resource Group
- B. prevedere le modifiche di un deployment
- C. creare il Terraform state
- D. avviare l'agent

### 4. `terraform init`:

- A. crea sempre risorse Azure
- B. prepara la directory e i provider
- C. elimina lo state
- D. esegue il destroy

### 5. `terraform validate`:

- A. sostituisce sempre `plan`
- B. controlla la configurazione senza applicare risorse
- C. elimina le risorse non valide
- D. crea un ACR

### 6. Il Terraform state serve principalmente a:

- A. memorizzare il PAT dell'agent
- B. collegare gli oggetti Terraform alle risorse gestite
- C. sostituire Git
- D. memorizzare Dockerfile

### 7. `terraform destroy`:

- A. elimina anche i file `.tf`
- B. rimuove le risorse gestite dalla configurazione/state
- C. disinstalla Terraform
- D. elimina l'organizzazione Azure DevOps

### 8. Dopo UD12 dobbiamo conservare:

- A. soltanto il Resource Group Bicep
- B. codice IaC, strumenti e agent configurato
- C. tutti i Resource Group temporanei
- D. il file `terraform.tfstate` in GitHub

---

## Parte B — Risposte brevi

### 9. Distingui approccio imperativo e dichiarativo.

### 10. Perché è utile separare parametri e definizione delle risorse?

### 11. Distingui Bicep What-If e Terraform Plan.

### 12. Perché il Terraform state non deve essere committato come un normale sorgente?

### 13. Distingui `terraform validate`, `plan` e `apply`.

### 14. Perché in questa UD distruggiamo le risorse Azure ma conserviamo i file IaC?

---

## Parte C — Scenario

> Un collega modifica `main.tf`. `terraform validate` riesce. `terraform plan` mostra `1 to add, 0 to change, 2 to destroy`, ma il collega si aspettava soltanto l'aggiunta di un tag.

### 15. Deve eseguire immediatamente `terraform apply`? Spiega il perché.

### 16. Quali controlli dovrebbe fare prima di applicare qualsiasi modifica?

### 17. Perché installare Terraform in WSL2 prepara il self-hosted Agent ma non garantisce nulla sul Microsoft-hosted Agent?

### 18. Perché un Job Microsoft-hosted non deve dipendere da file creati dal Job precedente?

### 19. Perché è utile verificare `terraform version`, `az version` e `az bicep version` all'interno di una pipeline?

### 20. Qual è il vantaggio e quale il rischio di usare `ubuntu-latest` rispetto a un'immagine versionata?

---

# Dopo la verifica — Gate 2A self-hosted e Gate 2B Microsoft-hosted

Terraform e Bicep sono stati installati o verificati durante UD12.

Prima di iniziare le pipeline successive distinguiamo due ambienti.

# Gate 2A — Self-hosted Agent

## 1. Verificare gli strumenti nella shell

Da WSL2:

```bash
terraform version
az version
az bicep version
git --version
python3 --version
docker --version
```

Questi sono i tool che il nostro self-hosted Agent dovrà poter raggiungere.

## 2. Riavviare il processo Agent

Se `run.sh` è ancora attivo:

```text
Ctrl+C
```

Poi:

```bash
cd "$HOME/azdo-agent"
./run.sh
```

Atteso:

```text
Listening for Jobs
```

Non rieseguire:

```text
./config.sh
```

e non creare un nuovo PAT.

## 3. Verificare Azure DevOps

Aprire:

```text
Project settings
→ Agent pools
→ pool-ud09-wsl
→ Agents
→ agent UD09
```

Lo stato deve essere:

```text
Online
```

Aprire le capability.

Dopo l'installazione di nuovi software il riavvio dell'Agent permette di rileggere l'ambiente.

Non è necessario che ogni comando venga visualizzato con esattamente lo stesso nome tra le capability: il controllo definitivo resta anche la possibilità concreta di eseguire il comando dal PATH dell'Agent.

## 4. Non fare cleanup dell'Agent

L'Agent deve restare configurato.

A fine giornata `run.sh` può essere fermato.

Per riavviarlo:

```bash
cd "$HOME/azdo-agent"
./run.sh
```

Il Gate 2A è superato quando:

```text
Agent Online
+
Terraform disponibile
+
Azure CLI/Bicep disponibile
+
Git/Python/Docker disponibili
```

---

# Gate 2B — Microsoft-hosted

Tornare allo stato annotato in UD09.

Nel file di consegna indicare uno dei valori:

```text
MICROSOFT_HOSTED_READY
MICROSOFT_HOSTED_PENDING
MICROSOFT_HOSTED_REQUEST_SUBMITTED
MICROSOFT_HOSTED_BILLING_NOT_ELIGIBLE
```

In UD12 **non eseguiamo una pipeline hosted solo per verificare i tool**.

Il concetto da conservare è:

```text
Microsoft-hosted
→ nuova VM per ogni Job
→ software preinstallato dipendente dall'immagine
→ versioni da verificare nella pipeline
→ eventuale installazione/configurazione nel Job
```

Se lo stato non è `READY`, il corso prosegue comunque.

UD13 userà il self-hosted Agent.

---

# Gate finale UD12

```text
risorse temporanee UD12 eliminate
+
file IaC conservati
+
lock file Terraform conservato
+
self-hosted Agent pronto
+
stato Microsoft-hosted documentato
```
