# UD06 — Laboratorio autonomo

# Scenario

La VM Linux è attiva e Nginx risponde correttamente.

Devi:

1. introdurre un guasto NSG controllato;
2. diagnosticarlo;
3. ripristinare il servizio;
4. leggere una metrica;
5. progettare una regola di autoscaling;
6. distinguere HA, Backup e DR.

---

# Attività 1 — Baseline

Verifica:

```bash
curl -I "http://$LAB_VM_IP"
```

Annota:

- stato VM;
- Nginx;
- esito HTTP;
- regola NSG che consente il traffico.

---

# Attività 2 — Guasto controllato

Crea:

```text
Name: Deny-HTTP-Auto
Priority: 200
Direction: Inbound
Protocol: TCP
Source: My IP
Destination port: 80
Action: Deny
```

La regola Allow è a priorità 310.

---

# Attività 3 — Diagnosi

Ripeti il test HTTP.

Usa:

- elenco regole NSG;
- IP Flow Verify;
- stato Nginx;
- `curl localhost`;
- route effettive se necessario.

Documenta:

```text
sintomo
→ ipotesi
→ controllo
→ causa
→ correzione minima
```

---

# Attività 4 — Ripristino

Elimina solo:

```text
Deny-HTTP-Auto
```

Ripeti test HTTP e verifica.

---

# Attività 5 — Monitoring

Apri Metrics della VM.

Scegli una metrica tra:

```text
Percentage CPU
Network In
Network Out
```

Riporta:

- metrica;
- intervallo;
- aggregazione;
- ciò che puoi dedurre;
- ciò che NON puoi dedurre.

---

# Attività 6 — Progetta autoscaling VMSS

Requisito:

> mantenere almeno 1 istanza, massimo 4; se CPU media supera 70% per 5 minuti aggiungere 1 istanza.

Compila:

```text
min:
default:
max:
metrica:
condizione:
azione:
```

Spiega perché:

```text
max = 4
```

è importante.

---

# Attività 7 — App Service scaling

Per ciascuna esigenza scegli:

```text
Scale up
Scale out manuale
Azure Monitor Autoscale
Automatic Scaling
```

### A
Serve una singola istanza più potente.

### B
Il numero di istanze deve aumentare quando CPU supera una soglia definita.

### C
La piattaforma deve reagire automaticamente al traffico HTTP senza definire regole metriche esplicite, su un tier compatibile.

### D
Per una demo voglio semplicemente passare da 1 a 2 istanze manualmente.

---

# Attività 8 — Backup policy

Progetta una policy per una VM aziendale.

Indica:

```text
frequenza:
orario:
retention:
motivazione:
```

Non creare il backup reale.

---

# Attività 9 — HA / Backup / DR

Classifica:

### Scenario A
Guasto di una singola istanza, servizio deve continuare.

### Scenario B
Cancellazione accidentale di dati: serve recuperare uno stato precedente.

### Scenario C
Regione primaria indisponibile: il workload deve essere riattivato altrove.

Indica:

```text
HA
Backup
DR
```

e motiva.

---

# Attività 10 — RPO / RTO

Requisito:

```text
perdita massima dati: 15 minuti
servizio nuovamente operativo entro: 60 minuti
```

Indica:

```text
RPO:
RTO:
```

---

# Consegna

Compila:

```text
consegne/UD06/02_LAB_AUTONOMO.md
```
