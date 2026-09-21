# UD11 — Laboratorio autonomo
## Troubleshooting ingress/target port

## Prerequisito e ripristino del contesto

Il Resource Group della UD11 deve essere ancora presente.

Il LAB autonomo non dipende dal fatto che la stessa shell del LAB guidato sia rimasta aperta. Reimpostiamo quindi le variabili essenziali:

```bash
export LAB_RG="rg-ud11-containers"
export ACA_APP="catalog-api-ud11"
```

Verificare il contesto Azure:

```bash
az account show \
  --query "{Subscription:name,User:user.name}" \
  --output table
```

Recuperare nuovamente il FQDN dalla risorsa:

```bash
export ACA_FQDN=$(az containerapp show \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --query properties.configuration.ingress.fqdn \
  --output tsv)
```

Verificare:

```bash
echo "$ACA_FQDN"
```

La Container App deve rispondere con:

```text
version = v2
```

---

# 1. Baseline

```bash
curl -fsS "https://$ACA_FQDN/health" \
  | python3 -m json.tool
```

Registrare:

```text
status:
version:
```

---

# 2. Baseline ingress

```bash
az containerapp ingress show \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --query "{External:external,TargetPort:targetPort,FQDN:fqdn}" \
  --output table
```

Atteso:

```text
TargetPort = 8000
```

---

# 3. Introdurre errore controllato

Impostare target port errato:

```bash
az containerapp ingress update \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --target-port 9999 \
  --output none
```

---

# 4. Osservare sintomo

```bash
curl -i \
  --max-time 20 \
  "https://$ACA_FQDN/health"
```

Non correggere subito.

Registrare:

```text
HTTP status / timeout:
```

---

# 5. Verificare stato app

```bash
az containerapp show \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --query "{State:properties.runningStatus,FQDN:properties.configuration.ingress.fqdn}" \
  --output table
```

---

# 6. Revision

```bash
az containerapp revision list \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --query "[].{
    Name:name,
    Active:properties.active,
    Health:properties.healthState
  }" \
  --output table
```

---

# 7. Log applicativi

```bash
az containerapp logs show \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --tail 30
```

Domanda:

```text
Il backend risulta avviato su quale porta?
```

---

# 8. Ingress config

```bash
az containerapp ingress show \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --query "{External:external,TargetPort:targetPort}" \
  --output table
```

Confrontare:

```text
backend listen port
vs
ingress target port
```

---

# 9. Diagnosi

Compilare:

```text
Sintomo:
Risultato atteso:
Evidenza:
Ipotesi:
Causa:
Correzione minima:
```

---

# 10. Correzione

```bash
az containerapp ingress update \
  --name "$ACA_APP" \
  --resource-group "$LAB_RG" \
  --target-port 8000 \
  --output none
```

---

# 11. Verifica

Attendere alcuni secondi perché la modifica dell'ingress venga applicata, quindi eseguire:

```bash
curl -fsS "https://$ACA_FQDN/health" \
  | python3 -m json.tool
```

Se la piattaforma sta ancora applicando la modifica, attendere 5–10 secondi e ripetere **lo stesso comando**.

Atteso:

```text
status = ok
version = v2
```

---

# 12. Domande

1. Era necessario creare una nuova image?
2. Era necessario fare push di v3?
3. Il problema era ACR, managed identity o ingress?
4. Quale evidenza ha identificato la causa?
5. Perché modificare più impostazioni contemporaneamente sarebbe stato un errore metodologico?

---


# 13. Conservare le risorse fino alla verifica individuale

Il problema è stato corretto e la Container App deve essere nuovamente raggiungibile con `targetPort=8000`.

**Non eliminare ancora il Resource Group.**

La verifica individuale usa lo scenario appena osservato per ragionare su:

- ACR;
- managed identity;
- revision;
- ingress;
- target port;
- troubleshooting.

Passare quindi a:

```text
04_VERIFICA.md
```

Il cleanup completo della UD11 è riportato alla fine della verifica.
