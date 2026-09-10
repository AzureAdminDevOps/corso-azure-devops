# soluzioni_UD04

Soluzioni complete delle domande e delle attività con risposta presenti nei materiali partecipante della UD04.

Le sezioni seguono i file della UD nell'ordine di utilizzo.

---

# `README.md`

Il file `README.md` contiene istruzioni operative, ordine dei materiali e consegne richieste.

**Non contiene domande esplicite da risolvere.**

---

# `00_CONCETTI.md`

## Domande di controllo

### 1. Perché Azure Blob e Azure Files non sono intercambiabili?

**Risposta:**  
Blob organizza oggetti in container e usa API/HTTP; Azure Files espone invece condivisioni e gerarchie di file tramite protocolli come SMB. Il modello di accesso richiesto dall'applicazione determina quindi la scelta.

**Nota:**  
Non scegliere il servizio soltanto perché entrambi memorizzano dati:

```text
object storage → Azure Blob
file share     → Azure Files
```

---

### 2. Qual è la differenza tra management plane e data plane?

**Risposta:**  
Il **management plane** configura e amministra la risorsa Azure tramite Azure Resource Manager. Il **data plane** opera invece sui dati contenuti nel servizio.

Esempi:

```text
Management plane
→ creare o leggere le proprietà dello Storage Account

Data plane
→ elencare, leggere, caricare o eliminare Blob
```

**Nota:**  
Le autorizzazioni dei due piani non coincidono automaticamente.

---

### 3. Perché Contributor sullo storage account non implica accesso Blob con Entra ID?

**Risposta:**  
Perché `Contributor` autorizza la gestione della risorsa sul management plane, ma non concede automaticamente i permessi del data plane Blob. Per accedere ai Blob con Microsoft Entra ID serve un ruolo dati appropriato, ad esempio `Storage Blob Data Reader` o `Storage Blob Data Contributor`.

**Nota:**  

```text
Contributor
≠
Storage Blob Data Contributor
```

---

### 4. Perché geo-ridondanza e backup risolvono problemi diversi?

**Risposta:**  
La ridondanza protegge disponibilità e durabilità rispetto a guasti infrastrutturali mantenendo più copie dei dati. Backup, versioning o altri punti di recupero servono invece a ripristinare dati o stati precedenti in caso di errore o cancellazione logica.

**Nota:**  
Una cancellazione può propagarsi alle copie ridondate:

```text
ridondanza ≠ backup
```

---

### 5. Quali fattori valuteresti prima di scegliere Archive?

**Risposta:**  
Frequenza di accesso, latenza di reidratazione, permanenza minima, costo di recupero e compatibilità della ridondanza.

**Nota:**  
Archive non va scelto soltanto perché un file è vecchio o perché il costo di conservazione è inferiore.

---

### 6. Perché una account key ha un impatto maggiore di una SAS limitata?

**Risposta:**  
La account key abilita un accesso molto ampio allo Storage Account. Una SAS può invece limitare servizio o risorsa, operazioni consentite e durata.

**Nota:**  
Una credenziale più ampia produce un impatto maggiore se viene esposta.

---

### 7. Quali proprietà rendono una SAS coerente con il minimo privilegio?

**Risposta:**  
Una SAS coerente con il minimo privilegio deve avere:

- scope ristretto;
- soli permessi necessari;
- scadenza breve;
- uso tramite HTTPS;
- nessuna esposizione del token in repository o screenshot.

Quando applicabile, una user delegation SAS è preferibile a una SAS firmata con account key.

**Nota:**  

```text
cosa posso fare?
+
su quale risorsa?
+
per quanto tempo?
```

---

### 8. Perché non possiamo verificare una policy lifecycle aspettando pochi minuti?

**Risposta:**  
Perché il motore Lifecycle Management opera periodicamente e non è un job sincrono immediato. Nel laboratorio si verifica quindi la configurazione della regola, non l'effetto dopo pochi minuti.

**Nota:**  
La policy può richiedere molte ore prima che l'elaborazione inizi.

---

# `02_LAB_GUIDATO.md`

Il laboratorio guidato contiene procedure operative e verifiche tecniche, ma **non contiene domande esplicite da compilare come quesiti**.

Le soluzioni operative sono già incorporate nei comandi e nei passaggi guidati del file stesso.

I punti concettuali da verificare durante l'esecuzione sono:

```text
Storage Account
→ container privato
→ ruolo Storage Blob Data Contributor
→ --auth-mode login
→ Blob
→ Shared Key
→ SAS
→ Lifecycle Management
```

---

# `03_LAB_AUTONOMO.md`

## Attività 1. Motiva la scelta di Blob rispetto ad Azure Files, Queue e Table.

**Soluzione:**  
Blob è appropriato perché i documenti sono oggetti letti dall'applicazione. Non è richiesta una condivisione SMB/NFS come Azure Files, non serve messaggistica asincrona come Queue e non serve un modello NoSQL chiave/attributi come Table.

