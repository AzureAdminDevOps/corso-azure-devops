# Laboratorio autonomo — Progettare un accesso minimo e diagnosticabile

## Scenario

Il team FinOps deve consultare costi e risorse di un solo ambiente applicativo, ma non deve modificare risorse né gestire accessi. Il gruppo applicativo deve inoltre essere protetto da eliminazioni accidentali e associato a una soglia di spesa osservabile.

Compila `consegne/UD03/02_LAB_AUTONOMO.md` senza modificare ruoli o oggetti diversi da quelli temporanei già creati nel laboratorio guidato.

## Attività

1. Definisci principal, ruolo e scope che applicheresti al team. Motiva perché non useresti Contributor o Owner.
2. Ricostruisci dal portale e dalla CLI tutte le assegnazioni applicabili al resource group `LAB_RG`, includendo quelle ereditate.
3. Classifica ogni assegnazione come diretta o ereditata e spiega se l'assegnazione Reader temporanea riduce eventuali privilegi più ampi già posseduti.
4. Documenta il budget configurato o, se non disponibile, i campi che sarebbero necessari e la limitazione rilevata.
5. Verifica che il lock impedisca l'eliminazione e che non impedisca una lettura con `az group show`.
6. Analizza i tre casi seguenti indicando causa probabile, controllo e rimedio minimo.

### Caso A

```text
Please run 'az login' to setup account.
```

### Caso B

```text
AuthorizationFailed ... Microsoft.Authorization/roleAssignments/write ...
```

### Caso C

```text
ScopeLocked: The scope is locked and can't be deleted.
```

7. Inserisci una checklist completa di cleanup, senza eseguirla prima della sezione finale del laboratorio guidato.

## Comandi consentiti per la diagnosi

```bash
az account show --output table
az group show --name "$LAB_RG" --output table
az role assignment list --scope "$RG_SCOPE" --include-inherited --output table
az lock list --resource-group "$LAB_RG" --output table
```

Se le variabili non sono più in memoria, recupera il resource group dal portale e ricostruisci:

```bash
LAB_RG="<nome-del-resource-group-UD03>"
RG_SCOPE="$(az group show --name "$LAB_RG" --query id --output tsv)"
```

## Criteri di completamento

Il documento deve contenere:

- una tabella principal–ruolo–scope;
- almeno un'assegnazione diretta e una ereditata, oppure la dichiarazione verificabile che uno dei due tipi non è presente;
- distinzione tra autenticazione, autorizzazione e lock;
- spiegazione corretta del budget;
- output anonimizzati;
- cleanup ordinato e verificabile.

## Controllo della consegna

Prima di terminare verifica e prepara soltanto il file del laboratorio autonomo:

```bash
git diff -- consegne/UD03/02_LAB_AUTONOMO.md
git add consegne/UD03/02_LAB_AUTONOMO.md
git diff --cached -- consegne/UD03/02_LAB_AUTONOMO.md
```

⏱
