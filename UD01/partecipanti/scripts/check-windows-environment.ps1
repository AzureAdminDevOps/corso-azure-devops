<#
.SYNOPSIS
Rileva lo stato degli strumenti disponibili nell'ambiente Windows e genera un inventario Markdown.

.DESCRIPTION
Lo script controlla Windows, WSL, Visual Studio Code, Git, Git Credential Manager,
Azure CLI e Docker CLI. Per ogni componente registra presenza, versione sintetica
e risultato del controllo. Il report viene scritto per impostazione predefinita
nella cartella temporanea dell'utente Windows, fuori dal repository del corso.

Lo script è esclusivamente diagnostico: non installa programmi, non aggiorna
componenti, non modifica WSL, non esegue login e non cambia configurazioni Git.
L'unica modifica effettuata è la creazione del file Markdown e, se necessario,
della cartella che lo contiene.

.PARAMETER ReportPath
Percorso facoltativo del file Markdown da generare. Se il parametro non viene
specificato, il report viene collocato nella cartella temporanea di Windows.

.OUTPUTS
Un file Markdown con la tabella dell'inventario e due messaggi nel terminale.

.NOTES
Gli output dei comandi vengono ridotti alla prima riga e il carattere `|` viene
protetto per evitare che interrompa la tabella Markdown. Prima di pubblicare il
report è comunque necessario controllare che non contenga dati personali.
#>

# Dichiara il parametro facoltativo che permette di scegliere il file di destinazione.
param(
    # Usa una stringa vuota per riconoscere il caso in cui non viene fornito alcun percorso.
    [string]$ReportPath = ""
)

# Continua l'esecuzione quando un comando esterno restituisce un errore non terminante.
# In questo modo l'inventario può registrare anche componenti assenti o non funzionanti.
$ErrorActionPreference = "Continue"

# Verifica se il parametro è vuoto o contiene soltanto spazi.
if ([string]::IsNullOrWhiteSpace($ReportPath)) {
    # Costruisce il percorso predefinito nella cartella temporanea dell'utente.
    # Il report non modifica così la copia locale del repository pubblico.
    $ReportPath = Join-Path $env:TEMP "INVENTARIO_WINDOWS_GENERATO.md"
}

# Definisce una funzione che esegue un controllo e restituisce soltanto la prima riga utile.
function Get-FirstOutputLine {
    # Dichiara il blocco di istruzioni che la funzione dovrà eseguire.
    param([scriptblock]$Action)

    # Avvia un blocco protetto per trasformare eventuali eccezioni in testo diagnostico.
    try {
        # Esegue il blocco, unisce errori e output standard e converte il risultato in testo.
        $rawOutput = & $Action 2>&1 | Out-String

        # Divide il testo in righe, elimina quelle vuote e seleziona la prima riga disponibile.
        $firstLine = $rawOutput -split "`r?`n" | Where-Object { $_.Trim() -ne "" } | Select-Object -First 1

        # Controlla se il comando non ha prodotto una riga utilizzabile.
        if ([string]::IsNullOrWhiteSpace($firstLine)) {
            # Restituisce un messaggio esplicito al posto di una cella vuota.
            return "nessun output"
        }

        # Rimuove gli spazi esterni e protegge il separatore delle tabelle Markdown.
        return $firstLine.Trim().Replace("|", "\|")
    }
    # Intercetta un'eccezione terminante generata dal comando controllato.
    catch {
        # Restituisce il messaggio di errore proteggendo il carattere `|` per Markdown.
        return "errore: $($_.Exception.Message.Replace("|", "\|"))"
    }
}

# Definisce una funzione che controlla se un comando è raggiungibile tramite il PATH.
function Test-CommandAvailable {
    # Riceve il nome del comando da cercare.
    param([string]$CommandName)

    # Get-Command restituisce il comando se esiste; il confronto produce True oppure False.
    return $null -ne (Get-Command $CommandName -ErrorAction SilentlyContinue)
}

# Legge dal registro le informazioni sulla versione corrente di Windows.
$windowsInfo = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"

# Compone un'etichetta sintetica con edizione, versione e numero di build.
$windowsLabel = "$($windowsInfo.ProductName) - versione $($windowsInfo.DisplayVersion) - build $($windowsInfo.CurrentBuildNumber)"

# Crea un array vuoto che conterrà una riga logica per ciascun componente controllato.
$checks = @()

# Aggiunge all'array il risultato relativo al sistema operativo Windows.
$checks += [pscustomobject]@{
    # Specifica il nome del componente visualizzato nel report.
    Component = "Windows"
    # Windows è presente perché lo script è in esecuzione in PowerShell sul sistema host.
    Present = "Sì"
    # Protegge l'eventuale separatore Markdown contenuto nell'etichetta di versione.
    Version = $windowsLabel.Replace("|", "\|")
    # Descrive il controllo funzionale realmente eseguito.
    Functional = "Informazioni di sistema leggibili"
}

