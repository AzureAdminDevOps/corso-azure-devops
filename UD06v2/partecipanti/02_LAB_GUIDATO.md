# UD06 — Laboratorio guidato

## Obiettivo

Creare e osservare una VM reale, completare il troubleshooting di rete iniziato in UD05, osservare metriche, distribuire una Web App e analizzare scaling, backup e DR.

---

# 1. Login, terminale e variabili

## Dove eseguire i comandi

Tutti i blocchi marcati `bash` di questa UD devono essere eseguiti in:

```text
Windows
  └── WSL2
       └── Ubuntu
            └── Bash
```

salvo quando il materiale indica esplicitamente **Portale Azure**.

Non eseguire questi comandi da PowerShell Windows.

Aprire quindi una shell **Ubuntu/WSL2** e verificare:

```bash
uname -a
az --version
python3 --version
```

## Login Azure

Nella stessa shell WSL2:

```bash
az login
az account show --output table
```

La sessione deve rimanere aperta: le variabili create nei passaggi successivi appartengono a questa shell.

## Variabili fisse della UD

```bash
export LAB_RG="rg-ud06-compute"
export LAB_VM="vm-ud06-linux"
export LAB_VNET="vnet-ud06"
export LAB_SUBNET="snet-vm"
```

## Portarsi nella directory della UD06

Posizionarsi nella cartella che contiene:

```text
partecipanti/
docente/
README.md
```

Esempio, se i materiali sono nel repository del corso:

```bash
cd ~/workspace/corso-azure-devops/UD06
```

Se il percorso è diverso, entrare nella propria cartella `UD06`.

Verificare che lo script sia presente:

```bash
test -f partecipanti/script/select-vm-target.sh \
  && echo "Script regione/size trovato"
```

Output atteso:

```text
Script regione/size trovato
```

## Selezione autonoma di regione e size

Non copiare/incollare un ciclo Bash multi-riga nel terminale.

La logica è già contenuta nel file:

```text
partecipanti/script/select-vm-target.sh
```

Rendere eseguibile lo script:

```bash
chmod +x partecipanti/script/select-vm-target.sh
```

Eseguirlo **dalla shell WSL2 corrente** e acquisire i due valori:

```bash
if read -r LAB_LOCATION LAB_VM_SIZE < <(
  ./partecipanti/script/select-vm-target.sh
); then
  export LAB_LOCATION LAB_VM_SIZE
else
  echo "Selezione regione/size non riuscita: interrompere la creazione della VM."
  exit 1
fi
```

Lo script verifica, nell'ordine:

```text
Size:
1. Standard_B1s
2. Standard_B1ms

Regioni:
1. westeurope
2. northeurope
3. francecentral
4. germanywestcentral
```

Non seleziona automaticamente size più grandi.

Durante l'esecuzione compariranno messaggi simili a:

```text
Verifico Standard_B1s in westeurope...
```

Verificare quindi le variabili:

```bash
echo "Regione selezionata: $LAB_LOCATION"
echo "Size selezionata:    $LAB_VM_SIZE"
```

Esempio di output:

```text
Regione selezionata: westeurope
Size selezionata:    Standard_B1s
```

Questi valori restano disponibili nella **stessa sessione Bash** e devono essere usati in tutti i passaggi successivi della UD.

> Nota tecnica: lo script non tenta di `export`are le variabili nella shell chiamante. Uno script eseguito normalmente gira infatti in un processo figlio. Per questo i valori vengono restituiti dallo script e acquisiti esplicitamente con `read` nella shell corrente.

---

# 2. Chiave SSH

```bash
ssh-keygen -t ed25519 \
  -f ~/.ssh/ud06_azure \
  -C "ud06"
```

Non sovrascrivere chiavi già esistenti.

Chiave pubblica:

```bash
cat ~/.ssh/ud06_azure.pub
```

La chiave privata non deve mai entrare nel repository.

---

# 3. Creare la VM dal Portale