**Nota:**  
La scelta dipende dal modello di accesso, non dal fatto generico che "devo salvare dati".

---

## Attività 2. Valuta LRS e ZRS: indica quale useresti in produzione se il requisito comprende resilienza a un guasto zonale e perché il laboratorio usa LRS.

**Soluzione:**  
In produzione userei **ZRS** perché il requisito richiede resilienza rispetto al guasto di una Availability Zone nella regione primaria.

Nel laboratorio viene utilizzato **LRS** perché i dati sono temporanei, ricostruibili e l'obiettivo è contenere costo e complessità.

**Nota:**  

```text
Produzione con resilienza zonale → ZRS
Laboratorio temporaneo           → LRS
```

---

## Attività 3. Crea da CLI un secondo container privato `archive` usando `--auth-mode login`.

**Soluzione:**

```bash
az storage container create \
  --account-name "$LAB_STORAGE" \
  --name archive \
  --auth-mode login \
  --output table
```

**Nota:**  
`--auth-mode login` rende esplicito l'uso dell'identità Microsoft Entra.

---

## Attività 4. Carica una copia di `consegne/UD04/01_DOCUMENTO_LAB.txt` come `current/documento.txt`, quindi verifica nome, tier e dimensione.

**Soluzione:**

```bash
az storage blob upload \
  --account-name "$LAB_STORAGE" \
  --container-name archive \
  --name current/documento.txt \
  --file consegne/UD04/01_DOCUMENTO_LAB.txt \
  --auth-mode login \
  --overwrite \
  --output table
```

Verifica:

```bash
az storage blob list \
  --account-name "$LAB_STORAGE" \
  --container-name archive \
  --auth-mode login \
  --query "[].{Name:name,Tier:properties.blobTier,Bytes:properties.contentLength}" \
  --output table
```

**Nota:**  
La verifica deve mostrare almeno nome, tier e dimensione del Blob.

---

## Attività 5. Progetta una SAS di sola lettura per il singolo Blob con durata massima 15 minuti. Generala, verifica l'accesso e rimuovi immediatamente la variabile; non riportare token o URL.

**Soluzione:**  
La SAS corretta deve usare:

```text
container: archive
Blob: current/documento.txt
permesso: read
durata: massimo 15 minuti
user delegation
autenticazione: Microsoft Entra ID
```

La struttura deve quindi riprendere il comando del laboratorio guidato usando `--permissions r`, `--as-user`, `--auth-mode login` e una scadenza breve.

**Nota:**  
Il token SAS non deve comparire nella relazione, nei commit o negli screenshot.

---

## Attività 6. Analizza questi errori distinguendo piano, causa e controllo:

```text
AuthorizationPermissionMismatch
ResourceNotFound: The specified container does not exist
curl: (22) The requested URL returned error: 403
```

### `AuthorizationPermissionMismatch`

**Soluzione:**  
È tipicamente un problema di **data plane**. Verificare principal, ruolo `Storage Blob Data Contributor`/`Reader`, scope e propagazione della role assignment.

### `ResourceNotFound: The specified container does not exist`

**Soluzione:**  
Controllare Storage Account, nome del container, nome della risorsa e contesto utilizzato. Non è necessariamente un problema di credenziali.

### `curl: (22) The requested URL returned error: 403`

**Soluzione:**  
Controllare scadenza UTC, permesso `r`, risorsa firmata e integrità del token SAS. Non risolvere il problema rigenerando una SAS con permessi completi.

**Nota:**  
Il troubleshooting deve identificare la causa prima di aumentare i privilegi.

---

## Attività 7. Spiega perché la lifecycle rule `documents/temporary/` non si applica a `archive/current/documento.txt`.

**Soluzione:**  
Perché il filtro della regola riguarda il prefisso:

```text
documents/temporary/
```

mentre il Blob autonomo si trova in:

```text
archive/current/documento.txt
```

Il Blob non corrisponde quindi al filtro della lifecycle rule.

**Nota:**  
Una lifecycle rule agisce soltanto sugli oggetti che corrispondono ai filtri configurati.

---

## Attività 8. Elenca driver di costo e cleanup nell'ordine corretto.

**Soluzione:**  
I principali driver di costo sono:

- capacità;
- ridondanza;
- tier;
- transazioni;
- recupero;
- trasferimento.

Il cleanup deve:

1. rimuovere il ruolo temporaneo;
2. eliminare il Resource Group;
3. verificare che il Resource Group non esista più;
4. verificare che token o segreti non siano presenti nei file.

**Nota:**  
Eliminando il Resource Group vengono eliminati Storage Account, container, Blob e policy appartenenti allo scope.

---

# `04_VERIFICA.md`

## Parte A — Scelta singola

### 1. Quale servizio è più adatto a immagini applicative accessibili come oggetti HTTP?

- A. Blob
- B. Files
- C. Queue
- D. Table

**Risposta corretta: A — Blob**

