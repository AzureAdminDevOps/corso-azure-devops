# Laboratorio guidato — Identità, RBAC, budget e lock

Creerai un resource group temporaneo da CLI perché questa tipologia è già stata introdotta nel portale in UD02. Utente, gruppo, assegnazione RBAC, budget e lock sono invece nuovi: la loro prima configurazione avverrà nel portale e sarà verificata da CLI.

## 1. Prepara repository e contesto

```bash
cd ~/workspace/azure-devops-lab
git pull --ff-only
mkdir -p consegne/UD03
ls -1 consegne/UD03/*.md
az version --output table
az account show --query "{Name:name,State:state,User:user.name}" --output table
```

Se `az` non è disponibile o la sessione non è autenticata, applica il controllo già descritto in UD01. Non reinstallare la CLI senza averne prima verificato presenza e versione.

Genera un suffisso non personale e crea il gruppo temporaneo:

```bash
LAB_SUFFIX="$(openssl rand -hex 3)"
LAB_RG="rg-cea-identity-${LAB_SUFFIX}"
LAB_LOCATION="italynorth"
LAB_DELETE_AFTER="$(date -u -d '+1 day' +%F)"

az group create \
  --name "$LAB_RG" \
  --location "$LAB_LOCATION" \
  --tags course=cloud-engineer-academy unit=UD03 \
         environment=lab deleteAfter="$LAB_DELETE_AFTER" \
  --output table
```

Se `italynorth` non è disponibile, usa una località verificata in UD02. Il gruppo non contiene risorse a consumo: serve come scope isolato per RBAC, budget e lock.

## 2. Determina il percorso Entra senza tentare escalation

Nel portale apri **Microsoft Entra ID → Users → All users** e verifica se **New user** è disponibile. Apri poi **Groups → All groups** e verifica se **New group** è disponibile.

La presenza del pulsante non garantisce che l'operazione sia autorizzata; l'autorizzazione viene valutata al salvataggio. Non attivare trial, non modificare ruoli e non richiedere privilegi aggiuntivi per completare il laboratorio.

| Esito | Percorso |
|---|---|
| Puoi creare e rimuovere utenti e gruppi di sicurezza | A |
| Non puoi creare uno o entrambi gli oggetti | B |

Registra il percorso in `consegne/UD03/01_LAB_GUIDATO.md`.

## 3A. Crea utente e gruppo quando autorizzato

In **Microsoft Entra ID → Users → New user → Create new user**, crea un account cloud temporaneo con alias non personale come `cea-lab-<suffisso>`. Non usare nome, cognome o email reali. Conserva la password temporanea soltanto per il tempo necessario e non inserirla nel repository o negli screenshot.

