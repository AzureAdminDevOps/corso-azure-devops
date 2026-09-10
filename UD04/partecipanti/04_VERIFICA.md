# Verifica — Azure Storage

Compila `consegne/UD04/03_VERIFICA.md`. Al termine controlla il file con `git diff`, aggiungi alla staging area soltanto questa consegna e verifica il risultato con `git diff --cached`.

## Parte A — Scelta singola

1. Quale servizio è più adatto a immagini applicative accessibili come oggetti HTTP?
   - A. Blob
   - B. Files
   - C. Queue
   - D. Table
2. Quale servizio offre condivisioni file SMB gestite?
   - A. Blob
   - B. Files
   - C. Queue
   - D. Table
3. Contributor sullo storage account consente automaticamente lettura Blob via Entra ID?
   - A. Sì, sempre
   - B. No, serve un ruolo del piano dati
   - C. Solo con LRS
   - D. Solo dal portale
4. Quale ridondanza protegge da un guasto zonale nella region primaria?
   - A. LRS
   - B. ZRS
   - C. nessuna replica
   - D. Hot
5. Quale metodo concede un accesso delegato con permessi e scadenza?
   - A. Tag
   - B. SAS
   - C. Lock
   - D. Endpoint
6. Un budget Azure Storage:
   - A. elimina i Blob al raggiungimento della soglia
   - B. cambia automaticamente tier
   - C. segnala una soglia ma non blocca i consumi
   - D. sostituisce lifecycle management
7. Una lifecycle rule con prefisso `documents/temporary/` interessa:
   - A. ogni Blob dell'account
   - B. soltanto Blob che corrispondono al filtro
   - C. tutte le file share
   - D. solo le account key
8. Perché `--auth-mode login` è importante?
   - A. rende esplicito l'uso dell'identità Entra
   - B. rende pubblico il container
   - C. disabilita TLS
   - D. crea una chiave

## Parte B — Risposte brevi

9. Distingui ridondanza e backup.
10. Distingui management plane e data plane con un comando per ciascuno.
11. Elenca quattro proprietà di una SAS a minimo privilegio.
12. Spiega perché Archive non è appropriato per dati da recuperare immediatamente.
13. Perché non bisogna salvare account key o SAS nel repository?

## Parte C — Caso situazionale

Un'applicazione espone documenti privati. Il tecnico assegna Contributor allo storage account, omette `--auth-mode login`, condivide una account key e crea una SAS con permessi completi senza scadenza breve.

14. Individua almeno tre problemi.
15. Proponi autorizzazione e scope più appropriati.
16. Indica come verificheresti accesso e cleanup senza pubblicare segreti.

Controlla e prepara soltanto il file della verifica:

```bash
git diff -- consegne/UD04/03_VERIFICA.md
git add consegne/UD04/03_VERIFICA.md
git diff --cached -- consegne/UD04/03_VERIFICA.md
```

⏱
