# Laboratorio autonomo — Verificare e documentare l'ambiente

## Risultato atteso

Senza modificare installazioni o configurazioni di sistema, dovrai verificare il contesto di lavoro, creare una nota tecnica, controllare con Git soltanto i file richiesti e pubblicare il risultato nel repository personale.

Tempo previsto: **35 minuti**.

Al termine devono essere presenti:

```text
azure-devops-lab/
├── evidenze/
│   └── UD01.md
└── laboratori/
    └── UD01/
        ├── nota-operativa.md
        └── verifica-autonoma.md
```

## Rileva il contesto

In PowerShell esegui:

```powershell
wsl --list --verbose
```

Registra nel file `verifica-autonoma.md` il nome della distribuzione e il valore della colonna `VERSION`, senza riportare il nome dell'utente o del computer.

Apri Ubuntu e raggiungi il repository personale:

```bash
cd ~/workspace/azure-devops-lab
pwd
git rev-parse --show-toplevel
git status
git remote -v
```

I primi due percorsi devono riferirsi allo stesso repository nel filesystem Linux. `git remote -v` deve mostrare il repository `azure-devops-lab` associato al tuo account GitHub.

Dal browser apri **Settings → Collaborators** e verifica che `<USERNAME_GITHUB_DOCENTE>` risulti come invito pendente o collaboratore attivo. Registra soltanto lo stato nel file autonomo; non inserire e-mail o screenshot della pagina.

Se `git rev-parse` restituisce `not a git repository`, individua il repository senza modificare file:

```bash
find ~/workspace -maxdepth 3 -type d -name .git -print
```

Ogni risultato rappresenta la cartella `.git` interna a un repository. Rimuovi `/.git` dal percorso visualizzato e usa `cd` per entrare nella relativa cartella di progetto. Ripeti quindi i controlli iniziali.

## Crea la verifica autonoma

Crea il file con Visual Studio Code:

```bash
code laboratori/UD01/verifica-autonoma.md
```

Scrivi un testo breve che includa naturalmente:

- la prova che Ubuntu utilizza WSL 2;
- il percorso Linux del repository;
- l'URL del remote senza token o parametri riservati;
- la differenza tra working tree, staging area, commit locale e repository remoto;
- il controllo usato per verificare Azure CLI;
- lo stato verificato dell'invito al docente;
- un possibile errore di contesto e il comando che permette di riconoscerlo.

Non creare una sezione separata per ogni punto. Il documento deve essere leggibile come una nota tecnica destinata a chi deve riprodurre la verifica.

## Controlla le modifiche

Esegui:

```bash
git status --short
git diff -- laboratori/UD01/verifica-autonoma.md
```

`git status --short` deve mostrare il nuovo file con `??`. Il secondo comando può non visualizzare contenuto perché Git non include normalmente i file non tracciati nel diff. Aggiungi quindi soltanto il file richiesto:

```bash
git add laboratori/UD01/verifica-autonoma.md
git status --short
git diff --cached -- laboratori/UD01/verifica-autonoma.md
```

Ora lo stato deve mostrare `A` e il diff con `--cached` deve visualizzare il testo destinato al commit. Se compaiono altri file in staging, rimuovili dalla staging area senza cancellarli:

```bash
git restore --staged <PERCORSO_FILE_NON_RICHIESTO>
git status --short
```

## Pubblica e verifica

Quando la staging area contiene soltanto `verifica-autonoma.md`, esegui:

```bash
git commit -m "Documenta la verifica autonoma dell'ambiente"
git push
git log -1 --oneline
git status
```

Apri la pagina GitHub del repository e verifica che il commit e il file siano visibili. Il laboratorio è concluso soltanto quando:

- `git log -1 --oneline` mostra il commit appena creato;
- la pagina GitHub mostra lo stesso messaggio e lo stesso hash abbreviato;
- `git status` non segnala modifiche inattese;
- il file pubblicato non contiene informazioni riservate.

## Recupero degli errori

Se `git push` restituisce `Repository not found`, esegui:

```bash
git remote -v
```

Confronta l'URL con quello copiato dalla pagina GitHub. Se è errato, correggilo e verifica il nuovo valore:

```bash
git remote set-url origin "https://github.com/<USERNAME_GITHUB>/azure-devops-lab.git"
git remote -v
git push
```

Se compare una richiesta di username e password, interrompila con `Ctrl+C` e controlla Git Credential Manager:

```bash
git config --global --get credential.helper
```

Il valore deve corrispondere al helper configurato nel laboratorio guidato. Ripeti `git push` per riaprire il flusso di autenticazione nel browser.

Se GitHub non mostra il nuovo commit ma `git commit` è riuscito, confronta:

```bash
git status -sb
git log -1 --oneline
git remote -v
```

La dicitura `ahead 1` indica che il commit esiste localmente ma non è stato ancora inviato. Esegui `git push` e ripeti il confronto.

## Autovalutazione

Assegna a ogni capacità `Completato` oppure `Da ripetere`:

| Capacità | Valutazione |
|---|---|
| Distinguo PowerShell dal terminale Ubuntu | |
| Verifico che Ubuntu utilizzi WSL 2 | |
| Riconosco la radice del repository Git | |
| Verifico il remote prima del push | |
| Distinguo file non tracciato e file in staging | |
| Inserisco in staging soltanto il file richiesto | |
| Verifico lo stesso commit in locale e su GitHub | |
| Verifico lo stato dell'invito al docente | |
| Riconosco ed escludo dati riservati | |

Per ogni voce `Da ripetere`, torna alla sezione che contiene il relativo controllo, ripeti i comandi e aggiorna la valutazione soltanto dopo aver ottenuto l'output atteso.

⏱
