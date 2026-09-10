# UD04 – Rinforzo Microsoft Learn
## AZ-104: Implement and manage storage in Azure
### Versione PARTECIPANTE

Percorso ufficiale di riferimento:

https://learn.microsoft.com/en-us/training/paths/az-104-manage-storage/

> Obiettivo: consolidare Azure Storage dopo la UD04 e integrare alcuni argomenti richiesti da AZ-104 senza seguire meccanicamente l'intero learning path.

---

# 1. Selezione dei moduli

| # | Modulo Microsoft Learn | Cosa fare | Priorità |
|---|---|---|---|
| 1 | Configure storage accounts | **Completo** | Massima |
| 2 | Configure Azure Blob Storage | **Quasi completo** | Massima |
| 3 | Configure Azure Storage security | **Completo** | Massima |
| 4 | Configure Azure Files | **Selezione mirata** | Alta |

---

# 2. Modulo 1 – Configure storage accounts

## Da svolgere integralmente

- Introduction
- Implement Azure Storage
- Explore Azure Storage services
- Determine storage account types
- Determine replication strategies
- Access storage
- Secure storage endpoints
- Module assessment
- Summary and resources

## Concetti da fissare

- tipi di Storage Account;
- servizi disponibili;
- ridondanza;
- endpoint;
- accesso allo Storage Account;
- sicurezza di rete degli endpoint;
- differenza tra disponibilità, durabilità e accessibilità.

## Checkpoint

Prima di proseguire devi saper spiegare:

1. perché uno Storage Account è il contenitore amministrativo dei servizi Storage;
2. differenza generale tra LRS e ZRS;
3. perché un endpoint Storage può essere raggiungibile o meno indipendentemente dai permessi RBAC;
4. perché la scelta della ridondanza dipende dal requisito e non solo dal costo.

---

# 3. Modulo 2 – Configure Azure Blob Storage

## Da svolgere

- Introduction
- Implement Azure Blob Storage
- Create blob containers
- Assign blob access tiers
- Add blob lifecycle management rules
- Determine blob object replication
- Manage blobs
- Determine Blob Storage pricing
- Module assessment
- Summary and resources

## Da saltare oggi

- Exercise – Provide storage for the public website

L'esercizio sul sito pubblico non è prioritario per la UD04: il laboratorio del corso mantiene invece il focus su container privati, identità, SAS e minimo privilegio.

## Concetti da fissare

```text
Storage Account
   ↓
Container
   ↓
Blob
```

```text
Hot / Cool / Archive
→ frequenza di accesso
→ costo di storage
→ costo di accesso/recupero
```

Inoltre:

- lifecycle management;
- object replication;
- gestione dei Blob;
- relazione tra tier e pricing.

---

# 4. Modulo 3 – Configure Azure Storage security

## Da svolgere integralmente

- Introduction
- Review Azure Storage security strategies
- Create shared access signatures
- Identify URI and SAS parameters
- Determine Azure Storage encryption
- Create customer-managed keys
- Apply Azure Storage security best practices
- Exercise: Manage Azure Storage
- Module assessment
- Summary and resources

## Concetti da fissare

### SAS

```text
SAS
=
risorsa
+
permessi
+
intervallo temporale
```

Principio:

```text
solo ciò che serve
+
solo dove serve
+
solo per il tempo necessario
```

### Encryption

Distinguere:

- encryption at rest;
- chiavi gestite dal servizio;
- customer-managed keys.

### Accesso

Non confondere:

```text
RBAC
→ autorizzazioni di un'identità
```

con:

```text
SAS
→ delega temporanea
```

ed:

```text
Account key
→ segreto condiviso molto potente
```

---

# 5. Modulo 4 – Configure Azure Files

Azure Files fa parte della preparazione AZ-104 ma nella UD04 il focus principale rimane Blob Storage.

## Da svolgere

- Introduction
- Compare storage for file shares and blob data
- Manage Azure file shares
- Create file share snapshots
- Implement soft delete for Azure Files
- Use Azure Storage Explorer
- Knowledge check
- Summary and resources

## Da leggere rapidamente

- Consider Azure File Sync

Non è necessario oggi approfondire l'architettura di Azure File Sync.

## Concetti da fissare

### Blob vs Files

```text
Blob Storage
→ object storage
```

```text
Azure Files
→ file share gestita
```

### Protezione dati

- snapshots;
- soft delete;
- recupero.

### Strumenti

- Portale Azure;
- Azure Storage Explorer;
- CLI/AzCopy come strumenti complementari.

