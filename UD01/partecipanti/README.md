# UD01 — Preparazione dell'ambiente e metodo di lavoro

In questa unità prepareremo l'ambiente che useremo durante tutto il percorso. Non installeremo strumenti in modo automatico o indiscriminato: prima osserveremo ciò che è già presente, poi interverremo soltanto dove serve.

La postazione finale sarà composta da Windows come sistema host, WSL 2 con Ubuntu come ambiente Linux, Visual Studio Code come banco di lavoro, Git come sistema di versionamento locale, GitHub per materiali e consegne e Azure Portal/Azure CLI per le successive attività cloud.

## Come utilizzare i materiali

| Fascia | Attività |
|---|---|
| 09:00–11:00 | `00_CONCETTI.md`, sezione **1**: panoramica delle 120 ore, strumenti, applicazione trasversale, metodo, repository ed evidenze. Le domande conclusive vengono svolte prima della pausa. |
| 11:15–11:40 | `00_CONCETTI.md`, sezioni **2–7**, **12** e **13**: ambiente Windows/WSL, shell, file, percorsi, Markdown e criterio per installare o aggiornare uno strumento. |
| 11:40–12:10 | `00_CONCETTI.md`, sezioni **2–10**, **12** e **13**: applicazione guidata dei concetti alla catena PowerShell → Ubuntu → VS Code/WSL → GitHub → Azure. |
| 12:10–13:00 | `02_LAB_GUIDATO.md`, sezioni **1–3**, con `docs/INVENTARIO_AMBIENTE.md` e, quando indicato, `scripts/check-windows-environment.ps1`: rilevazione di Windows, WSL e Ubuntu e preparazione di `~/workspace`. |
| 14:00–14:25 | `00_CONCETTI.md`, sezione **8**, e `02_LAB_GUIDATO.md`, sezione **4**: verifica funzionale di Visual Studio Code collegato a WSL. |
| 14:25–15:15 | `00_CONCETTI.md`, sezione **9**, e `02_LAB_GUIDATO.md`, sezioni **5–6**: Git in Ubuntu, identità dell'autore e autenticazione GitHub. |
| 15:15–16:00 | `00_CONCETTI.md`, sezione **10**; `02_LAB_GUIDATO.md`, sezione **7**; `GUIDA_PARTECIPANTE_GITHUB_COLLABORATORE.md`, sezione **Aggiornamento dei materiali del corso**: clone e verifica del repository pubblico. |
| 16:15–16:40 | `GUIDA_PARTECIPANTE_GITHUB_COLLABORATORE.md`, dall'inizio a **Preparazione della struttura locale**, poi `02_LAB_GUIDATO.md`, sezioni **8–11**: repository personale, collaboratore, struttura iniziale e preparazione della prima evidenza. |
| 16:40–17:00 | `02_LAB_GUIDATO.md`, sezioni **12–13**, con `scripts/check-wsl-environment.sh` e `docs/TEMPLATE_EVIDENCE.md`: verifica Azure, inventario finale e pubblicazione dell'evidenza. |
| 17:00–17:35 | `03_LAB_AUTONOMO.md`: verifica e documentazione autonoma dell'ambiente. |
| 17:35–17:55 | `04_VERIFICA.md`: quesiti e prova pratica individuale. |
| 17:55–18:00 | Questo `README.md`, sezione **Criterio di completamento**: controllo conclusivo dei risultati. |

## Ordine dei materiali

Non leggere tutti i file integralmente prima di iniziare. Segui questo ordine:

1. leggi questo `README.md` per conoscere sequenza, materiali e risultato finale;
2. studia la sezione **1** di `00_CONCETTI.md` e rispondi alle domande sulla panoramica;
3. studia le sezioni **2–7**, **12** e **13** di `00_CONCETTI.md` e segui l'applicazione guidata proposta durante la spiegazione;
4. esegui le sezioni **1–3** di `02_LAB_GUIDATO.md`, usando `docs/INVENTARIO_AMBIENTE.md` come traccia e lo script Windows soltanto quando la procedura lo richiede;
5. prima di ogni successiva parte pratica, leggi il richiamo concettuale indicato nella tabella precedente e svolgi le sezioni **4–7** del laboratorio guidato;
6. usa `GUIDA_PARTECIPANTE_GITHUB_COLLABORATORE.md` come procedura principale per creare il repository personale, invitare il docente, clonare il repository e preparare la struttura locale; torna poi alle sezioni **8–11** del laboratorio per verificarne il risultato e creare la prima evidenza;
7. completa le sezioni **12–13** del laboratorio guidato; esegui `scripts/check-wsl-environment.sh` una sola volta, nel punto indicato, e riporta nel repository personale soltanto le informazioni richieste da `docs/TEMPLATE_EVIDENCE.md`;
8. svolgi integralmente `03_LAB_AUTONOMO.md` applicando in autonomia i controlli già studiati;
9. completa `04_VERIFICA.md` e infine controlla il criterio di completamento riportato sotto.

`GUIDA_PARTECIPANTE_GITHUB_COLLABORATORE.md` resta il riferimento GitHub per tutte le UD successive. I file nella cartella `docs` sono modelli: non modificarli nella copia del repository pubblico. Gli script nella cartella `scripts` sono materiale da leggere prima dell'esecuzione e raccolgono informazioni diagnostiche senza installare o aggiornare componenti.

## Regola di sicurezza

Nel repository non devono comparire password, token, chiavi, stringhe di connessione, file `.env`, codici temporanei di autenticazione o schermate che li contengano. Prima di pubblicare un output, controlla anche la presenza di indirizzi e-mail, nomi completi, ID della sottoscrizione e percorsi che contengono il nome dell'utente Windows.

## Criterio di completamento

L'unità è completata quando il repository personale contiene:

```text
azure-devops-lab/
├── README.md
├── evidenze/
│   └── UD01.md
└── laboratori/
    └── UD01/
        ├── nota-operativa.md
        └── verifica-autonoma.md
```

I file devono essere presenti anche su GitHub e il commit finale deve essere visibile dalla pagina del repository.
In **Settings → Collaborators** deve inoltre risultare l'invito inviato allo username GitHub comunicato dal docente; lo stato può essere ancora pendente se l'accettazione non è stata completata.
