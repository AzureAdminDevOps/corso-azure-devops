# Laboratorio guidato — Costruire e verificare l'ambiente

## Risultato atteso

Completerai l'inventario della postazione, aprirai una cartella Ubuntu con Visual Studio Code, configurerai Git, clonerai il repository del corso, creerai il repository personale, inviterai il docente come collaboratore e pubblicherai la prima evidenza.

Lavora sui passaggi nell'ordine indicato. Quando un controllo restituisce un risultato compatibile, non reinstallare lo strumento. Prima di un riavvio salva i file aperti e annota il punto raggiunto. Se mancano privilegi amministrativi, registra il blocco nell'inventario e prosegui con le attività che non richiedono installazioni.

## 1. Prepara l'inventario senza cambiare il sistema

Apri **PowerShell senza privilegi amministrativi**. Per prima cosa individuiamo la versione di Windows:

```powershell
winver
```

Usa `docs/INVENTARIO_AMBIENTE.md` come traccia dei campi da rilevare, ma non modificarlo nella copia del repository pubblico. In questa fase conserva appunti temporanei; le sole informazioni destinate al repository personale verranno riportate successivamente in `evidenze/UD01.md`. Non annotare nome del computer o dell'utente.

Controlla ora WSL:

```powershell
wsl --status
wsl --version
wsl --list --verbose
```

Non preoccuparti se uno dei comandi fallisce: anche l'errore è un'informazione diagnostica. Confronta il risultato con questa tabella.

| Risultato | Passo successivo |
|---|---|
| WSL presente, Ubuntu presente, colonna `VERSION` uguale a `2` | non reinstallare; passa alla verifica di Ubuntu |
| WSL presente, ma nessuna distribuzione | installa Ubuntu seguendo il punto 2 |
| Ubuntu usa WSL 1 | applica la procedura di backup e conversione descritta nel punto 2 |
| `wsl --version` non mostra i componenti | esegui `wsl --status`, quindi applica la procedura di aggiornamento del punto 2 |
| `wsl` non è riconosciuto | verifica requisiti e installa WSL seguendo il punto 2 |

Se hai ottenuto il pacchetto `UD01` tramite download ZIP, apri prima `partecipanti/scripts/check-windows-environment.ps1` con Visual Studio Code. Leggi la descrizione iniziale e individua parametro, funzioni, condizioni, ciclo, file prodotto e operazioni che lo script dichiara di non eseguire. Raggiungi quindi da PowerShell la cartella estratta e lancia:

```powershell
& ".\partecipanti\scripts\check-windows-environment.ps1" `
  -ReportPath "$env:TEMP\INVENTARIO_WINDOWS_GENERATO.md"
