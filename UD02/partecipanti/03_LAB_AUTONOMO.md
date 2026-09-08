# Laboratorio autonomo — Tradurre requisiti in un ambiente Azure verificabile

## Risultato atteso

Partendo da requisiti descritti in linguaggio naturale, creerai un ambiente Azure temporaneo, ne verificherai struttura e proprietà attraverso portale e CLI, documenterai le decisioni e completerai il cleanup senza dipendere da indicazioni esterne.

Tempo previsto: **55 minuti**.

## Scenario

Un gruppo di sviluppo deve provare un componente che richiede una rete isolata e uno spazio di archiviazione vuoto. L'ambiente è destinato allo sviluppo, deve rimanere separato dagli altri laboratori e deve poter essere eliminato come un'unica unità.

I requisiti sono:

- resource group dedicato nella località già verificata;
- nome del resource group con prefisso `rg-cea-ud02-auto-`;
- VNet `vnet-cea-auto` con spazio `10.30.0.0/16`;
- subnet `snet-workload` con spazio `10.30.10.0/24`;
- storage account `StorageV2`, `Standard_LRS`, HTTPS obbligatorio, TLS minimo 1.2 e accesso Blob pubblico disabilitato;
- tag `course=cloud-engineer-academy`, `unit=UD02`, `environment=dev`, `scenario=autonomous` e `deleteAfter` entro due giorni;
- nessuna chiave, token o identificativo della sottoscrizione nei file;
- eliminazione completa al termine.

## Pianificazione prima della creazione

Nel repository personale crea:

```bash
code consegne/UD02/02_LAB_AUTONOMO.md
```

Prima di eseguire comandi, scrivi un breve paragrafo che motivi:

- il resource group come confine del ciclo di vita;
- la località scelta;
- la differenza fra VNet e storage account;
- il motivo dei tag;
- il criterio con cui dimostrerai il cleanup.

Non creare un'intestazione separata per ogni punto: costruisci una nota tecnica leggibile.

## Vincoli operativi

Usa Azure CLI per la creazione. Usa Azure Portal per una seconda verifica indipendente. Puoi riprendere le strutture dei comandi da `02_LAB_GUIDATO.md`, ma devi sostituire nomi, indirizzi e tag con quelli richiesti dallo scenario.

Prima della creazione devi mostrare nel terminale:

```bash
az account show \
  --query "{Name:name,State:state,IsDefault:isDefault}" \
  --output table
```

Non continuare se lo stato non è `Enabled` o se la sottoscrizione non è quella prevista.

Genera un nuovo suffisso che non modifichi le variabili del laboratorio guidato:

```bash
AUTO_SUFFIX="$(date +%s%N | sha256sum | cut -c1-8)"
AUTO_RG="rg-cea-ud02-auto-${AUTO_SUFFIX}"
AUTO_VNET="vnet-cea-auto"
AUTO_SUBNET="snet-workload"
AUTO_STORAGE="stceaauto${AUTO_SUFFIX}"
AUTO_DELETE_AFTER="$(date -d '+2 days' +%F)"
```

La località può essere recuperata dal file già versionato:

```bash
source consegne/UD02/01_VARIABILI_LAB.sh
AUTO_LOCATION="$LAB_LOCATION"
```

Controlla tutti i nomi prima di usarli:

```bash
printf 'Location: %s\nRG: %s\nVNet: %s\nSubnet: %s\nStorage: %s\n' \
  "$AUTO_LOCATION" "$AUTO_RG" "$AUTO_VNET" "$AUTO_SUBNET" "$AUTO_STORAGE"
```

## Criteri di verifica

L'ambiente è corretto soltanto se riesci a dimostrare che:

- il resource group si trova nella località prevista;
- VNet e storage account appartengono allo stesso resource group;
- la VNet contiene la subnet con il prefisso richiesto;
- lo storage account applica HTTPS, TLS 1.2 e public Blob access disabilitato;
- i tag sono presenti sia sulla VNet sia sullo storage account;
- il portale e `az resource list` mostrano lo stesso insieme di risorse;
- gli ID riportati nella relazione sono anonimizzati;
- il resource group non esiste più dopo il cleanup.

Nella relazione inserisci i comandi di verifica e brevi output ripuliti. Non è necessario riportare tutti i messaggi prodotti dalla creazione.

## Recupero degli errori

Se il nome dello storage account non è disponibile, genera soltanto un nuovo valore per `AUTO_STORAGE`:

```bash
AUTO_STORAGE="stceaauto$(date +%s%N | sha256sum | cut -c1-8)"
az storage account check-name --name "$AUTO_STORAGE" --output table
```

Non cambiare `AUTO_RG` dopo aver creato il resource group.

Se una risorsa è stata creata nel resource group errato, non duplicarla immediatamente. Elenca entrambi i gruppi, elimina soltanto la risorsa collocata male dopo averne verificato il nome e ricreala nel gruppo corretto.

Se VNet e subnet non rispettano i prefissi richiesti, controlla:

```bash
az network vnet show \
  --resource-group "$AUTO_RG" \
  --name "$AUTO_VNET" \
  --query "{Address:addressSpace.addressPrefixes,Subnets:subnets[].{Name:name,Prefix:addressPrefix}}" \
  --output jsonc
```

Correggi la configurazione soltanto dopo aver confrontato valore richiesto e valore reale.

Se la sessione termina e le variabili non sono più disponibili, recupera i nomi dal portale o da:

```bash
az group list \
  --query "[?starts_with(name, 'rg-cea-ud02-auto-')].{Name:name,Location:location}" \
  --output table
```

Ricostruisci poi le variabili usando i nomi reali. Non eseguire comandi di eliminazione con variabili vuote.

## Cleanup e conclusione

Prima dell'eliminazione completa la relazione e verifica il nome:

```bash
printf 'Resource group autonomo da eliminare: %s\n' "$AUTO_RG"
```

Elimina, attendi e controlla:

```bash
az group delete --name "$AUTO_RG" --yes --no-wait
az group wait --name "$AUTO_RG" --deleted
az group exists --name "$AUTO_RG"
```

Il risultato finale deve essere `false`. Aggiorna `consegne/UD02/02_LAB_AUTONOMO.md` con l'esito, quindi:

```bash
git status
git diff -- consegne/UD02/02_LAB_AUTONOMO.md
git add consegne/UD02/02_LAB_AUTONOMO.md
git status
git commit -m "Completa lo scenario Azure autonomo"
git push
```

Il laboratorio è concluso quando il file è presente su GitHub, il commit contiene soltanto materiale intenzionale e il resource group non esiste più.

## Autovalutazione

Indica `Completato` oppure `Da ripetere`.

| Capacità | Valutazione |
|---|---|
| Traduco requisiti in nomi, tag e risorse | |
| Verifico account e località prima della creazione | |
| Interpreto le proprietà di VNet e storage | |
| Confronto portale e CLI | |
| Anonimizzo gli identificativi | |
| Diagnostico una variabile o un nome errato | |
| Verifico la conclusione del cleanup | |

Per ogni voce `Da ripetere`, torna al controllo corrispondente, eseguilo nuovamente e aggiorna la valutazione soltanto dopo aver ottenuto il risultato previsto.

⏱