---

# 6. Laboratorio di rinforzo – Storage Security & Lifecycle Challenge

## Scenario

Una società deve archiviare documenti di progetto in Azure.

Requisiti:

1. container non pubblico;
2. accesso amministrativo tramite identità;
3. possibilità di condividere temporaneamente un singolo Blob in sola lettura;
4. gestione automatica del ciclo di vita;
5. individuazione delle impostazioni di rete dello Storage Account;
6. confronto tra Blob Storage e Azure Files.

---

## Fase 1 – Verifica Storage Account

Utilizzare lo Storage Account della UD04 oppure crearne uno temporaneo.

Verificare:

- tipo di account;
- regione;
- ridondanza;
- servizi disponibili;
- Networking / endpoint;
- Configuration.

Annotare le impostazioni rilevanti.

---

## Fase 2 – Container privato

Creare:

```text
documents
```

Access level:

```text
Private
```

Caricare almeno un file:

```text
report.txt
```

Verificare che non sia stato configurato accesso anonimo.

---

## Fase 3 – Accesso tramite identità

Verificare quale ruolo dati consente di caricare/modificare Blob tramite Microsoft Entra ID.

Individuare nel portale:

```text
Access control (IAM)
```

e distinguere i ruoli di management dai ruoli del data plane.

---

## Fase 4 – SAS temporanea

Generare una SAS per il solo Blob `report.txt` con:

```text
Permission: Read
Durata: circa 10–15 minuti
```

Non inserire il token completo nelle consegne.

Verificare che la SAS consenta la lettura prevista.

---

## Fase 5 – Lifecycle Management

Creare o esaminare una regola di lifecycle management.

Esempio concettuale:

```text
prefix: documents/archive/
```

Individuare:

```text
scope
+
condition
+
action
```

Non è necessario attendere l'esecuzione della policy.

---

## Fase 6 – Azure Files

Creare una File Share temporanea oppure, se non previsto dal laboratorio operativo, esaminare la procedura nel portale.

Individuare:

- quota;
- snapshot;
- soft delete;
- differenza rispetto a un Blob Container.

---

# 7. Domande di rinforzo

## 1

Un amministratore può configurare lo Storage Account ma non riesce a caricare Blob con la propria identità.

Quale distinzione deve controllare per prima?

A. Hot vs Cool  
B. Management plane vs data plane  
C. LRS vs ZRS  
D. DNS pubblico vs privato

---

## 2

Devi concedere accesso in sola lettura a un singolo Blob per 15 minuti.

Quale soluzione è più appropriata?

A. Account key  
B. Owner sulla subscription  
C. SAS limitata  
D. Container pubblico

---

## 3

Devi aumentare la resilienza rispetto al guasto di una singola Availability Zone mantenendo i dati nella stessa regione.

A. LRS  
B. ZRS  
C. Archive  
D. SAS

---

## 4

Quale funzionalità permette di spostare o eliminare automaticamente Blob in base a condizioni temporali?

A. RBAC  
B. Lifecycle Management  
C. NSG  
D. Resource Lock

---

## 5

Quale servizio è più adatto quando un'applicazione richiede una file share gestita anziché object storage?

A. Azure Blob Storage  
B. Azure Files  
C. Azure Policy  
D. Azure DNS

---

## 6

Una SAS con permessi Read/Write/Delete valida per un anno è richiesta per leggere un singolo Blob per pochi minuti.

Quale principio viene violato?

A. Availability Zone  
B. Least privilege  
C. DNS resolution  
D. Object replication

---

## 7

Qual è il principale vantaggio dello snapshot di una Azure File Share?

A. Aumenta automaticamente la banda  
B. Crea un punto nel tempo utile per recupero  
C. Converte la share in Blob Storage  
D. Sostituisce RBAC

---

## 8

Una regola Lifecycle appena creata non ha ancora modificato un Blob.

Questo significa necessariamente che la configurazione è errata?

A. Sì  
B. No

---

# 8. Checklist finale

Al termine devi saper spiegare:

1. Storage Account e servizi associati.
2. LRS vs ZRS.
3. management plane vs data plane.
4. Blob Container vs Azure File Share.
5. Hot/Cool/Archive.
6. SAS vs account key vs Entra ID/RBAC.
7. lifecycle management.
8. object replication.
9. encryption e customer-managed keys a livello concettuale.
10. snapshots e soft delete.
11. ruolo di Storage Explorer/AzCopy.
12. perché rete e autorizzazione sono controlli differenti.
