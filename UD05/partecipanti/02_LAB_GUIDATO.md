# Laboratorio guidato — Segmentazione, NSG e verifica preventiva

## 1. Verifica ambiente e repository

```bash
cd ~/workspace/azure-devops-lab
git pull --ff-only
mkdir -p consegne/UD05
ls -1 consegne/UD05/*.md
az version --output table
az account show --query "{Subscription:name,State:state}" --output table
```

Se CLI o autenticazione non funzionano, usa la procedura di UD01. Non reinstallare senza verificare presenza, versione e contesto.

## 2. Progetta prima di creare

Compila la sezione **Piano di indirizzamento** di `consegne/UD05/01_LAB_GUIDATO.md` con:

| Elemento | CIDR |
|---|---|
| VNet | `10.50.0.0/16` |
| web | `10.50.10.0/24` |
| data | `10.50.20.0/24` |

Verifica che le subnet siano contenute nella VNet e non si sovrappongano. Nel lavoro reale questo controllo precede il deployment perché correggere indirizzamento dopo l'integrazione può richiedere migrazioni.

## 3. Crea la VNet da CLI

La prima VNet è stata creata dal portale in UD02. Ora la procedura diventa ripetibile:

```bash
LAB_SUFFIX="$(openssl rand -hex 3)"
LAB_RG="rg-cea-network-${LAB_SUFFIX}"
LAB_VNET="vnet-cea-${LAB_SUFFIX}"
LAB_NSG="nsg-data-${LAB_SUFFIX}"
LAB_LOCATION="italynorth"

az group create --name "$LAB_RG" --location "$LAB_LOCATION" \
  --tags course=cloud-engineer-academy unit=UD05 environment=lab --output table

az network vnet create \
  --resource-group "$LAB_RG" \
  --name "$LAB_VNET" \
  --location "$LAB_LOCATION" \
  --address-prefixes 10.50.0.0/16 \
  --subnet-name snet-web \
  --subnet-prefixes 10.50.10.0/24 \
  --output table

az network vnet subnet create \
  --resource-group "$LAB_RG" \
  --vnet-name "$LAB_VNET" \
  --name snet-data \
  --address-prefixes 10.50.20.0/24 \
  --output table
```

⏱

## 4. Crea il primo NSG e la prima regola dal portale

Nel portale cerca **Network security groups → Create**. Usa sottoscrizione verificata, `LAB_RG`, `LAB_NSG` e `LAB_LOCATION`. Nella scheda Tags aggiungi `unit=UD05` ed `environment=lab`, quindi crea.

⏱

Apri l'NSG, seleziona **Inbound security rules → Add** e configura:

| Campo | Valore |
|---|---|
| Source | IP Addresses |
| Source IP/CIDR | `10.50.10.0/24` |
| Source port ranges | `*` |
| Destination | Any |
| Service | Custom |
| Destination port | `5432` |
| Protocol | TCP |
| Action | Allow |
| Priority | `300` |
| Name | `Allow-Web-Postgres` |

La regola consente soltanto il flusso web→data previsto. Non usare `Internet`, tutte le porte o priorità casuali.

Verifica con CLI:

```bash
az network nsg rule show \
  --resource-group "$LAB_RG" \
  --nsg-name "$LAB_NSG" \
  --name Allow-Web-Postgres \
  --query "{Priority:priority,Direction:direction,Access:access,Protocol:protocol,Source:sourceAddressPrefix,Port:destinationPortRange}" \
  --output jsonc
```

## 5. Associa il NSG alla subnet dati dal portale

Nel NSG apri **Subnets → Associate**, seleziona `LAB_VNET` e `snet-data`, poi conferma. L'associazione alla subnet applica la baseline a tutte le NIC che verranno collegate, evitando configurazioni individuali incoerenti.

```bash
az network vnet subnet show \
  --resource-group "$LAB_RG" \
  --vnet-name "$LAB_VNET" \
  --name snet-data \
  --query "{Prefix:addressPrefix,Nsg:networkSecurityGroup.id}" \
  --output jsonc \
  | sed -E 's#/subscriptions/[^/]+#/subscriptions/<omitted>#'
```

