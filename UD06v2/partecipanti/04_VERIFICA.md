# UD06 — Verifica individuale

## Parte A — Scelta singola

### 1. Quale componente collega normalmente una VM Azure alla subnet?

- A. NIC
- B. Backup policy
- C. App Service Plan
- D. Recovery point

### 2. Quale tecnologia gestisce un insieme di VM e può supportare autoscaling?

- A. Availability Set
- B. VM Scale Set
- C. Recovery Services vault
- D. Log Analytics workspace

### 3. Passare da 2 a 4 istanze è:

- A. scale up
- B. scale out
- C. failback
- D. deallocate

### 4. Quale elemento definisce capacità e tier di una Web App?

- A. App Service Plan
- B. NSG
- C. Recovery point
- D. NIC

### 5. Azure Monitor Autoscale può usare:

- A. soltanto nomi DNS
- B. metriche e regole
- C. soltanto backup policy
- D. account key

### 6. Quale affermazione è corretta?

- A. Metrics e Logs sono sinonimi
- B. Metrics rappresentano valori numerici nel tempo; Logs sono record interrogabili
- C. Log Analytics è un NSG
- D. Azure Monitor è un backup

### 7. Quale risorsa è centrale nel workflow tradizionale di Azure Backup per VM?

- A. Recovery Services vault
- B. VNet
- C. Load Balancer
- D. App Service Plan

### 8. Azure Site Recovery è principalmente associato a:

- A. tagging
- B. Disaster Recovery
- C. object storage
- D. DNS

---

## Parte B — Risposte brevi

### 9. Distingui Availability Zone, Availability Set e VM Scale Set.

### 10. Distingui scale up e scale out.

### 11. Distingui App Service Autoscale e Automatic Scaling.

### 12. Distingui High Availability, Backup e Disaster Recovery.

### 13. Spiega Recovery Services vault, backup policy e recovery point.

### 14. Distingui RPO e RTO.

---

## Parte C — Caso situazionale

> Una VM Linux è Running. Nginx risponde a `curl localhost`. La VM ha un Public IP. Nell'NSG:
>
> - `Deny-HTTP` priority 100, TCP 80, sorgente My IP, Deny
> - `Allow-HTTP` priority 300, TCP 80, sorgente My IP, Allow
>
> La richiesta HTTP esterna fallisce.

### 15. Qual è la causa più probabile e perché?

### 16. Qual è la correzione minima e quali verifiche useresti per dimostrare il ripristino end-to-end?