Get-Content "$env:TEMP\INVENTARIO_WINDOWS_GENERATO.md"
```

Se i criteri di esecuzione bloccano lo script, non modificare in modo permanente la policy del computer. Esegui i controlli manuali riportati sopra oppure abilita l'esecuzione soltanto per il processo corrente:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

La modifica vale solo per la finestra PowerShell aperta. In un ambiente aziendale le policy possono essere controllate centralmente: non devono essere aggirate senza autorizzazione.

### Checkpoint

Prima di continuare devi conoscere:

- versione/build di Windows;
- presenza e versione del componente WSL;
- distribuzioni disponibili;
- architettura WSL usata da Ubuntu.

## 2. Installa o correggi WSL soltanto se serve

Salta questa sezione se WSL 2 e Ubuntu sono già funzionanti.

Se WSL è assente, apri **PowerShell come amministratore**. L'elevazione è necessaria perché Windows deve abilitare componenti di sistema e la piattaforma di virtualizzazione.

```powershell
wsl --install
```

Il comando abilita le funzionalità richieste, imposta WSL 2 come predefinito e installa Ubuntu. Segui l'eventuale richiesta di riavvio. Al primo avvio Ubuntu chiederà di creare un utente Linux e una password: questa password è distinta da quella Windows e verrà richiesta da `sudo`.

Se WSL esiste ma manca Ubuntu, verifica prima i nomi disponibili:

```powershell
wsl --list --online
```

Se `Ubuntu-24.04` è presente nell'elenco:

```powershell
wsl --install --distribution Ubuntu-24.04
```

Se `Ubuntu-24.04` non compare, usa `Ubuntu-22.04` quando disponibile. Non installare più distribuzioni senza una necessità: ciascuna possiede file, pacchetti e configurazioni proprie.

Se `wsl --version` non mostra i dettagli oppure la versione è inferiore a 2.1.5, il comando previsto da Microsoft è:

```powershell
wsl --update
```

Ripeti i tre controlli iniziali al termine. Se la distribuzione esistente usa WSL 1, non convertirla automaticamente quando contiene dati importanti. Elenca prima il nome esatto con `wsl --list --verbose`, quindi esporta un backup in una cartella Windows con spazio sufficiente:

```powershell
wsl --export <NOME_DISTRIBUZIONE> "$env:USERPROFILE\Downloads\backup-wsl.tar"
Get-Item "$env:USERPROFILE\Downloads\backup-wsl.tar"
```

Il secondo comando deve mostrare un file esistente con dimensione maggiore di zero. Solo dopo questa verifica esegui la conversione:

```powershell
wsl --set-version <NOME_DISTRIBUZIONE> 2
```

Sostituisci il segnaposto con il nome esatto ottenuto da `wsl --list --verbose`.

I comandi di installazione, elenco, aggiornamento, esportazione e conversione usati in questa sezione sono descritti nella [documentazione ufficiale dei comandi WSL](https://learn.microsoft.com/windows/wsl/basic-commands). Il collegamento è anche il riferimento da ricontrollare se l'interfaccia di WSL cambia in futuro.

## 3. Verifica Ubuntu e prepara la cartella di lavoro

Apri Ubuntu dal menu Start oppure esegui `wsl` in PowerShell. I comandi successivi devono essere eseguiti nella shell Linux.

```bash
cat /etc/os-release
uname -r
whoami
pwd
```

`whoami` serve a riconoscere l'utente Linux, ma non copiarlo nell'evidenza pubblica se coincide con un dato personale. In questa fase non occorre aggiornare l'indice dei pacchetti: `apt-get update` verrà eseguito soltanto nei rami che richiedono realmente un'installazione o un aggiornamento.

Prepara il workspace Linux:

```bash
mkdir -p ~/workspace
cd ~/workspace
pwd
```

L'output deve terminare con `/workspace` e non iniziare con `/mnt/c`.

Lo script Linux non viene ancora eseguito: sarà usato una sola volta nella sezione 13, dopo la configurazione degli strumenti, per produrre l'inventario finale. I controlli manuali di questa sezione servono a comprendere direttamente distribuzione, kernel, utente e percorso.

⏱

## 4. Verifica Visual Studio Code nel contesto corretto

Visual Studio Code deve essere installato sul lato Windows. Controllalo prima in PowerShell:

```powershell
code --version
```

Se il comando funziona, non reinstallare. Apri VS Code e verifica **Help → About** e la presenza dell'estensione **WSL** di Microsoft.

Se VS Code è assente, scarica la versione Stable dal [sito ufficiale di Visual Studio Code](https://code.visualstudio.com/Download). Durante l'installazione seleziona l'aggiunta del comando `code` al `PATH`: in questo modo potremo aprire una cartella direttamente dal terminale. Dopo l'installazione chiudi e riapri PowerShell e Ubuntu, perché i terminali già aperti potrebbero non vedere il nuovo percorso.

L'estensione può essere controllata anche con:

```powershell
code --list-extensions
```

Nell'elenco deve comparire:

```text
ms-vscode-remote.remote-wsl
```

Se manca, installala dalla sezione Extensions di VS Code oppure con:

```powershell
code --install-extension ms-vscode-remote.remote-wsl
```

Torna ora nel terminale Ubuntu:

```bash
cd ~/workspace
mkdir -p verifica-vscode
cd verifica-vscode
code .
```

Al primo avvio VS Code installerà automaticamente un componente server dentro WSL. Attendi il completamento. Nella nuova finestra controlla l'indicatore `WSL: Ubuntu`, quindi apri il terminale integrato e digita:

```bash
pwd
cat /etc/os-release | head
```

Se il percorso è Linux e l'indicatore WSL è presente, la verifica funzionale è riuscita. Puoi chiudere la cartella di prova; non è necessario conservarla nel repository.

### Checkpoint

Il checkpoint è superato quando puoi verificare contemporaneamente:

- una distribuzione Ubuntu con valore `2` in `wsl --list --verbose`;
- una finestra VS Code con indicatore `WSL: Ubuntu`;
- il terminale integrato posizionato in `~/workspace` secondo l'output di `pwd`.

⏱

## 5. Verifica Git dentro Ubuntu

Nel terminale WSL esegui:

```bash
git --version
```

Se Git è assente:

```bash
sudo apt-get update
sudo apt-get install -y git
```

Se è presente, non reinstallarlo. Per il corso serve almeno Git 2.23, versione che ha introdotto `git switch`; Ubuntu 22.04 e 24.04 forniscono normalmente versioni successive. Se il numero fosse inferiore, non aggiungere repository non ufficiali: prova prima l'aggiornamento dal repository Ubuntu configurato.

```bash
sudo apt-get update
sudo apt-get install --only-upgrade -y git
```

Configura l'identità soltanto se non è già corretta:

```bash
git config --global user.name
git config --global user.email
```

Se i valori mancano:

```bash
git config --global user.name "<NOME_VISIBILE>"
git config --global user.email "<EMAIL_GIT_O_NOREPLY>"
git config --global init.defaultBranch main
```

Usa un indirizzo verificato nel tuo account GitHub oppure l'indirizzo `noreply` fornito da GitHub. Non scrivere l'e-mail nell'inventario che pubblicherai.

Controlla valori e origine della configurazione:

```bash
git config --list --show-origin
```

L'opzione `--global` salva i valori nella configurazione dell'utente Ubuntu e li applica ai repository di quell'utente. Un progetto potrà in seguito sovrascriverli con una configurazione locale.

## 6. Prepara l'autenticazione GitHub tramite HTTPS

Apri GitHub nel browser e verifica di poter accedere all'account. Se non possiedi un account, crealo e completa la verifica dell'indirizzo e-mail. È consigliata l'autenticazione a più fattori.

Per evitare di inserire token manualmente useremo HTTPS con Git Credential Manager quando disponibile. Se sul computer è installato Git for Windows, GCM è normalmente incluso. Dal terminale WSL prova:

```bash
git credential-manager --version
```

Se restituisce una versione, il componente è rilevato. Se non viene trovato, controlla in PowerShell `git --version`: Git for Windows include normalmente Git Credential Manager. Se anche Git for Windows è assente, installalo dal [sito ufficiale](https://git-scm.com/download/win) mantenendo Git Credential Manager tra i componenti selezionati. Riapri poi Ubuntu e verifica il percorso dell'eseguibile:

```bash
ls "/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe"
```

Se il file esiste, configura Git in WSL affinché lo utilizzi. Nel valore salvato da Git lo spazio di `Program Files` deve essere protetto con una barra inversa:

```bash
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
git config --global --get credential.helper
```

L'ultimo comando deve restituire il percorso configurato. Il percorso può essere diverso quando Git for Windows è installato in una posizione personalizzata: in quel caso usa il percorso effettivamente verificato con `ls`. Non configurare `credential.helper store`, perché salverebbe le credenziali in chiaro. Questa integrazione è quella indicata nella [guida ufficiale di Git Credential Manager per WSL](https://github.com/git-ecosystem/git-credential-manager/blob/main/docs/wsl.md).

La prima operazione che richiede scrittura su GitHub dovrebbe aprire un flusso di autenticazione nel browser. Completa l'autorizzazione con il tuo account e non condividere codici o schermate.

⏱

## 7. Clona il repository pubblico del corso

Dal browser apri `<URL_REPO_CORSO>`, seleziona **Code → HTTPS** e copia l'indirizzo. Nel terminale WSL:

```bash
cd ~/workspace
git clone "<URL_REPO_CORSO>"
cd corso-azure-devops
git remote -v
git status
```

Se il nome della cartella creato dal clone è differente, usa quello reale. `git remote -v` deve mostrare l'URL del repository del corso per fetch e push; come partecipante userai normalmente soltanto fetch/pull su questo repository.

Esegui:

```bash
git pull --ff-only
```

Se il repository era già aggiornato, Git lo comunicherà senza modificare file. In futuro questo comando recupererà il materiale pubblicato nel repository del corso.

Apri il repository con:

```bash
code .
```

Verifica ancora una volta che VS Code operi in WSL.

⏱

## 8. Crea e prepara il repository personale

Apri `GUIDA_PARTECIPANTE_GITHUB_COLLABORATORE.md` e svolgi, nell'ordine, le sezioni da **Verifica dell'account** a **Preparazione della struttura locale**. Quella guida è la procedura operativa unica per:

- creare `azure-devops-lab` con le impostazioni richieste;
- invitare lo username GitHub comunicato dal docente;
- clonare il repository nella cartella `~/workspace`;
- copiare `.gitignore` e preparare la struttura locale.

Non ripetiamo qui gli stessi passaggi. Al termine torna in questo laboratorio ed esegui nel terminale WSL:

```bash
cd ~/workspace/azure-devops-lab
pwd
git remote -v
git status --short
```

Il percorso deve trovarsi nel filesystem Linux e `origin` deve puntare al repository `azure-devops-lab` del tuo account. Se uno dei due controlli non coincide, usa la sezione **Controlli in caso di errore** della guida prima di continuare.

## 9. Verifica l'invito e prepara l'evidenza

In **Settings → Collaborators** verifica che `<USERNAME_GITHUB_DOCENTE>` risulti come invito pendente o collaboratore attivo. Non ripetere l'invito se è già presente.

Registra soltanto lo stato, senza screenshot contenenti indirizzi e-mail o altri account. Prepara le cartelle e copia il modello dal repository del corso:

```bash
mkdir -p evidenze laboratori/UD01
cp ~/workspace/corso-azure-devops/UD01/partecipanti/docs/TEMPLATE_EVIDENCE.md \
   evidenze/UD01.md