# Controlla se l'eseguibile di WSL è disponibile nel PATH Windows.
if (Test-CommandAvailable "wsl.exe") {
    # Esegue `wsl --version` e conserva soltanto la prima riga utile.
    $wslVersion = Get-FirstOutputLine { wsl.exe --version }

    # Esegue l'elenco delle distribuzioni e converte le righe in una singola cella Markdown.
    $wslList = (wsl.exe --list --verbose 2>&1 | Out-String).Trim().Replace("|", "\|").Replace("`r", " ").Replace("`n", "; ")

    # Aggiunge il risultato positivo del controllo WSL.
    $checks += [pscustomobject]@{
        # Identifica il componente controllato.
        Component = "WSL"
        # Registra che il comando è presente.
        Present = "Sì"
        # Riporta la versione sintetica restituita da WSL.
        Version = $wslVersion
        # Riporta distribuzioni e versione WSL 1/2 come verifica funzionale.
        Functional = $wslList
    }
}
# Gestisce il caso in cui `wsl.exe` non sia disponibile.
else {
    # Aggiunge al report un risultato negativo senza tentare alcuna installazione.
    $checks += [pscustomobject]@{
        # Identifica il componente non trovato.
        Component = "WSL"
        # Registra l'assenza del comando.
        Present = "No"
        # Esplicita che non è stata rilevata una versione.
        Version = "non rilevata"
        # Indica che la decisione di installazione deve essere svolta nella procedura guidata.
        Functional = "Applicare la procedura di verifica e installazione"
    }
}

# Definisce in forma tabellare i comandi Windows da controllare nello stesso modo.
$commandDefinitions = @(
    # Associa l'etichetta VS Code al comando e alla verifica della versione.
    @{ Label = "Visual Studio Code (Windows)"; Name = "code"; Probe = { code --version } },
    # Associa l'etichetta Git al comando e alla verifica della versione.
    @{ Label = "Git (Windows)"; Name = "git"; Probe = { git --version } },
    # Associa Git Credential Manager al relativo comando di versione.
    @{ Label = "Git Credential Manager"; Name = "git-credential-manager"; Probe = { git-credential-manager --version } },
    # Associa Azure CLI al comando che restituisce le versioni dei componenti.
    @{ Label = "Azure CLI (Windows)"; Name = "az"; Probe = { az version } },
    # Rileva Docker senza avviarlo, installarlo o configurarlo.
    @{ Label = "Docker CLI (rilevazione)"; Name = "docker"; Probe = { docker --version } }
)

# Ripete il controllo per ogni definizione presente nell'array precedente.
foreach ($definition in $commandDefinitions) {
    # Verifica se il comando corrente è raggiungibile tramite il PATH.
    if (Test-CommandAvailable $definition.Name) {
        # Aggiunge un risultato positivo e usa la funzione per ottenere la versione sintetica.
        $checks += [pscustomobject]@{
            # Usa l'etichetta leggibile definita nella tabella dei comandi.
            Component = $definition.Label
            # Registra che il comando è presente.
            Present = "Sì"
            # Esegue il blocco Probe e conserva la prima riga significativa.
            Version = Get-FirstOutputLine $definition.Probe
            # Indica che l'eseguibile è stato trovato nel contesto Windows.
            Functional = "Comando disponibile nel PATH Windows"
        }
    }
    # Gestisce il comando non disponibile senza modificare il sistema.
    else {
        # Aggiunge una riga negativa per conservare l'informazione nell'inventario.
        $checks += [pscustomobject]@{
            # Usa la stessa etichetta leggibile del controllo positivo.
            Component = $definition.Label
            # Registra l'assenza del comando.
            Present = "No"
            # Esplicita che non è stata rilevata una versione.
            Version = "non rilevata"
            # Conferma che lo script non ha tentato installazioni o correzioni.
            Functional = "Nessuna modifica eseguita"
        }
    }
}

# Estrae dal percorso del report la cartella che dovrà contenerlo.
$reportDirectory = Split-Path -Parent $ReportPath

# Verifica se la cartella di destinazione non esiste ancora.
if (-not (Test-Path $reportDirectory)) {
    # Crea la cartella e scarta l'oggetto restituito per mantenere pulito il terminale.
    New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null
}

# Crea le righe iniziali del documento Markdown.
$reportLines = @(
    # Titolo del report.
    "# Inventario Windows generato",
    # Riga vuota necessaria alla formattazione Markdown.
    "",
    # Data e ora locali di generazione.
    "Generato: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    # Riga vuota prima dell'avvertenza.
    "",
    # Avvertenza che chiarisce il comportamento non modificativo dello script.
    "> Lo script è diagnostico: non ha installato né aggiornato componenti.",
    # Riga vuota prima della tabella.
    "",
    # Intestazione della tabella Markdown.
    "| Componente | Presente | Versione/stato | Verifica |",
    # Riga di separazione richiesta dalla sintassi Markdown.
    "|---|---|---|---|"
)

# Converte ogni oggetto di controllo in una riga della tabella Markdown.
foreach ($check in $checks) {
    # Interpola le quattro proprietà mantenendo l'ordine delle colonne.
    $reportLines += "| $($check.Component) | $($check.Present) | $($check.Version) | $($check.Functional) |"
}

# Aggiunge le righe finali che dovranno essere completate dopo la lettura del report.
$reportLines += @(
    # Riga vuota dopo la tabella.
    "",
    # Titolo della valutazione manuale.
    "## Valutazione da completare",
    # Riga vuota prima dell'elenco.
    "",
    # Campo per i componenti già compatibili.
    "- Componenti compatibili senza intervento:",
    # Campo per i componenti assenti.
    "- Componenti assenti:",
    # Campo per gli aggiornamenti motivati dai requisiti.
    "- Aggiornamenti realmente necessari:",
    # Campo per i problemi che richiedono diagnosi.
    "- Problemi funzionali da diagnosticare:"
)

# Scrive tutte le righe nel file usando la codifica UTF-8.
Set-Content -Path $ReportPath -Value $reportLines -Encoding utf8

# Comunica nel terminale il percorso esatto del file creato.
Write-Host "Inventario scritto in: $ReportPath"

# Ricorda che la pubblicazione richiede un controllo manuale dei dati contenuti.
Write-Host "Controllare e ripulire il contenuto prima di pubblicarlo."
