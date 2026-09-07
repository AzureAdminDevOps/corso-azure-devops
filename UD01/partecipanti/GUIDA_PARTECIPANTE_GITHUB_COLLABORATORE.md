# Procedura del partecipante — Repository personale e accesso del docente

Questa procedura crea il repository pubblico nel quale conserverai laboratori, codice ed evidenze e aggiunge il docente come collaboratore. Il repository resta di tua proprietà: non devi comunicare password, codici MFA, token o credenziali.

Prima di iniziare devi ricevere dal docente:

| Dato | Valore da comunicare |
|---|---|
| username GitHub docente | `<USERNAME_GITHUB_DOCENTE>` |
| URL repository pubblico | `<URL_REPO_CORSO>` |
| nome repository pubblico | `<NOME_REPO_CORSO>` |

## Verifica dell'account

Accedi a [GitHub](https://github.com/) e apri il tuo profilo. Annota lo username esatto: non coincide necessariamente con il nome visualizzato. Verifica l'indirizzo e-mail dell'account e configura l'autenticazione a più fattori.

Questa verifica serve a creare il repository sotto il proprietario corretto e a fornire al docente un riferimento non ambiguo.

## Creazione del repository personale

Seleziona **New repository** e imposta:

| Campo | Valore |
|---|---|
| Repository name | `azure-devops-lab` |
| Description | `Laboratori ed evidenze del percorso Microsoft Azure e DevOps` |
| Visibility | **Public** |
| Add a README file | selezionato |
| Add .gitignore | nessuno |
| License | nessuna |

Controlla proprietario, nome e visibilità prima di selezionare **Create repository**.

Il repository pubblico è leggibile da chiunque su Internet. Rimane quindi vietato inserirvi password, account key, token SAS, file `.env`, credenziali Azure, subscription ID completi, dati personali o output non ripuliti. L'accesso del docente come collaboratore serve per revisione e collaborazione, non per la semplice lettura.

## Invito del docente

Apri il repository `azure-devops-lab` e seleziona **Settings**. Se la scheda non è visibile, apri il menu del repository e scegli **Settings**.

Nella sezione **Access** seleziona **Collaborators**, quindi **Add people**. Digita:

```text
<USERNAME_GITHUB_DOCENTE>
```

Prima di confermare confronta username, avatar e pagina del profilo con i dati forniti dal docente. Questa verifica evita di concedere accesso a un account omonimo.

Seleziona **Add `<USERNAME_GITHUB_DOCENTE>` to this repository**. GitHub invia un invito; non devi generare né trasmettere credenziali. La procedura è documentata in [Inviting collaborators to a personal repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/repository-access-and-collaboration/inviting-collaborators-to-a-personal-repository).

Torna in **Settings → Collaborators**:

- `Pending invite` indica che GitHub ha inviato l'invito ma il docente non lo ha ancora accettato;
- la presenza del collaboratore senza stato pendente indica che l'accesso è attivo.

Registra soltanto lo stato dell'invito nell'evidenza; non pubblicare screenshot contenenti indirizzi e-mail o altri collaboratori.

Il repository rimane di proprietà del partecipante. Nei repository appartenenti a un account personale, un collaboratore può anche scrivere nel repository; il docente userà questo accesso soltanto per le attività didattiche concordate.

## Clone nella cartella WSL

Apri Ubuntu/WSL. Presenza, versione e identità Git sono già state controllate nelle sezioni 5–6 del laboratorio guidato e non devono essere verificate una seconda volta se terminale e configurazione non sono cambiati. Se stai usando questa guida in modo indipendente o in una sessione diversa, riprendi quei controlli prima del clone.

Clona il repository personale:

```bash
cd ~/workspace
git clone "https://github.com/<USERNAME_PARTECIPANTE>/azure-devops-lab.git"
cd azure-devops-lab
git remote -v
git status
```

Sostituisci `<USERNAME_PARTECIPANTE>` con il tuo username. Entrambe le righe di `git remote -v` devono puntare al tuo repository `azure-devops-lab`; se mostrano il repository del corso o l'account del docente, non proseguire con il push.

## Copia del `.gitignore` e struttura iniziale

Se non hai ancora clonato il repository pubblico:

```bash
cd ~/workspace
git clone "<URL_REPO_CORSO>"
```

Nel repository personale:

```bash
cd ~/workspace/azure-devops-lab
cp ~/workspace/"<NOME_REPO_CORSO>"/.gitignore .gitignore
mkdir -p evidenze laboratori
git status --short
```

Il `.gitignore` evita l'aggiunta accidentale di molti file locali e sensibili comuni, ma non controlla il contenuto dei file ammessi.

Git non registra cartelle vuote. `evidenze` e `laboratori` compariranno nella cronologia quando conterranno i primi documenti.

## Preparazione della struttura locale

Apri la cartella in Visual Studio Code:

```bash
code .
```

Verifica che VS Code indichi WSL e controlla `README.md` e `.gitignore`. Poi:

```bash
git status --short
```

Il `README.md` è già presente nel commit creato da GitHub quando hai inizializzato il repository. `.gitignore` apparirà invece come nuovo file. Non creare ancora un secondo commit: nella UD01 verrà pubblicato insieme alla prima evidenza e alla nota operativa, dopo la verifica Azure e l'inventario finale. Questa scelta evita due commit parziali a pochi minuti di distanza.

La prima operazione di `push` potrà aprire il flusso di autenticazione nel browser. Usa il tuo account e non condividere codici o schermate; la password ordinaria di GitHub non viene usata come password Git HTTPS.

## Aggiornamento dei materiali del corso

Il repository pubblico serve soltanto per ricevere i materiali:

```bash
cd ~/workspace/"<NOME_REPO_CORSO>"
git status
git pull --ff-only
```

Non svolgere gli esercizi nel clone pubblico. Copia nel repository personale i template indicati dalla UD; in questo modo gli aggiornamenti del docente non entrano in conflitto con il tuo lavoro.

## Consegna di una UD

Nel repository personale:

```bash
cd ~/workspace/azure-devops-lab
git status --short
git diff
git add evidenze/UDxx.md laboratori/UDxx/
git diff --cached --stat
git commit -m "Completa attività UDxx"
git push
git log -1 --oneline
```

Sostituisci `UDxx` con l'unità effettiva. Non usare indiscriminatamente `git add .`: indicare i percorsi aiuta a vedere che cosa stai consegnando.

La consegna è completa quando:

- il commit è visibile su GitHub;
- il docente compare tra i collaboratori;
- i file richiesti sono leggibili;
- non sono presenti segreti o identificativi non richiesti;
- il cleanup delle risorse temporanee è stato verificato.

## Controlli in caso di errore

| Problema | Verifica | Correzione |
|---|---|---|
| il docente non vede il repository | Settings → Collaborators | controlla username e stato dell'invito |
| `Repository not found` durante clone/push | `git remote -v` e accesso nel browser | correggi l'URL o completa l'autenticazione |
| Git richiede una password | credential helper configurato in UD01 | usa il flusso browser, non la password dell'account |
| push rifiutato `non-fast-forward` | `git status` e cronologia remota | non usare `--force`; sincronizza e analizza le modifiche |
| file non aggiunto | `git check-ignore -v <percorso>` | verifica la regola; non forzare un file sensibile |

## Verifica conclusiva

- account e username verificati;
- repository `azure-devops-lab` pubblico;
- `origin` collegato al repository personale;
- docente invitato con username esatto;
- stato dell'invito controllato;
- `.gitignore` presente;
- primo commit e push visibili;
- materiali del corso e consegne conservati in repository distinti;
- nessuna credenziale o informazione riservata nella cronologia.
