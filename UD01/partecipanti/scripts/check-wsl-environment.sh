#!/usr/bin/env bash

# SCOPO
# Questo script rileva lo stato dell'ambiente Ubuntu eseguito in WSL e genera
# un inventario Markdown. Controlla distribuzione, kernel, cartella corrente,
# Git, Visual Studio Code, Azure CLI, Docker, Python e configurazione
# dell'identità Git.
#
# INPUT
# Il primo argomento, facoltativo, indica il percorso del report. Se non viene
# fornito, il file viene creato in `/tmp/INVENTARIO_WSL_GENERATO.md`, fuori
# dal repository pubblico del corso.
#
# OUTPUT
# Lo script crea un file Markdown con una tabella e stampa nel terminale il
# percorso del file generato.
#
# OPERAZIONI ESEGUITE
# - legge file e versioni già presenti;
# - cerca comandi tramite il PATH;
# - crea, se necessario, la cartella che contiene il report;
# - scrive il report Markdown.
#
# OPERAZIONI NON ESEGUITE
# Lo script non installa, non aggiorna, non rimuove e non configura componenti.
# Non effettua login e non riporta nome o indirizzo e-mail configurati in Git.
# Prima di pubblicare il report è comunque necessario verificarne il contenuto.

# Considera errore l'uso di una variabile che non è stata inizializzata.
# Non viene usato `set -e` perché un comando assente deve essere registrato nel
# report senza interrompere tutti i controlli successivi.
set -u

# Costruisce il percorso predefinito fuori dal repository del corso.
# `/tmp` è adatto a un report diagnostico che non deve essere versionato.
default_report="/tmp/INVENTARIO_WSL_GENERATO.md"

# Usa il primo argomento se presente; `${1:-...}` seleziona il valore predefinito
# quando l'argomento manca oppure è vuoto.
report_path="${1:-$default_report}"

# Definisce una funzione che rende una stringa adatta a una cella Markdown.
sanitize() {
  # `printf` evita interpretazioni aggiuntive, `tr` sostituisce i ritorni a capo
  # con spazi e `sed` protegge il carattere `|` usato come separatore di colonna.
  printf '%s' "$1" | tr '\n\r' '  ' | sed 's/|/\\|/g'
}

# Definisce una funzione che verifica se un comando è raggiungibile tramite il PATH.
command_present() {
  # `command -v` cerca il comando; le redirezioni nascondono output ed errori
  # perché interessa soltanto il codice di uscita vero/falso.
  command -v "$1" >/dev/null 2>&1
}

# Definisce una funzione che esegue un comando e conserva soltanto la prima riga.
first_line() {
  # `"$@"` mantiene separati comando e argomenti, `2>&1` unisce gli errori
  # all'output e `sed -n '1p'` stampa esclusivamente la prima riga.
  "$@" 2>&1 | sed -n '1p'
}

# Imposta un valore predefinito nel caso in cui la distribuzione non sia rilevabile.
distro_label="non rilevata"

# Verifica che il file standard con le informazioni della distribuzione sia leggibile.
if [ -r /etc/os-release ]; then
  # Carica le variabili di `/etc/os-release` in una subshell e stampa PRETTY_NAME;
  # la subshell evita che tali variabili rimangano nell'ambiente dello script.
  distro_label="$(. /etc/os-release && printf '%s' "${PRETTY_NAME:-sconosciuta}")"
fi

# Interroga la versione del kernel; il testo alternativo viene usato se `uname` fallisce.
kernel_label="$(uname -r 2>/dev/null || printf '%s' 'non rilevato')"

# Registra la cartella dalla quale è stato avviato lo script; il controllo servirà
# a riconoscere se il progetto si trova nel filesystem Linux oppure sotto `/mnt/c`.
workspace_label="$(pwd 2>/dev/null || printf '%s' 'non rilevato')"

# Estrae la directory che dovrà contenere il file di report.
report_directory="$(dirname "$report_path")"

# Crea la directory e gli eventuali livelli mancanti senza errore se esiste già.
mkdir -p "$report_directory"

