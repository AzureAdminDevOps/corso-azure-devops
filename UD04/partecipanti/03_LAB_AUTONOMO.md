# Laboratorio autonomo — Archivio documentale controllato

## Scenario

Un'applicazione deve conservare documenti consultati frequentemente per 30 giorni e file temporanei eliminabili dopo un giorno. Gli utenti applicativi devono leggere i documenti senza ricevere account key. L'accesso pubblico anonimo non è consentito.

Compila `consegne/UD04/02_LAB_AUTONOMO.md` usando l'account del laboratorio guidato.

## Attività

1. Motiva la scelta di Blob rispetto ad Azure Files, Queue e Table.
2. Valuta LRS e ZRS: indica quale useresti in produzione se il requisito comprende resilienza a un guasto zonale e perché il laboratorio usa LRS.
3. Crea da CLI un secondo container privato `archive` usando `--auth-mode login`.
4. Carica una copia di `consegne/UD04/01_DOCUMENTO_LAB.txt` come `current/documento.txt`, quindi verifica nome, tier e dimensione.
5. Progetta una SAS di sola lettura per il singolo Blob con durata massima 15 minuti. Generala, verifica l'accesso e rimuovi immediatamente la variabile; non riportare token o URL.
6. Analizza questi errori distinguendo piano, causa e controllo:

```text
AuthorizationPermissionMismatch
ResourceNotFound: The specified container does not exist
curl: (22) The requested URL returned error: 403
```

7. Spiega perché la lifecycle rule `documents/temporary/` non si applica a `archive/current/documento.txt`.
8. Elenca driver di costo e cleanup nell'ordine corretto.

## Strutture di comando disponibili

```bash
az storage container create --account-name "$LAB_STORAGE" --name archive --auth-mode login
az storage blob upload --account-name "$LAB_STORAGE" --container-name archive --name current/documento.txt --file consegne/UD04/01_DOCUMENTO_LAB.txt --auth-mode login --overwrite
az storage blob list --account-name "$LAB_STORAGE" --container-name archive --auth-mode login --output table
```

Per la SAS riprendi la struttura della sezione 8 del laboratorio guidato cambiando container, Blob e durata. Il documento deve riportare solo configurazione ed esito.

## Criteri di completamento

- scelta del servizio motivata;
- confronto LRS/ZRS corretto;
- container e Blob verificati;
- SAS limitata e non pubblicata;
- tre diagnosi complete;
- relazione tra prefisso e lifecycle corretta;
- cleanup previsto e nessun segreto nel repository.

## Controllo della consegna

Prima di terminare verifica e prepara soltanto il file del laboratorio autonomo:

```bash
git diff -- consegne/UD04/02_LAB_AUTONOMO.md
git add consegne/UD04/02_LAB_AUTONOMO.md
git diff --cached -- consegne/UD04/02_LAB_AUTONOMO.md
```

⏱
