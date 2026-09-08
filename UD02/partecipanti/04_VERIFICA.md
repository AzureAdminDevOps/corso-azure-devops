# Verifica — Modelli cloud e struttura iniziale di Azure

Tempo consigliato: **25 minuti**. Non creare nuove risorse. Quando una risposta richiede un comando, indica anche quale risultato dovrebbe produrre.

Compila `consegne/UD02/03_VERIFICA.md`. Al termine controlla il file con `git diff`, aggiungi alla staging area soltanto questa consegna e verifica il risultato con `git diff --cached`.

## Parte A — Scelte operative

### 1

Un'applicazione aziendale richiede controllo completo del sistema operativo e installazione di un componente non supportato da un servizio gestito. Quale modello è più coerente?

A. SaaS  
B. IaaS  
C. PaaS senza configurazioni  
D. Soltanto cloud privato

### 2

Usando Azure App Service, quale responsabilità rimane normalmente al cliente?

A. Manutenzione dell'hardware fisico.  
B. Aggiornamento dell'hypervisor.  
C. Configurazione dell'applicazione, identità, accessi e dati.  
D. Alimentazione dei datacenter.

### 3

Quale affermazione descrive correttamente un resource group?

A. È sempre una rete privata.  
B. È il confine fisico di una availability zone.  
C. È un contenitore logico per risorse che possono condividere ciclo di vita e governance.  
D. Sostituisce la sottoscrizione.

### 4

Il resource group si trova in `italynorth`. Quale conclusione è corretta?

A. Tutte le risorse devono obbligatoriamente trovarsi in `italynorth`.  
B. La località indica dove Azure conserva i metadati del resource group; le risorse possono avere località proprie.  
C. Il resource group è automaticamente distribuito in tutte le zone italiane.  
D. La località non viene registrata da Azure.

### 5

Prima di eseguire `az group create`, quale controllo riduce maggiormente il rischio di creare risorse nel contesto sbagliato?

A. `git status`  
B. `az account show`  
C. `pwd`  
D. `docker ps`

### 6

Quale nome è formalmente compatibile con uno storage account Azure?

A. `st-cea-UD02`  
B. `Storage_CEA_02`  
C. `stcea02a7f9`  
D. `st cea 02`

### 7

Un tag `deleteAfter=2026-09-10` è stato applicato a una risorsa. Che cosa accade alla data indicata?

A. Azure elimina sempre automaticamente la risorsa.  
B. Il tag documenta l'intenzione, ma serve ancora una procedura o una policy che esegua l'eliminazione.  
C. La risorsa viene spostata in un'altra region.  
D. Il tag revoca tutte le autorizzazioni.

### 8

Dopo `az group delete --no-wait`, quale controllo dimostra che il cleanup è realmente terminato?

A. Il terminale ha restituito il prompt.  
B. Il comando è presente nella history.  
C. `az group exists --name <NOME>` restituisce `false`.  
D. `git status` non mostra modifiche.

## Parte B — Risposte brevi

### 9

Spiega la differenza tra cloud pubblico, privato e ibrido usando un solo scenario aziendale.

### 10

Descrivi la relazione fra tenant Microsoft Entra, sottoscrizione, resource group e risorsa.

### 11

Perché una availability zone non è sinonimo di region?

### 12

Quale differenza operativa hai osservato tra Azure Portal e Azure CLI?

### 13

Perché i tag devono essere applicati esplicitamente anche alle risorse se sono già presenti sul resource group?

## Parte C — Interpretazione tecnica

Osserva l'output anonimizzato:

```json
{
  "id": "/subscriptions/<omitted>/resourceGroups/rg-cea-test/providers/Microsoft.Storage/storageAccounts/stceatest01",
  "location": "italynorth",
  "name": "stceatest01",
  "tags": {
    "environment": "lab",
    "unit": "UD02"
  },
  "type": "Microsoft.Storage/storageAccounts"
}
```

Scrivi una breve analisi che indichi:

1. sottoscrizione, resource group, provider, tipo e nome riconoscibili nell'ID;
2. località e tag;
3. quale comando useresti per verificare che la risorsa appartenga realmente al resource group;
4. quale operazione useresti per rimuovere l'intero ambiente se il resource group contiene soltanto risorse del laboratorio;
5. quale verifica eseguiresti dopo l'eliminazione.

Controlla e prepara soltanto il file della verifica:

```bash
git diff -- consegne/UD02/03_VERIFICA.md
git add consegne/UD02/03_VERIFICA.md
git diff --cached -- consegne/UD02/03_VERIFICA.md
```

⏱