## 6. Crea la prima NIC dal portale

Nel portale cerca **Network interfaces → Create**. Crea `nic-data-01` in `LAB_RG` e `LAB_LOCATION`, scegli `LAB_VNET`, subnet `snet-data`, assegnazione IP privato dinamica e nessun public IP. La NIC rappresenta il punto di collegamento di una futura VM; da sola non genera un servizio in ascolto.

Verifica:

```bash
az network nic show \
  --resource-group "$LAB_RG" \
  --name nic-data-01 \
  --query "{PrivateIp:ipConfigurations[0].privateIPAddress,Subnet:ipConfigurations[0].subnet.id,PublicIp:ipConfigurations[0].publicIPAddress}" \
  --output jsonc \
  | sed -E 's#/subscriptions/[^/]+#/subscriptions/<omitted>#'
```

## 7. Crea la NIC successiva da CLI

```bash
az network nic create \
  --resource-group "$LAB_RG" \
  --name nic-web-01 \
  --vnet-name "$LAB_VNET" \
  --subnet snet-web \
  --location "$LAB_LOCATION" \
  --output table
```

Non specifichiamo public IP: il requisito è interno e non esiste ancora un workload da pubblicare.

## 8. Leggi regole e route effettive

```bash
az network nic list-effective-nsg \
  --resource-group "$LAB_RG" \
  --name nic-data-01 \
  --output jsonc

az network nic show-effective-route-table \
  --resource-group "$LAB_RG" \
  --name nic-data-01 \
  --output table
```

L'output deve mostrare l'NSG associato tramite subnet e route di sistema. Non dimostra che un'applicazione risponda: non esiste ancora una VM collegata alla NIC.

## 9. Introduci e correggi un guasto di priorità

Crea da CLI una regola più prioritaria che nega lo stesso flusso:

```bash
az network nsg rule create \
  --resource-group "$LAB_RG" \
  --nsg-name "$LAB_NSG" \
  --name Deny-Web-Postgres \
  --priority 200 \
  --direction Inbound \
  --access Deny \
  --protocol Tcp \
  --source-address-prefixes 10.50.10.0/24 \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 5432 \
  --description "Guasto didattico: nega il flusso previsto" \
  --output table

az network nsg rule list \
  --resource-group "$LAB_RG" \
  --nsg-name "$LAB_NSG" \
  --query "sort_by([].{Priority:priority,Name:name,Access:access,Source:sourceAddressPrefix,Port:destinationPortRange}, &Priority)" \
  --output table
```

La regola 200 viene valutata prima della 300, quindi il flusso sarebbe negato. Correggi rimuovendo esclusivamente la regola di guasto:

```bash
az network nsg rule delete \
  --resource-group "$LAB_RG" \
  --nsg-name "$LAB_NSG" \
  --name Deny-Web-Postgres
```

## 10. Prepara il test reale di UD06

Documenta in `consegne/UD05/01_LAB_GUIDATO.md` il flusso:

```text
10.50.10.0/24:any → 10.50.20.0/24:5432 TCP
```

In UD06 una VM sarà creata per la prima volta dal portale. Solo allora IP Flow Verify o una connessione applicativa potranno associare il risultato a una sorgente reale. Non dichiarare “connettività verificata” in questa UD: dichiara “configurazione e regole effettive verificate”.

⏱

## 11. Cleanup finale

Esegui dopo laboratorio autonomo e verifica:

```bash
az group delete --name "$LAB_RG" --yes --no-wait
az group wait --name "$LAB_RG" --deleted
az group exists --name "$LAB_RG"
```

L'ultimo comando deve restituire `false`. VNet, NSG e NIC non comportano nel laboratorio un costo significativo come una VM, ma il cleanup resta obbligatorio per evitare ambienti abbandonati.

```bash
git add consegne/UD05/00_DOMANDE_CONCETTI.md \
        consegne/UD05/01_LAB_GUIDATO.md \
        consegne/UD05/02_LAB_AUTONOMO.md \
        consegne/UD05/03_VERIFICA.md
git commit -m "Completa laboratorio reti Azure e NSG"
git push
```

⏱
