# UD14 — Security Review
## Analisi conclusiva della CI e decisione per la UD15

La UD14 viene considerata conclusa con i materiali e con la procedura utilizzati durante il laboratorio.

Questo documento non richiede di modificare retroattivamente la pipeline UD14, le service connection, le App Registration o gli altri oggetti eventualmente creati durante l'esercitazione. Lo scopo è analizzare ciò che il team ha osservato durante l'esecuzione e trasformare quelle osservazioni in una decisione architetturale per la UD15.

---

# 1. Che cosa è stato realizzato nella UD14

La UD14 ha costruito una pipeline di Continuous Integration capace di:

```text
test
↓
build dell'immagine
↓
push in Azure Container Registry
```

Nel modello utilizzato durante la UD14 erano presenti due connessioni Azure DevOps:

```text
sc-azure-ud13-15
→ Azure Resource Manager
→ gestione delle risorse Azure

sc-acr-ud14
→ Docker Registry
→ autenticazione del task Docker@2 verso ACR
```

Questo modello può funzionare correttamente e il task `Docker@2` rimane un task supportato da Azure Pipelines.

---

# 2. Che cosa ha osservato il team

Durante l'esecuzione non tutti i componenti del team hanno incontrato lo stesso percorso autorizzativo.

In alcuni casi la creazione o l'utilizzo della connessione dedicata al registry ha richiesto passaggi interattivi di autorizzazione. In altri casi il percorso è proseguito senza la stessa richiesta.

Questa differenza non dimostra una vulnerabilità di OAuth e non dimostra che `Docker@2` sia insicuro.

Evidenzia però un problema di uniformità del processo: per una stessa pipeline il team si è trovato a dipendere da una seconda relazione di fiducia verso il registry e da una configurazione che non si è presentata nello stesso modo per tutti.

---

# 3. Considerazione di sicurezza e architettura

Una pipeline deve essere non soltanto funzionante, ma anche comprensibile, ripetibile e gestibile.

Mantenere due service connection significa mantenere due configurazioni distinte:

```text
pipeline
├── sc-azure-ud13-15
└── sc-acr-ud14
```

Ogni connessione deve essere creata, autorizzata, controllata e successivamente rimossa quando non serve più.

Per la fase successiva scegliamo quindi di ridurre questa superficie di configurazione e di utilizzare una sola Azure Resource Manager service connection:

```text
sc-azure-ud13-15
```

La connessione utilizza Workload Identity Federation e viene usata dalla pipeline per autenticarsi ad Azure senza memorizzare una password o un client secret nel file YAML.

---

# 4. Perché cambia il modo di pubblicare l'immagine

La decisione di utilizzare una sola Azure Resource Manager service connection ha una conseguenza tecnica precisa.

Il task:

```text
Docker@2
```

per il push verso un registry richiede una Docker Registry service connection.

Non può usare direttamente `sc-azure-ud13-15` come `containerRegistry`.

Per questo nella UD15 la pubblicazione dell'immagine verrà eseguita così:

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

Il cambiamento non deriva da un problema di sicurezza intrinseco di `Docker@2`.

Deriva dalla scelta architetturale di standardizzare la pipeline su una sola service connection Azure.

---

# 5. Separare l'identità della pipeline dall'identità dell'applicazione

Nella UD15 verranno utilizzate due identità con responsabilità differenti.

La pipeline deve poter pubblicare nuove immagini:

```text
sc-azure-ud13-15
+
AcrPush
↓
push delle immagini
```

La Container App deve invece soltanto poter leggere l'immagine necessaria all'esecuzione:

```text
managed identity della Container App
+
AcrPull
↓
pull dell'immagine
```

Questa separazione applica il principio del minimo privilegio:

```text
chi pubblica
≠
chi esegue

permesso di scrittura
≠
permesso di lettura
```

---

# 6. Terraform nella UD15

La nuova unità utilizzerà Terraform come strumento Infrastructure as Code principale.

Terraform gestirà:

```text
Container Apps Environment
Container App
configurazione dell'immagine
ingress
managed identity associata alla Container App
```

L'ACR e la user-assigned managed identity verranno letti come risorse già esistenti.

Lo state Terraform sarà conservato in Azure Storage, in modo che run differenti della pipeline lavorino sullo stesso stato dell'infrastruttura.

---

# 7. Che cosa facciamo con gli oggetti creati nella UD14

Al termine di questa lettura non viene modificato nulla della UD14.

In particolare:

```text
non cancellare sc-acr-ud14
non modificare App Registration
non modificare Enterprise Application
non ricostruire retroattivamente il percorso OAuth
non riscrivere la pipeline UD14
```

Se `sc-acr-ud14` esiste, rimane semplicemente una connessione appartenente alla soluzione precedente e non verrà utilizzata dalla nuova pipeline UD15.

La sua eventuale rimozione avverrà soltanto al termine del percorso.

---

# 8. Decisione per la UD15

La UD15 parte quindi da questa configurazione:

```text
pipeline
↓
sc-azure-ud13-15
↓
Workload Identity Federation
↓
Azure

BuildPush
↓
az acr login
↓
docker build
↓
docker push

Terraform
↓
state remoto in Azure Storage
↓
Container Apps Environment
↓
Container App

Runtime Container App
↓
managed identity
↓
AcrPull
↓
Azure Container Registry
```

Prima di iniziare il laboratorio della UD15 verranno verificati ambiente, strumenti, autorizzazioni e risorse necessarie.

Solo dopo questi controlli tutti i partecipanti inizieranno lo stesso laboratorio dalla stessa configurazione tecnica.

---

# 9. Conclusione

La UD14 non viene corretta retroattivamente.

Viene utilizzata come esperienza reale sulla quale applicare un principio importante del lavoro DevOps:

```text
implementazione
↓
osservazione
↓
analisi
↓
decisione architetturale
↓
nuova implementazione
```

La UD15 rappresenta la nuova implementazione.
