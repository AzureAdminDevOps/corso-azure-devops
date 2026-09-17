# UD09 — Verifica individuale

La verifica controlla sia i **fondamenti DevOps** sia la capacità di interpretare gli oggetti Azure DevOps preparati nel LAB.

## Parte A — Scelta singola

### 1. DevOps è principalmente:

- A. un prodotto Microsoft
- B. un insieme di cultura, pratiche e tecnologie che collegano sviluppo, delivery e operation
- C. un sinonimo di Docker
- D. un linguaggio YAML

### 2. Agile e DevOps:

- A. sono esattamente la stessa cosa
- B. sono incompatibili
- C. Agile riguarda soprattutto lavoro iterativo/adattivo; DevOps estende il flusso a delivery e operation
- D. DevOps sostituisce il Version Control

### 3. Un backlog è:

- A. un elenco ordinato di lavoro da realizzare
- B. un file di log
- C. un container registry
- D. un Agent Pool

### 4. Continuous Integration significa principalmente:

- A. distribuire automaticamente ogni commit in produzione
- B. integrare frequentemente e verificare automaticamente build/test
- C. creare una VM
- D. fare code review senza test

### 5. Un artifact è:

- A. soltanto codice sorgente
- B. un risultato di build destinato a una fase successiva
- C. un utente Azure DevOps
- D. una permission

### 6. Continuous Deployment si distingue dalla Continuous Delivery perché:

- A. non usa pipeline
- B. può portare automaticamente in produzione ogni modifica che supera i gate previsti
- C. non esegue test
- D. richiede sempre un deployment manuale

### 7. Un container registry conserva principalmente:

- A. User Story
- B. container image
- C. sprint
- D. log KQL

### 8. Un orchestrator serve principalmente a:

- A. gestire scheduling, repliche, scaling e lifecycle di workload containerizzati
- B. creare commit Git
- C. scrivere User Story
- D. generare PAT

### 9. Azure Boards supporta principalmente:

- A. planning e tracking del lavoro
- B. container image
- C. gestione NSG
- D. DNS

### 10. Nel nostro percorso il repository sorgente rimane:

- A. Azure Repos
- B. GitHub
- C. Azure Artifacts
- D. Log Analytics

### 11. Un agent è:

- A. la capacità/licenza di concorrenza
- B. il processo/macchina che esegue un job
- C. un backlog
- D. un Work Item

### 12. Un parallel job rappresenta:

- A. la capacità di eseguire job contemporaneamente
- B. la versione dell'agent
- C. una branch
- D. un container

---

## Parte B — Risposte brevi

### 13. Distingui Scrum e Kanban.

### 14. Distingui Epic, Feature, User Story e Task.

### 15. Distingui build e artifact.

### 16. Distingui unit test, integration test e smoke test.

### 17. Che cosa significa shift-left?

### 18. Distingui Stage, Job e Step.

### 19. Distingui Azure Repos, Azure Pipelines, Azure Test Plans e Azure Artifacts.

### 20. Distingui Organization, Project, Agent Pool e Agent.

### 21. Distingui Microsoft-hosted e self-hosted Agent.

### 22. Perché `Grant access permission to all pipelines` non è la scelta predefinita consigliabile?

### 23. Perché il PAT di registrazione dell'agent può essere revocato dopo la configurazione?


### 24. Azure Pipelines e Azure Pipelines Agent sono la stessa cosa? Spiega la differenza.

### 25. Associa correttamente:

```text
Azure Pipelines
Jenkins
GitHub Actions
GitLab CI/CD
```

con:

```text
Azure Pipelines Agent
Jenkins Agent
Runner
GitLab Runner
```

### 26. Perché Jenkins viene citato nella UD09 anche se non lo utilizzeremo operativamente?

### 27. Quali compiti svolgerà concretamente un Agent nelle UD13–UD15?

### 28. Perché prepariamo sia self-hosted sia Microsoft-hosted?

---

## Parte C — Scenario

> Il portale mostra `agent-wsl-01 Offline`. La registrazione era stata completata correttamente e il PAT è già stato revocato. In WSL2 nessun processo `run.sh` è attivo.

### 29. Qual è la prima causa da verificare e quale azione eseguiresti?

### 30. Perché non creeresti subito un nuovo PAT e non riconfigureresti l'agent?

---

## Parte D — Mappa finale

Completa mentalmente o sul file di consegna:

```text
Planning        → ?
Version Control → ?
CI/CD           → ?
Container       → ?
Registry        → ?
IaC             → ?
Runtime         → ?
Monitoring      → ?
```

Usa gli strumenti effettivamente adottati nel percorso.