```

Se il nome della cartella del corso è differente, usa il nome reale verificato nella sezione 7. Il modello originale rimane immutato nel repository pubblico; la copia dentro `azure-devops-lab` diventa la tua evidenza.

## 10. Completa la prima evidenza

Apri il repository personale:

```bash
code .
```

Modifica `evidenze/UD01.md`. Inserisci soltanto informazioni tecniche necessarie. Riporta le versioni senza copiare nome utente, host, e-mail, ID della sottoscrizione o codici di autenticazione.

Crea anche `laboratori/UD01/nota-operativa.md` con questo contenuto iniziale:

````markdown
# Nota operativa — UD01

La cartella di lavoro si trova nel filesystem Linux di WSL 2 ed è stata aperta con Visual Studio Code tramite l'estensione WSL.

Il controllo che ha dimostrato il corretto contesto di esecuzione è:

```bash
pwd
```

L'output indicava un percorso interno alla home Linux e non un percorso `/mnt/c`.
````

## 11. Controlla i file destinati al primo commit

Nel terminale integrato:

```bash
git status --short
```

Non creare ancora il commit: l'evidenza verrà completata con la verifica Azure e con l'inventario finale nelle sezioni 12–13. Questo evita di pubblicare due versioni parziali dello stesso documento a pochi minuti di distanza.

Apri i file con VS Code e controlla che non contengano dati sensibili. `.gitignore`, `evidenze/UD01.md` e `laboratori/UD01/nota-operativa.md` saranno pubblicati insieme al termine della sezione 13.

### Checkpoint

Il checkpoint è superato quando repository e remote sono corretti, l'invito al docente risulta pendente o accettato e i tre file destinati al primo commit sono presenti soltanto nel repository personale.

⏱

## 12. Verifica Azure Portal e Azure CLI

Accedi al portale Azure dal browser usando l'account previsto per il corso. Nell'UD01 verifichiamo soltanto l'accesso; non creare risorse.

Nel terminale WSL:

```bash
az version
```

Se Azure CLI è presente, annota la versione. Non confrontarla con un numero fissato nel materiale: Azure CLI viene aggiornata frequentemente e la versione corrente può cambiare. Nell'UD01 la compatibilità viene dimostrata dal funzionamento di `az login` e `az account show`, non dalla coincidenza con una versione specifica.

Se la CLI è presente ma uno dei due controlli funzionali fallisce per incompatibilità della versione, verifica prima la versione disponibile nel repository configurato:

```bash
apt-cache policy azure-cli
```

Aggiorna soltanto Azure CLI, senza eseguire un aggiornamento indiscriminato di tutti i pacchetti:

```bash
sudo apt-get update
sudo apt-get install --only-upgrade -y azure-cli
az version
```

Se il comando non esiste, usa il metodo `apt` ufficiale riportato di seguito. Per evitare l'esecuzione non verificata di uno script remoto, useremo l'installazione esplicita.

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -sLS https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor \
  | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/microsoft.gpg
```