```text
Virtual machines
→ Create
→ Azure virtual machine
```

Impostazioni da utilizzare:

```text
Resource Group: rg-ud06-compute
VM name: vm-ud06-linux
Region: valore visualizzato da `echo "$LAB_LOCATION"`
Image: Ubuntu Server LTS più recente pubblicata da Canonical
Size: valore visualizzato da `echo "$LAB_VM_SIZE"`
Authentication: SSH public key
Username: azureuser
Public inbound ports: None
```

Se nel Portale non compare la combinazione già selezionata da `select-vm-target.sh`, non scegliere una VM più grande a caso. Tornare al passo 1, rieseguire lo script e verificare che la sessione Azure CLI utilizzi la subscription corretta con `az account show --output table`.

Networking:

```text
VNet: vnet-ud06
Subnet: snet-vm
Public IP: sì
Inbound: None
```

Creare la VM.

---

# 4. Inventario da CLI

```bash
az vm show \
  --resource-group "$LAB_RG" \
  --name "$LAB_VM" \
  --show-details \
  --query "{Power:powerState,Private:privateIps,Public:publicIps,Size:hardwareProfile.vmSize}" \
  --output table
```

Registrare:

- image;
- size;
- private IP;
- public IP;
- VNet/subnet;
- OS disk;
- NIC.

---

# 5. Regola SSH minima

Portale:

```text
VM
→ Networking
→ Network settings
→ Create port rule
```

Configurare:

```text
Source: My IP address
TCP 22
Allow
Priority: 300
Name: Allow-SSH-MyIP
```

---

# 6. Collegamento SSH

Tornare alla **stessa shell WSL2** usata al passo 1. Verificare che le variabili siano ancora presenti:

```bash
printf 'RG=%s\nVM=%s\nREGION=%s\nSIZE=%s\n' \
  "$LAB_RG" "$LAB_VM" "$LAB_LOCATION" "$LAB_VM_SIZE"
```

Poi recuperare il Public IP:

```bash
export LAB_VM_IP=$(az vm show \
  --resource-group "$LAB_RG" \
  --name "$LAB_VM" \
  --show-details \
  --query publicIps \
  --output tsv)
```

```bash
ssh -i ~/.ssh/ud06_azure azureuser@"$LAB_VM_IP"
```

Dentro la VM:

```bash
hostname
ip addr
uname -a
df -h
```

---

# 7. Installare Nginx

Dentro la VM:

```bash
sudo apt update
sudo apt install -y nginx
systemctl status nginx --no-pager
curl -I http://localhost
```

Uscire:

```bash
exit
```

---

# 8. Consentire HTTP solo dal proprio IP

Creare:

```text
Source: My IP address
TCP 80
Allow
Priority: 310
Name: Allow-HTTP-MyIP
```

Test:

```bash
curl -I "http://$LAB_VM_IP"
```

Ora il percorso reale è:

```text
client
→ Public IP
→ NSG
→ NIC
→ VM
→ Nginx
```

---

# 9. IP Flow Verify

Portale:

```text
Network Watcher
→ IP flow verify
```

Impostare:

```text
VM: vm-ud06-linux
Direction: Inbound
Protocol: TCP
Local port: 80
Remote IP: proprio IP pubblico
```

Registrare:

- Allow/Deny;
- regola responsabile.

---

# 10. Azure Monitor Metrics

Aprire:

```text
VM
→ Monitoring
→ Metrics
```

Osservare:

```text
Percentage CPU
Network In
Network Out
```

Provare a cambiare:

- time range;
- aggregation;
- metrica.

Annotare:

```text
metrica
valore/tendenza
interpretazione
```

Non confondere questa vista con Log Analytics.

---

# 11. VM Scale Set e autoscaling — configurazione guidata

Questa parte è **analisi/configurazione**. In questa UD non è stato creato un VM Scale Set, quindi i comandi seguenti **non devono essere eseguiti**: servono per leggere una configurazione completa e riconoscerne i parametri.

