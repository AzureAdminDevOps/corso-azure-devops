# UD14 — CI in due blocchi

## Blocco A — fine Giornata 13

Prepariamo:

- applicazione/test;
- Docker Registry service connection;
- YAML CI;
- primo stage Test.

## Blocco B — inizio Giornata 14

Completiamo:

- build;
- push ACR;
- nuova modifica tramite branch/PR;
- nuova run CI;
- verifica image/tag.

Poi passiamo direttamente a UD15.

Non eseguire cleanup Azure.


## Strategia Agent

```text
MICROSOFT_HOSTED_READY
→ azure-pipelines-ci.yml
→ vmImage: ubuntu-latest

altrimenti
→ azure-pipelines-ci-selfhosted.yml
→ pool-ud09-wsl
```

Creare una sola pipeline CI.

Con Microsoft-hosted, `PythonTests` e `DockerBuild` ricevono ambienti temporanei distinti e non devono condividere implicitamente file locali.

L'ACR deve provenire dall'ultima UD13 con `LegacyRegistryPermissions`.


## Self-hosted fallback: interpretazione reale

Nel corso il fallback avvia l'Agent WSL2 personale. In produzione il fallback self-hosted sarebbe normalmente un Pool di build host aziendali gestiti e disponibili, non il notebook di uno sviluppatore.


### Regola da ricordare

```text
self-hosted
≠ PC dello sviluppatore

self-hosted
= Agent su infrastruttura gestita dall'organizzazione
```