Il primo gruppo prepara HTTPS, certificati, download e firma dei pacchetti. Il secondo importa la chiave Microsoft in formato utilizzabile da `apt`; `chmod` consente al gestore dei pacchetti di leggere la chiave.

Registra quindi il repository corrispondente alla distribuzione:

```bash
AZURE_CLI_DISTRO=$(lsb_release -cs)
echo "Types: deb
URIs: https://packages.microsoft.com/repos/azure-cli/
Suites: ${AZURE_CLI_DISTRO}
Components: main
Architectures: $(dpkg --print-architecture)
Signed-by: /etc/apt/keyrings/microsoft.gpg" \
  | sudo tee /etc/apt/sources.list.d/azure-cli.sources
```

La variabile contiene il nome in codice della distribuzione, per esempio `jammy` o `noble`. Controlla il file prima di installare:

```bash
cat /etc/apt/sources.list.d/azure-cli.sources
```

Completa:

```bash
sudo apt-get update
sudo apt-get install -y azure-cli
az version
```

Questa procedura segue l'[installazione ufficiale di Azure CLI su Ubuntu tramite `apt`](https://learn.microsoft.com/cli/azure/install-azure-cli-linux?view=azure-cli-latest). La pagina elenca anche le distribuzioni supportate e deve essere ricontrollata prima di usare il materiale su una versione di Ubuntu diversa da quelle previste.

