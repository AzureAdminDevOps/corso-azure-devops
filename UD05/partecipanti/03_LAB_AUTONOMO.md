# Laboratorio autonomo — Diagnosticare una regola incoerente

## Scenario

Il team segnala che il livello web non potrebbe collegarsi al database TCP 5432. La VNet e le subnet sono corrette; devi analizzare NSG, priorità, associazione e route senza attribuire il problema a un'applicazione che non è ancora stata distribuita.

Compila `consegne/UD05/02_LAB_AUTONOMO.md`.

## Attività

1. Ricostruisci VNet, subnet, prefissi, NIC e associazioni usando portale e CLI.
2. Aggiungi temporaneamente una regola `Deny-Web-Postgres-Auto` con priorità 250, stessa origine e porta della regola Allow.
3. Ordina le regole per priorità e determina quale corrisponde per prima.
4. Verifica gli NSG effettivi su `nic-data-01` e le route effettive.
5. Spiega perché l'assenza di una VM impedisce un test IP Flow Verify completo, ma non impedisce di individuare il conflitto di regole.
6. Rimuovi soltanto la regola autonoma e dimostra che la regola Allow torna a essere la prima regola personalizzata corrispondente.
7. Analizza separatamente questi sintomi:

```text
InvalidAddressPrefix
SecurityRuleConflict
un nome DNS non viene risolto
la porta risulta filtrata da un NSG
```

Per ciascuno indica livello, controllo e correzione minima.

## Struttura del comando di guasto

```bash
az network nsg rule create \
  --resource-group "$LAB_RG" \
  --nsg-name "$LAB_NSG" \
  --name Deny-Web-Postgres-Auto \
  --priority 250 \
  --direction Inbound \
  --access Deny \
  --protocol Tcp \
  --source-address-prefixes 10.50.10.0/24 \
  --destination-address-prefixes '*' \
  --destination-port-ranges 5432
```

## Criteri di completamento

- inventario completo e anonimizzato;
- priorità valutate correttamente;
- distinzione tra deduzione e test reale;
- regola autonoma rimossa;
- diagnosi separate per CIDR, regole, DNS e filtro;
- cleanup del laboratorio guidato previsto soltanto nella sezione finale.

## Controllo della consegna

Prima di terminare verifica e prepara soltanto il file del laboratorio autonomo:

```bash
git diff -- consegne/UD05/02_LAB_AUTONOMO.md
git add consegne/UD05/02_LAB_AUTONOMO.md
git diff --cached -- consegne/UD05/02_LAB_AUTONOMO.md
```

⏱