**Motivazione:**  
Blob è object storage ed è adatto a oggetti applicativi accessibili tramite HTTP/API.

---

### 2. Quale servizio offre condivisioni file SMB gestite?

- A. Blob
- B. Files
- C. Queue
- D. Table

**Risposta corretta: B — Files**

**Motivazione:**  
Azure Files offre file share gestite.

---

### 3. Contributor sullo storage account consente automaticamente lettura Blob via Entra ID?

- A. Sì, sempre
- B. No, serve un ruolo del piano dati
- C. Solo con LRS
- D. Solo dal portale

**Risposta corretta: B**

**Motivazione:**  
`Contributor` non concede automaticamente le autorizzazioni del data plane Blob.

---

### 4. Quale ridondanza protegge da un guasto zonale nella region primaria?

- A. LRS
- B. ZRS
- C. nessuna replica
- D. Hot

**Risposta corretta: B — ZRS**

**Motivazione:**  
ZRS replica tra Availability Zone della regione primaria.

---

### 5. Quale metodo concede un accesso delegato con permessi e scadenza?

- A. Tag
- B. SAS
- C. Lock
- D. Endpoint

**Risposta corretta: B — SAS**

**Motivazione:**  
Una SAS permette di delegare accesso limitando permessi e durata.

---

### 6. Un budget Azure Storage:

- A. elimina i Blob al raggiungimento della soglia
- B. cambia automaticamente tier
- C. segnala una soglia ma non blocca i consumi
- D. sostituisce lifecycle management

**Risposta corretta: C**

**Motivazione:**  
Il budget genera segnalazioni ma non costituisce un blocco automatico dei consumi.

---

### 7. Una lifecycle rule con prefisso `documents/temporary/` interessa:

- A. ogni Blob dell'account
- B. soltanto Blob che corrispondono al filtro
- C. tutte le file share
- D. solo le account key

**Risposta corretta: B**

**Motivazione:**  
Il prefisso limita gli oggetti sui quali la regola può agire.

---

### 8. Perché `--auth-mode login` è importante?

- A. rende esplicito l'uso dell'identità Entra
- B. rende pubblico il container
- C. disabilita TLS
- D. crea una chiave

**Risposta corretta: A**

**Motivazione:**  
Il comando usa esplicitamente l'identità Microsoft Entra anziché tentare implicitamente Shared Key.

---

## Parte B — Risposte brevi

### 9. Distingui ridondanza e backup.

**Risposta:**  
La ridondanza protegge disponibilità e durabilità rispetto a guasti fisici; il backup conserva copie o punti di recupero indipendenti per il ripristino logico.

---

### 10. Distingui management plane e data plane con un comando per ciascuno.

**Risposta:**  

Management plane:

```bash
az storage account show
```

Data plane:

```bash
az storage blob list --auth-mode login
```

Il primo legge la risorsa Azure; il secondo legge i dati Blob.

---

### 11. Elenca quattro proprietà di una SAS a minimo privilegio.

**Risposta:**  

- risorsa/scope ristretto;
- permessi minimi;
- scadenza breve;
- HTTPS.

È inoltre corretta la preferenza per una user delegation SAS quando applicabile.

---

### 12. Spiega perché Archive non è appropriato per dati da recuperare immediatamente.

**Risposta:**  
Archive è offline e richiede reidratazione. Latenza e costi di recupero sono quindi incompatibili con un requisito di disponibilità immediata.

---

### 13. Perché non bisogna salvare account key o SAS nel repository?

**Risposta:**  
Perché sono credenziali riutilizzabili. Git conserva cronologia e copie, quindi una semplice cancellazione successiva non garantisce che il segreto non sia più recuperabile.

---

## Parte C — Caso situazionale

> Un'applicazione espone documenti privati. Il tecnico assegna Contributor allo storage account, omette `--auth-mode login`, condivide una account key e crea una SAS con permessi completi senza scadenza breve.

### 14. Individua almeno tre problemi.

**Risposta:**  

- `Contributor` non è un ruolo dati Blob;
- l'omissione di `--auth-mode login` rende ambiguo il metodo di autorizzazione;
- la account key è condivisa ed eccessivamente potente;
- la SAS ha permessi e durata eccessivi.

---

### 15. Proponi autorizzazione e scope più appropriati.

**Risposta:**  
Usare un'identità applicativa con `Storage Blob Data Reader` sul container o sullo scope minimo necessario. Per una delega temporanea, usare una **user delegation SAS** sul singolo Blob con sola lettura e scadenza breve.

---

### 16. Indica come verificheresti accesso e cleanup senza pubblicare segreti.

**Risposta:**  

- usare comandi con `--auth-mode login`;
- controllare soltanto nomi e proprietà non sensibili;
- provare la SAS senza stamparla nella documentazione;
- rimuovere variabili e file temporanei;
- eliminare ruolo temporaneo e Resource Group;
- verificare che le risorse non esistano più;
- verificare che nessun token sia presente nei file.

