# UD13 — Terraform operativo + pipeline IaC

UD13 è la prima parte delle **due giornate finali integrate**.

La giornata non termina con il cleanup generale. Al contrario, prepara intenzionalmente infrastruttura e connessioni che verranno riutilizzate dalla CI e dalla CD.

Sequenza:

```text
Terraform più operativo
        ↓
service connection Azure
        ↓
pipeline YAML
        ↓
validazione Terraform/Bicep
        ↓
deploy ACR con Bicep
        ↓
passaggio immediato a UD14
```

## Ordine dei file

1. `00_CONCETTI.md`
2. `02_LAB_GUIDATO.md`
3. `03_LAB_AUTONOMO.md`
4. `04_VERIFICA.md`

## Cleanup

In UD13 viene eliminata soltanto l'infrastruttura Terraform temporanea.

**Non eliminare**:

```text
rg-ud13-15-delivery
ACR
service connection
pipeline IaC
agent
file IaC
```


## Scelta dell'Agent

UD13 è volutamente la **prima pipeline sul self-hosted Agent**:

```yaml
pool:
  name: pool-ud09-wsl
```

Questo permette di vedere che Terraform, Azure CLI e Bicep usati dalla pipeline sono quelli disponibili nel WSL2 preparato nelle UD precedenti.

Per evitare dipendenze accidentali dal filesystem persistente del self-hosted, i Job usano:

```yaml
workspace:
  clean: all
```

UD14 introdurrà il confronto operativo con Microsoft-hosted quando disponibile.

## Prima integrazione GitHub reale

La pipeline viene collegata al repository tramite **Azure Pipelines GitHub App**.

Non creare PAT GitHub manuali per la pipeline.

## Due connessioni diverse

```text
GitHub App
→ accesso al repository

sc-azure-ud13-15
→ accesso alle risorse Azure tramite WIF
```

Sono due problemi di autenticazione differenti.


## Interpretazione produttiva del Pool

`pool-ud09-wsl` non rappresenta il PC personale come architettura aziendale. Nel laboratorio contiene il singolo Agent WSL2; in produzione identificherebbe un insieme di build host condivisi. La pipeline deve poter essere assegnata a qualunque Agent compatibile del Pool.

### Regola da ricordare

```text
self-hosted
≠ PC dello sviluppatore

self-hosted
= Agent su infrastruttura gestita dall'organizzazione
```

`pool-ud09-wsl` è il nostro modello didattico di un Agent Pool aziendale condiviso.