Esegui il login con codice dispositivo:

```bash
az login --use-device-code
```

Apri l'indirizzo mostrato, inserisci il codice temporaneo e completa l'accesso. Non fotografare né copiare il codice nel repository.

Verifica infine il contesto Azure:

```bash
az account show --output table
```

Nel file pubblico scrivi soltanto che il comando è riuscito. Non copiare subscription ID o tenant ID.

## 13. Aggiorna l'inventario e chiudi il laboratorio

Nel repository del corso apri `partecipanti/scripts/check-wsl-environment.sh` e individua argomento facoltativo, variabili, funzioni, condizioni e redirezione finale. Verifica dai commenti che lo script non installi né aggiorni componenti. Eseguilo quindi per produrre l'inventario tecnico:

```bash
cd ~/workspace/corso-azure-devops/UD01
chmod +x partecipanti/scripts/check-wsl-environment.sh
./partecipanti/scripts/check-wsl-environment.sh \
  ~/workspace/INVENTARIO_WSL_GENERATO.md
```

Lo script viene eseguito qui una sola volta, dopo la configurazione degli strumenti. Il report completo rimane fuori dai due repository; usalo come supporto e conserva nel repository personale soltanto la versione ripulita e sintetica. Completa `evidenze/UD01.md`, quindi:

```bash
cd ~/workspace/azure-devops-lab
git status
git add .gitignore evidenze/UD01.md laboratori/UD01/nota-operativa.md
git status
git diff --cached --stat
git diff --cached --check
git commit -m "Completa setup ed evidenza dell'UD01"
git push
git log -1 --oneline
```

Apri la pagina GitHub e verifica presenza dei tre file, messaggio e hash del commit e assenza di dati sensibili. Se hai pubblicato un vero segreto, cancellarlo con un commit successivo non è sufficiente: revocalo o ruotalo nel servizio di origine e applica la procedura di rimozione dalla storia Git.

L'unità guidata è conclusa quando il repository remoto contiene l'evidenza aggiornata e sai descrivere come è arrivata dalla cartella locale a GitHub.

⏱
