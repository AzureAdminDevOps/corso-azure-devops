# Verifica — Preparazione dell'ambiente e metodo di lavoro

Tempo consigliato: **20 minuti**. Rispondi senza eseguire nuove installazioni. Quando una domanda richiede un comando, scrivi anche che cosa ti aspetti di osservare.

## Parte A — Scelte operative

### 1

In PowerShell `git --version` restituisce `2.53.0`, mentre nel terminale Ubuntu restituisce `2.43.0`. Qual è la spiegazione più corretta?

A. Una delle due installazioni è necessariamente danneggiata.  
B. Windows e Ubuntu possono possedere installazioni distinte di Git.  
C. WSL converte automaticamente la versione Linux in quella Windows.  
D. GitHub decide quale versione visualizzare.

### 2

Quale comando mostra se la distribuzione Ubuntu sta usando WSL 1 o WSL 2?

A. `wsl --version`  
B. `uname -r`  
C. `wsl --list --verbose`  
D. `cat /etc/os-release`

### 3

Perché il progetto viene conservato in `~/workspace`?

A. Per impedire a Windows di leggere i file.  
B. Perché Git funziona soltanto nella home Linux.  
C. Per lavorare nel file system Linux, più adatto al successivo workflow con Docker e bind mount.  
D. Perché `/mnt/c` non è mai accessibile da WSL.

### 4

Git è presente e la sua versione è compatibile. Qual è l'azione corretta?

A. Reinstallarlo comunque per rendere uguali tutte le postazioni.  
B. Rimuoverlo e installare sempre l'ultima versione disponibile.  
C. Verificarne il funzionamento e proseguire senza reinstallazione.  
D. Installare una seconda copia nella stessa distribuzione.

### 5

Dopo `git commit` la pagina GitHub non mostra la modifica. Quale spiegazione è più probabile?

A. Il commit esiste localmente, ma non è ancora stato eseguito `git push`.  
B. `git commit` elimina sempre il remote.  
C. GitHub aggiorna i repository soltanto una volta al giorno.  
D. È obbligatorio reinstallare Git.

### 6

Qual è il controllo più diretto per capire quali file entreranno nel prossimo commit?

A. `git status` dopo `git add`  
B. `pwd`  
C. `az account show`  
D. `wsl --status`

### 7

Durante `az login --use-device-code` il terminale mostra un codice temporaneo. Che cosa devi fare?

A. Inserirlo nel README per dimostrare il login.  
B. Condividerlo con il gruppo per accelerare il laboratorio.  
C. Usarlo nella pagina di autenticazione e non conservarlo nel repository.  
D. Trasformarlo in una variabile Git.

### 8

Quale indizio dimostra meglio che VS Code sta operando dentro Ubuntu?

A. Il tema scuro dell'editor.  
B. L'indicatore `WSL: Ubuntu` e un terminale con percorso Linux.  
C. La presenza del browser Edge.  
D. Il file possiede estensione `.md`.

### 9

Perché il docente deve essere aggiunto come collaboratore al repository personale pubblico?

A. Perché senza invito non può visualizzare un repository pubblico.  
B. Per ricevere la password GitHub del partecipante.  
C. Per partecipare alle attività di scrittura, revisione e collaborazione previste dal percorso.  
D. Per diventare proprietario dell'account del partecipante.

## Parte B — Risposte brevi

### 10

Spiega in non più di quattro righe la differenza fra Git e GitHub.

### 11

Scrivi la sequenza minima di comandi che useresti per osservare le modifiche, preparare un singolo file, creare un commit e inviarlo al remote.

### 12

Si propone di eseguire immediatamente `wsl --update` su tutte le postazioni. Quali due controlli devono precedere la decisione?

### 13

Il comando `code .` apre VS Code, ma il terminale integrato mostra un percorso `C:\Users\...`. Quale problema sospetti e quale verifica esegui?

### 14

Hai pubblicato per errore un vero token in un commit e poi hai cancellato la riga con un secondo commit. Perché il problema non è risolto?

## Parte C — Prova pratica

Nel repository personale:

1. aggiungi in fondo a `laboratori/UD01/nota-operativa.md` una frase che descriva il comando più utile incontrato nell'unità;
2. usa `git diff` per controllare la modifica;
3. prepara soltanto quel file;
4. crea un commit con un messaggio descrittivo;
5. esegui il push;
6. confronta `git log -1 --oneline` con il commit nella pagina GitHub e annota se hash e messaggio coincidono.

La prova è riuscita se sai spiegare l'effetto di ciascun comando, non soltanto se il file compare su GitHub.

⏱
