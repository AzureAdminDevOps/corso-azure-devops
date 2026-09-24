# UD14 — Verifica rapida

1. Perché Test deve precedere BuildPush?
2. Che cosa significa pipeline verde?
3. Perché usiamo `Build.BuildId` come tag?
4. Quale service connection usa Docker@2?
5. Perché ACR admin user può rimanere disabilitato?
6. Se Test fallisce, ha senso controllare i permessi ACR? Perché?
7. Quale evento attiva la CI configurata?
8. Perché non eseguiamo cleanup alla fine di UD14?
9. Perché Microsoft-hosted è il percorso principale della CI UD14?
10. Perché due Job Microsoft-hosted non devono condividere implicitamente file locali?
11. Quando si usa il fallback self-hosted?
12. Perché `workspace: clean: all` è importante sul fallback self-hosted?
13. Distingui Agent e Docker Registry service connection.
14. Perché controlliamo `python3 --version` e `docker --version` nei Job?

## Gate verso UD15

Verificare:

```text
UD14_AGENT_MODE documentato
pipeline CI riuscita
ACR presente
repository catalog-backend presente in ACR
almeno un tag Build ID presente
sc-azure-ud13-15 presente
sc-acr-ud14 presente
```