# Apre un gruppo di comandi: tutto ciò che il gruppo stampa verrà scritto nel report.
{
  # Scrive il titolo e due ritorni a capo per separarlo dal contenuto successivo.
  printf '# Inventario WSL generato\n\n'

  # Inserisce data e ora locali di generazione del report.
  printf 'Generato: %s\n\n' "$(date '+%Y-%m-%d %H:%M:%S')"

  # Dichiara esplicitamente che lo script non ha modificato installazioni o versioni.
  printf '> Lo script è diagnostico: non ha installato né aggiornato componenti.\n\n'

  # Scrive l'intestazione della tabella Markdown.
  printf '| Componente | Presente | Versione/stato | Verifica |\n'

  # Scrive la riga di separazione richiesta dalla sintassi delle tabelle Markdown.
  printf '|---|---|---|---|\n'

  # Aggiunge la distribuzione usando la funzione di sanificazione.
  printf '| Ubuntu | Sì | %s | `/etc/os-release` leggibile |\n' "$(sanitize "$distro_label")"

  # Aggiunge la versione del kernel restituita da `uname -r`.
  printf '| Kernel Linux | Sì | %s | `uname -r` riuscito |\n' "$(sanitize "$kernel_label")"

  # Aggiunge la cartella corrente e il criterio da controllare manualmente.
  printf '| Cartella corrente | Sì | `%s` | Controllare che il progetto non sia sotto `/mnt/c` |\n' "$(sanitize "$workspace_label")"

  # Verifica se Git è disponibile nell'ambiente Ubuntu.
  if command_present git; then
    # Esegue il comando di versione e conserva la prima riga.
    git_version="$(first_line git --version)"

    # Aggiunge al report il risultato positivo per Git.
    printf '| Git in Ubuntu | Sì | %s | Comando disponibile |\n' "$(sanitize "$git_version")"
  # Se Git non è raggiungibile, esegue il ramo alternativo.
  else
    # Registra l'assenza di Git senza tentare installazioni.
    printf '| Git in Ubuntu | No | non rilevata | Nessuna modifica eseguita |\n'
  fi

  # Controlla se il comando `code` è visibile da WSL e se risponde correttamente.
  if command_present code && code_output="$(code --version 2>&1)"; then
    # Estrae la prima riga, che normalmente contiene la versione di VS Code.
    code_version="$(printf '%s\n' "$code_output" | sed -n '1p')"

    # Registra il comando funzionante e ricorda che `code .` è il test completo.
    printf '| Visual Studio Code da WSL | Sì | %s | Verificare anche `code .` |\n' "$(sanitize "$code_version")"
  # Se `code` esiste ma il comando di versione è fallito, conserva l'errore.
  elif command_present code; then
    # Esegue nuovamente il comando per conservare la prima riga dell'errore.
    code_error="$(code --version 2>&1 | sed -n '1p')"

    # Distingue un comando presente ma non funzionante da un comando assente.
    printf '| Visual Studio Code da WSL | Parziale | %s | Comando visibile ma non funzionale |\n' "$(sanitize "$code_error")"
  # Se `code` non è presente, esegue il ramo che registra l'assenza.
  else
    # Registra l'assenza del comando `code` nel contesto WSL.
    printf '| Visual Studio Code da WSL | No | non rilevata | Controllare installazione Windows e PATH |\n'
  fi

  # Verifica se Azure CLI è disponibile nell'ambiente Ubuntu.
  if command_present az; then
    # Prova a estrarre direttamente la versione `azure-cli`; se la query fallisce,
    # usa come alternativa la prima riga del comando completo `az version`.
    azure_version="$(az version --query '"azure-cli"' --output tsv 2>/dev/null || first_line az version)"

    # Aggiunge la versione rilevata alla tabella.
    printf '| Azure CLI | Sì | %s | Comando disponibile |\n' "$(sanitize "$azure_version")"
  # Se Azure CLI non è raggiungibile, esegue il ramo alternativo.
  else
    # Registra l'assenza di Azure CLI senza installarla.
    printf '| Azure CLI | No | non rilevata | Nessuna modifica eseguita |\n'
  fi

  # Rileva Docker soltanto per preparare la successiva unità dedicata ai container.
  if command_present docker; then
    # Legge la prima riga del comando di versione di Docker.
    docker_version="$(first_line docker --version)"

    # Registra la versione senza eseguire container o modificare Docker.
    printf '| Docker CLI | Sì | %s | Rilevazione soltanto nell’UD01 |\n' "$(sanitize "$docker_version")"
  # Se Docker non è raggiungibile, esegue il ramo alternativo.
  else
    # Registra che l'installazione verrà valutata nella UD dedicata a Docker.
    printf '| Docker CLI | No | non rilevata | Installazione rinviata alla UD dedicata a Docker |\n'
  fi

  # Rileva Python perché verrà utilizzato dall'applicazione Catalogo prodotti.
  if command_present python3; then
    # Legge la prima riga del comando di versione di Python.
    python_version="$(first_line python3 --version)"

    # Registra la versione senza installare pacchetti Python.
    printf '| Python 3 | Sì | %s | Rilevazione soltanto |\n' "$(sanitize "$python_version")"
  # Se Python 3 non è raggiungibile, esegue il ramo alternativo.
  else
    # Registra l'assenza rinviando la valutazione all'unità sull'applicazione.
    printf '| Python 3 | No | non rilevata | Valutazione rinviata al Catalogo prodotti |\n'
  fi

  # Controlla se è configurato un nome autore globale senza leggerne il valore nel report.
  if git config --global --get user.name >/dev/null 2>&1; then
    # Memorizza soltanto lo stato configurato, non il nome reale.
    git_name_state="configurato"
  # Se il nome autore non è configurato, esegue il ramo alternativo.
  else
    # Memorizza lo stato mancante quando la chiave non esiste.
    git_name_state="mancante"
  fi

  # Controlla se è configurato un indirizzo e-mail globale senza riportarlo.
  if git config --global --get user.email >/dev/null 2>&1; then
    # Memorizza soltanto lo stato configurato, non l'indirizzo reale.
    git_email_state="configurata"
  # Se l'e-mail autore non è configurata, esegue il ramo alternativo.
  else
    # Memorizza lo stato mancante quando la chiave non esiste.
    git_email_state="mancante"
  fi

  # Verifica con due condizioni che nome ed e-mail siano entrambi configurati.
  if [ "$git_name_state" = "configurato" ] && [ "$git_email_state" = "configurata" ]; then
    # Imposta lo stato complessivo positivo quando entrambe le chiavi esistono.
    git_identity_present="Sì"
  # Se manca almeno una chiave dell'identità Git, registra lo stato parziale.
  else
    # Imposta lo stato parziale quando manca almeno una delle due chiavi.
    git_identity_present="Parziale"
  fi

  # Aggiunge lo stato dell'identità Git senza esporre i valori configurati.
  printf '| Identità Git | %s | nome: %s; e-mail: %s | I valori non vengono riportati per privacy |\n' "$git_identity_present" "$git_name_state" "$git_email_state"

  # Inserisce una riga vuota e il titolo della valutazione manuale.
  printf '\n## Valutazione da completare\n\n'

  # Aggiunge il campo per elencare i componenti già compatibili.
  printf -- '- Componenti compatibili senza intervento:\n'

  # Aggiunge il campo per elencare i componenti assenti.
  printf -- '- Componenti assenti:\n'

  # Aggiunge il campo per gli aggiornamenti motivati dai requisiti.
  printf -- '- Aggiornamenti realmente necessari:\n'

  # Aggiunge il campo per i problemi che richiedono diagnosi.
  printf -- '- Problemi funzionali da diagnosticare:\n'

# Redirige in una sola operazione tutto l'output del gruppo verso il file del report.
} > "$report_path"

# Comunica nel terminale il percorso completo del report appena scritto.
printf 'Inventario scritto in: %s\n' "$report_path"

# Ricorda che il report deve essere controllato prima della pubblicazione.
printf 'Controllare e ripulire il contenuto prima di pubblicarlo.\n'