Esempio di creazione di un profilo Autoscale per un VM Scale Set già esistente:

```bash
az monitor autoscale create \
  --resource-group <RG> \
  --resource <VMSS_NAME> \
  --resource-type Microsoft.Compute/virtualMachineScaleSets \
  --name autoscale \
  --min-count 1 \
  --max-count 3 \
  --count 1
```

e una regola concettuale:

```bash
az monitor autoscale rule create \
  --resource-group <RG> \
  --autoscale-name autoscale \
  --condition "Percentage CPU > 70 avg 5m" \
  --scale out 1
```

Compilare:

```text
min:
default:
max:
metrica:
soglia:
azione:
```

Domanda:

```text
Perché impostare un massimo?
```

Risposta nella consegna.

---

# 12. App Service Plan e Web App

Questa parte utilizza un secondo script fornito nei materiali, perché la selezione del runtime e il fallback sul piano Free F1 richiedono più controlli.

Rimanere nella **stessa shell WSL2** e tornare nella root della UD06:

```bash
cd ~/workspace/corso-azure-devops/UD06
```

Se i materiali sono in un altro percorso, entrare nella propria directory `UD06`.

Verificare:

```bash
test -f partecipanti/script/prepare-appservice.sh \
  && echo "Script App Service trovato"
```

Rendere eseguibile:

```bash
chmod +x partecipanti/script/prepare-appservice.sh
```

Verificare che le variabili necessarie siano ancora presenti:

```bash
printf 'RG=%s\nREGION=%s\n' \
  "$LAB_RG" "$LAB_LOCATION"
```

Eseguire lo script e acquisire i valori nella shell corrente:

```bash
if read -r APP_SERVICE_LIVE WEB_RUNTIME WEB_PLAN WEB_APP < <(
  ./partecipanti/script/prepare-appservice.sh
); then
  export APP_SERVICE_LIVE WEB_RUNTIME WEB_PLAN WEB_APP
else
  echo "Preparazione App Service non riuscita."
  export APP_SERVICE_LIVE="no"
  export WEB_RUNTIME="NONE"
  export WEB_PLAN="NONE"
  export WEB_APP="NONE"
fi
```

Verificare:

```bash
printf 'LIVE=%s\nRUNTIME=%s\nPLAN=%s\nAPP=%s\n' \
  "$APP_SERVICE_LIVE" \
  "$WEB_RUNTIME" \
  "$WEB_PLAN" \
  "$WEB_APP"
```

Lo script applica queste regole in modo autonomo:

```text
1. preferisce un runtime PHP Linux;
2. se PHP non è disponibile, prova Node.js;
3. tenta esclusivamente App Service Plan Free F1;
4. non crea automaticamente tier a pagamento;
5. crea la Web App solo se il piano F1 è stato creato;
6. restituisce APP_SERVICE_LIVE=yes/no alla shell chiamante.
```

Se:

```text
APP_SERVICE_LIVE=yes
```

proseguire con il deployment del paragrafo 13.

Se:

```text
APP_SERVICE_LIVE=no
```

non eseguire i comandi di deployment dei paragrafi 13 e 15. Completare comunque le sezioni di confronto e scaling usando `00_CONCETTI.md`.

---

# 13. Deployment semplice

```bash
mkdir -p ~/ud06-web
cat > ~/ud06-web/index.html <<'HTML'
<!doctype html>
<html lang="it">
<head><meta charset="utf-8"><title>UD06</title></head>
<body>
<h1>UD06 - Azure App Service</h1>
<p>Deployment riuscito.</p>
</body>
</html>
HTML
```

```bash
if [ "$APP_SERVICE_LIVE" = "yes" ]; then
  az webapp deploy \
    --resource-group "$LAB_RG" \
    --name "$WEB_APP" \
    --src-path ~/ud06-web/index.html \
    --type static \
    --target-path index.html \
    --async false \
    --track-status true
fi
```

