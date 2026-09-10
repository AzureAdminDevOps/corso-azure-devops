# Concetti — Azure Storage

## 1. Lo storage account come confine

Uno storage account fornisce un namespace Azure per servizi dati, configurazioni di rete, autorizzazione, ridondanza e fatturazione. Un account general purpose v2 (`StorageV2`) può esporre Blob, Files, Queue e Table. Il servizio scelto dipende dal modo in cui applicazioni e utenti devono organizzare e utilizzare i dati.

| Servizio | Modello | Scenario tipico |
|---|---|---|
| Blob | oggetti in container | immagini, documenti, log, backup, contenuti applicativi |
| Files | condivisioni e directory SMB/NFS | applicazioni e utenti che richiedono una file share |
| Queue | messaggi semplici | disaccoppiamento tra componenti asincroni |
| Table | entità NoSQL chiave/attributi | dati schemaless con accesso per partizione e chiave |

Blob non è un disco montato e Azure Files non è un database relazionale. La scelta parte dal modello di accesso, non dal solo volume.

## 2. Piano di gestione e piano dati

Creare un account, modificarne la rete o leggere le proprietà sono operazioni del **management plane**, gestite tramite Azure Resource Manager. Caricare, leggere o eliminare un Blob sono operazioni del **data plane**.

Essere Contributor sullo storage account consente di gestire la risorsa, ma non concede automaticamente accesso ai Blob tramite Microsoft Entra ID. Per il piano dati servono ruoli specifici, per esempio Storage Blob Data Reader o Storage Blob Data Contributor. Microsoft chiarisce questa separazione nella [guida all'autorizzazione Blob con Microsoft Entra ID](https://learn.microsoft.com/azure/storage/blobs/authorize-access-azure-active-directory).

## 3. Ridondanza

- **LRS** replica localmente ed è la scelta economica per laboratori e dati ricostruibili.
- **ZRS** replica in zone distinte nella region e protegge da un guasto zonale.
- **GRS** aggiunge replica asincrona in una region secondaria.
- **GZRS** combina ridondanza zonale primaria e replica geografica.
- Le varianti **RA-** consentono lettura dall'endpoint secondario nei casi previsti.

Più copie non equivalgono automaticamente a backup: una cancellazione o modifica logica può essere replicata. Backup, soft delete, versioning e ridondanza affrontano rischi differenti. La [panoramica Microsoft sulla ridondanza](https://learn.microsoft.com/azure/storage/common/storage-redundancy) descrive le opzioni e i compromessi.

## 4. Tier di accesso Blob

Hot, Cool, Cold e Archive bilanciano costo di conservazione, accesso e recupero. In generale, diminuendo la frequenza prevista di accesso diminuisce il costo di conservazione ma aumentano costi o tempi di recupero. Archive è offline e richiede reidratazione.

Non si sceglie Archive soltanto perché un file è “vecchio”: vanno valutati frequenza, tempo massimo di recupero, permanenza minima e costi delle operazioni.

## 5. Endpoint e naming

Il nome dello storage account è globale, lungo 3–24 caratteri, composto da minuscole e numeri. Entra negli endpoint, per esempio:

```text
https://<account>.blob.core.windows.net/<container>/<blob>
https://<account>.file.core.windows.net/<share>/<path>
```

Un endpoint corretto non garantisce accesso: la richiesta deve anche superare rete e autorizzazione.

## 6. Accesso anonimo, Microsoft Entra ID, chiavi e SAS

L'accesso pubblico anonimo non è necessario nei laboratori e rimane disabilitato.

Microsoft Entra ID usa l'identità autenticata e ruoli RBAC del piano dati. È il metodo preferito per utenti e applicazioni Azure moderne perché evita la distribuzione di una chiave condivisa.

Le account key concedono un accesso molto ampio. Sono segreti ad alto impatto: chi possiede una chiave può operare sui dati secondo le capacità dell'account. Vanno protette, ruotate e, quando possibile, sostituite da identità.

Una Shared Access Signature delega operazioni, risorsa e durata mediante un token nell'URL. Una SAS deve avere:

- permessi minimi;
- scope più ristretto possibile;
- scadenza breve;
- trasporto HTTPS;
- nessuna pubblicazione in repository o screenshot.

Una **user delegation SAS** è firmata usando credenziali Microsoft Entra ed è preferibile a SAS firmate con account key quando applicabile. La [panoramica SAS](https://learn.microsoft.com/azure/storage/common/storage-sas-overview) distingue i tipi e i relativi rischi.

## 7. Sicurezza di base

Trasferimento sicuro obbligatorio, TLS minimo supportato, accesso pubblico disabilitato e RBAC minimo sono controlli di partenza. Firewall, private endpoint e disabilitazione Shared Key richiedono una progettazione coerente con applicazioni e rete; non vanno attivati casualmente durante un laboratorio.

Soft delete e versioning proteggono da cancellazioni o sovrascritture, ma possono aumentare lo spazio fatturato. Ogni controllo ha effetto operativo e costo.

## 8. Lifecycle management

Una policy lifecycle contiene regole JSON che selezionano Blob per tipo, prefisso o tag e applicano azioni basate sull'età, come passaggio a un tier meno costoso o eliminazione. Non è un job immediato: l'elaborazione può iniziare dopo ore.

Le regole devono evitare filtri troppo ampi. Nel laboratorio useremo il prefisso `temporary/`, così la policy non riguarda l'intero account. Microsoft documenta struttura e limiti nella [panoramica lifecycle](https://learn.microsoft.com/azure/storage/blobs/lifecycle-management-overview).

## 9. Costi e cleanup

Il costo dipende da capacità, ridondanza, tier, operazioni, recupero e trasferimento. Un account vuoto può comunque essere oggetto di operazioni; un laboratorio deve mantenere file piccoli e rimuovere account, ruoli e token temporanei.

⏱

## 10. Domande di controllo

Inserisci le risposte motivate in `consegne/UD04/00_DOMANDE_CONCETTI.md`.

1. Perché Azure Blob e Azure Files non sono intercambiabili?
2. Qual è la differenza tra management plane e data plane?
3. Perché Contributor sullo storage account non implica accesso Blob con Entra ID?
4. Perché geo-ridondanza e backup risolvono problemi diversi?
5. Quali fattori valuteresti prima di scegliere Archive?
6. Perché una account key ha un impatto maggiore di una SAS limitata?
7. Quali proprietà rendono una SAS coerente con il minimo privilegio?
8. Perché non possiamo verificare una policy lifecycle aspettando pochi minuti?

⏱