La creazione di utenti richiede un ruolo amministrativo appropriato; Microsoft indica almeno User Administrator per la procedura standard nella [guida alla creazione ed eliminazione degli utenti](https://learn.microsoft.com/entra/fundamentals/how-to-create-delete-users).

In **Groups → New group** crea un gruppo **Security** con membership **Assigned** e nome `grp-cea-readers-<suffisso>`. Aggiungi l'utente di test come membro. Un gruppo di sicurezza consente di assegnare accesso a un insieme gestibile di principal; la membership dinamica non serve allo scenario e può richiedere licenze ulteriori.

Apri il gruppo e verifica in **Members** la presenza dell'account. In `consegne/UD03/01_LAB_GUIDATO.md` salva soltanto alias anonimizzati, mai object ID o password.

⏱

## 3B. Osserva la directory quando la creazione non è autorizzata

Non ripetere tentativi destinati a fallire. Apri **Users** e **Groups**, annota quali operazioni di lettura sono disponibili e registra la prima riga anonimizzata dell'eventuale messaggio di autorizzazione.

Per il resto del laboratorio userai come principal il tuo account corrente. Questo non dimostra l'effetto di Reader su un'identità priva di altri ruoli, ma permette di eseguire e verificare realmente una role assignment. Nella consegna guidata dovrai distinguere assegnazione creata e accesso effettivo derivante anche da ruoli ereditati.

⏱

## 4. Crea la prima assegnazione RBAC dal portale

Apri il resource group `LAB_RG`, quindi **Access control (IAM) → Add → Add role assignment**. Seleziona **Reader**. Come membro scegli:

- il gruppo `grp-cea-readers-<suffisso>` nel percorso A;
- il tuo account nel percorso B.

Controlla nel riepilogo principal, ruolo e scope, poi crea l'assegnazione. Reader è sufficiente per consultare lo scope e non permette di modificarne le risorse. Lo scope è il singolo resource group: non è necessario concedere il ruolo sull'intera sottoscrizione.

Se **Add role assignment** è disabilitato o l'operazione restituisce `AuthorizationFailed`, documenta l'azione mancante senza cercare di elevare l'account. Per completare il risultato operativo, individua in **Check access** una role assignment già esistente nello stesso resource group e analizzane principal, ruolo e scope. La limitazione deve risultare nell'evidenza.

Verifica da CLI:

```bash
RG_SCOPE="$(az group show --name "$LAB_RG" --query id --output tsv)"

az role assignment list \
  --scope "$RG_SCOPE" \
  --include-inherited \
  --query "[].{Role:roleDefinitionName,PrincipalType:principalType,Scope:scope}" \
  --output table
```

Non usare `--assignee` nell'evidenza pubblicabile: potrebbe mostrare indirizzi o identificativi. Se l'assegnazione appena creata non compare immediatamente, attendi alcuni minuti e ripeti la lettura; la propagazione non è sempre istantanea.

## 5. Analizza l'accesso effettivo

Nel resource group apri **Access control (IAM) → Check access** e seleziona il principal usato. Distingui:

- assegnazione Reader creata nello scope corrente;
- eventuali ruoli ereditati dalla sottoscrizione;
- tipo di principal;
- scope di origine.

Nel percorso B il tuo account potrebbe essere Owner o Contributor per ereditarietà. In tal caso Reader non riduce i permessi già concessi: le assegnazioni consentite si combinano. Questa osservazione è essenziale per non interpretare una singola riga come accesso effettivo completo.

## 6. Osserva Cost Analysis e crea il primo budget

Nel resource group apri **Cost Management → Cost analysis**. Imposta il mese corrente e osserva costo effettivo, eventuale previsione e raggruppamento per servizio. Il gruppo può mostrare zero perché non contiene risorse a consumo e perché i dati hanno tempi di elaborazione.

Apri **Budgets → Add** e configura:

| Campo | Valore didattico |
|---|---|
| Nome | `budget-cea-<suffisso>` |
| Periodo | mensile |
| Importo | un valore basso ma realistico per il laboratorio |
| Soglia | 80% del costo effettivo |
| Destinatario | esclusivamente il tuo indirizzo, se richiesto e se intendi ricevere la notifica |

Leggi il riepilogo prima di creare. Un budget non crea risorse a consumo e non arresta servizi. Se Budgets non è disponibile per tipo di sottoscrizione o autorizzazione, registra l'esito e completa l'analisi usando la schermata guidata senza confermare.

## 7. Crea il primo lock dal portale e osservane l'effetto

Nel resource group apri **Locks → Add**. Crea `lock-cea-delete` di tipo **Delete** (`CanNotDelete`) con una nota che ne dichiari lo scopo temporaneo.

Verifica con CLI:

```bash
az lock list \
  --resource-group "$LAB_RG" \
  --query "[].{Name:name,Level:level,Notes:notes}" \
  --output table
```

Prova a eliminare il gruppo senza `--no-wait`, perché vogliamo leggere l'errore:

```bash
az group delete --name "$LAB_RG" --yes
```

Il criterio di successo è paradossalmente il fallimento dell'eliminazione con un messaggio relativo al lock. Verifica che il gruppo esista ancora:

```bash
az group exists --name "$LAB_RG"
```

Deve restituire `true`. Il lock protegge da eliminazioni accidentali, ma può anche bloccare cleanup e automazioni; per questo va governato e documentato.

## 8. Completa l'evidenza

Compila `consegne/UD03/01_LAB_GUIDATO.md`. Anonimizza gli output:

```bash
az role assignment list \
  --scope "$RG_SCOPE" \
  --include-inherited \
  --query "[].{Role:roleDefinitionName,PrincipalType:principalType,Scope:scope}" \
  --output jsonc \
  | sed -E 's#/subscriptions/[^/]+#/subscriptions/<omitted>#g'
```

Prima del laboratorio autonomo devono risultare documentati percorso Entra, role assignment, accesso effettivo, stato Cost Analysis, budget o limitazione, lock e prova di protezione.

⏱

## 9. Cleanup finale verificato

Esegui questa sezione dopo laboratorio autonomo e verifica.

Nel portale elimina il budget temporaneo se è stato creato. In **Access control (IAM) → Role assignments**, rimuovi esclusivamente l'assegnazione Reader creata dal laboratorio; non rimuovere ruoli preesistenti o ereditati.

Il lock è già una tipologia conosciuta, quindi puoi rimuoverlo con CLI:

```bash
LOCK_ID="$(az lock list --resource-group "$LAB_RG" --query "[?name=='lock-cea-delete'].id | [0]" --output tsv)"
test -n "$LOCK_ID" && az lock delete --ids "$LOCK_ID"
az lock list --resource-group "$LAB_RG" --output table
```

Nel percorso A rimuovi prima l'utente dal gruppo, poi elimina gruppo e utente dal portale. Controlla attentamente nomi e suffisso: non eliminare oggetti non creati dal laboratorio.

Elimina infine il resource group:

```bash
az group delete --name "$LAB_RG" --yes --no-wait
az group wait --name "$LAB_RG" --deleted
az group exists --name "$LAB_RG"
```

L'ultimo comando deve restituire `false`. Aggiorna la checklist di cleanup, quindi:

```bash
git status --short
git diff -- consegne/UD03/
git add consegne/UD03/00_DOMANDE_CONCETTI.md \
        consegne/UD03/01_LAB_GUIDATO.md \
        consegne/UD03/02_LAB_AUTONOMO.md \
        consegne/UD03/03_VERIFICA.md
git commit -m "Completa laboratorio identita accessi e governance"
git push
```

⏱

Se non ci sono modifiche da registrare, non creare un commit vuoto: verifica di essere nel repository e di avere salvato i file previsti.
