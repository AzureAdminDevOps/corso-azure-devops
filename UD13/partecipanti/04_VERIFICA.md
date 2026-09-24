# UD13 — Verifica rapida

Questa verifica è volutamente breve perché UD14 inizia nella stessa giornata.

1. Perché lo state locale non è ideale in un team?
2. Che differenza c'è tra stage, job e step?
3. Che cosa rappresenta `checkout: self`?
4. Perché la service connection è limitata a `rg-ud13-15-delivery`?
5. Perché usiamo Workload Identity Federation?
6. Perché in pipeline Terraform viene validato ma non applicato?
7. Quale risorsa deve sopravvivere a UD13 e perché?
8. Se `az bicep lint` fallisce per un file inesistente, quale classe di problema stiamo diagnosticando?
9. Perché la prima pipeline UD13 usa il self-hosted Agent?
10. A che cosa serve `workspace: clean: all`?
11. Distingui la GitHub App dalla Azure Resource Manager service connection.
12. Perché non usiamo `~/workspace/azure-devops-lab` dentro il YAML?
13. Che cosa cambierà quando in UD14 useremo `vmImage: ubuntu-latest`?

## Passaggio a UD14

Prima di continuare verificare:

```text
agent Online
rg-ud13-15-delivery presente
ACR Basic presente
admin user ACR = false
sc-azure-ud13-15 presente
pipeline IaC riuscita
oppure, se WIF è bloccata esternamente:
BLOCKED_BY_SERVICE_CONNECTION + ACR continuity creata via fallback locale
```

Non eseguire cleanup.