Recuperare hostname:

```bash
if [ "$APP_SERVICE_LIVE" = "yes" ]; then
  export WEB_HOST=$(az webapp show \
    --resource-group "$LAB_RG" \
    --name "$WEB_APP" \
    --query defaultHostName \
    --output tsv)
  echo "$WEB_HOST"
fi
```

Test, solo in modalità live:

```bash
if [ "$APP_SERVICE_LIVE" = "yes" ]; then
  curl -I "https://$WEB_HOST"
fi
```

---

# 14. Scaling App Service

Se `APP_SERVICE_LIVE=yes`, dal Portale aprire:

```text
Web App
→ Scale up
```

e osservare i tier **senza applicare modifiche**.

Poi aprire:

```text
Web App / App Service Plan
→ Scale out
```

Se `APP_SERVICE_LIVE=no`, usare direttamente la descrizione presente in `00_CONCETTI.md`: la sezione deve essere completata comunque, senza creare un piano a pagamento.

Identificare:

- Manual;
- Azure Monitor Autoscale;
- Automatic Scaling.

**Regola di sicurezza:** durante questa UD non effettuare alcun upgrade del piano App Service e non creare tier a pagamento.

Compilare:

| Modalità | Basata su |
|---|---|
| Manual | |
| Azure Monitor Autoscale | |
| Automatic Scaling | |

---

# 15. Azure Monitor su App Service

Se `APP_SERVICE_LIVE=yes`, aprire:

```text
Web App
→ Monitoring
→ Metrics
```

e osservare almeno:

```text
Requests
Response Time
```

Confrontare con le metriche della VM.

Se `APP_SERVICE_LIVE=no`, annotare nella consegna `App Service Metrics non eseguite: piano Free non disponibile` e proseguire. Questo non blocca il completamento della UD.

---

# 16. Azure Backup — workflow guidato

Non è obbligatorio avviare un backup reale.

Dal portale osservare il percorso:

```text
Virtual machine
→ Backup
```

oppure:

```text
Resiliency
→ Configure protection
```

Identificare:

```text
Recovery Services vault
Backup policy
Schedule
Retention
Recovery point
Backup now
```

Compilare una mini-policy progettuale:

```text
frequenza:
orario:
retention:
motivazione:
```

In questa UD **non abilitare Azure Backup** sulla VM. La parte partecipante si conclude con l'analisi del workflow e la progettazione della policy.

I concetti `backup job` e `recovery point` devono essere riconosciuti dalla schermata/documentazione del servizio, ma non è richiesta la creazione reale di un recovery point.

---

# 17. HA, Backup e DR

Per ciascun requisito indicare la categoria corretta.

### A
"Voglio ridurre l'impatto del guasto di una singola istanza."

### B
"Voglio recuperare il contenuto della VM a uno stato precedente."

### C
"Voglio ripristinare il workload in un'altra regione dopo un grave outage."

Scelte:

```text
High Availability
Backup
Disaster Recovery
```

---

# 18. Azure Site Recovery — lettura architetturale

Schema:

```text
Region A
VM
 |
replica
 |
v
Region B
recovery
```

Concetti:

```text
replication
failover
failback
RPO
RTO
```

Non viene attivata replica cross-region nel laboratorio.

---

# 19. Cleanup

Prima:

```bash
az resource list \
  --resource-group "$LAB_RG" \
  --output table
```

Poi:

```bash
az group delete \
  --name "$LAB_RG" \
  --yes
```

Verificare:

```bash
az group exists --name "$LAB_RG"
```

Risultato atteso:

```text
false
```

Poiché il laboratorio partecipante **non abilita Azure Backup**, il Resource Group deve poter essere eliminato senza procedure aggiuntive legate alla protezione. Se `az group delete` non completa l'eliminazione, verificare con `az resource list --resource-group "$LAB_RG" --output table` quali risorse risultano ancora presenti prima di qualsiasi altra modifica.
