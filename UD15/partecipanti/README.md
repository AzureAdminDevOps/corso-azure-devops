# UD15 — Continuous Delivery con Terraform

La UD15 inizia dopo il completamento della UD14 e dopo la lettura del Security Review.

La UD14 non viene modificata.

Da questa unità la pipeline utilizza soltanto:

```text
sc-azure-ud13-15
```

per le operazioni Azure.

La nuova pipeline usa:

```text
Terraform
AzureCLI@2
Docker
Azure Container Registry
Azure Container Apps
```

## Prima del laboratorio

Aprire nell'ordine:

```text
00_CONCETTI.md
01_CONTROLLI_INIZIALI.md
```

I controlli iniziali servono a verificare che tutti dispongano delle stesse risorse e autorizzazioni prima di iniziare il laboratorio.

Solo dopo aver completato questi controlli aprire:

```text
02_LAB_GUIDATO.md
```

## File principali

```text
00_CONCETTI.md
01_CONTROLLI_INIZIALI.md
02_LAB_GUIDATO.md
03_LAB_AUTONOMO.md
04_VERIFICA.md
infra/terraform/ud15/
pipeline/azure-pipelines-delivery.yml
pipeline/azure-pipelines-cleanup.yml
modelli/
```

## Regola per gli oggetti della UD14

Se esiste:

```text
sc-acr-ud14
```

non modificarla durante UD15.

La nuova pipeline non la utilizza.

La sua eventuale rimozione viene affrontata soltanto al termine del percorso.
