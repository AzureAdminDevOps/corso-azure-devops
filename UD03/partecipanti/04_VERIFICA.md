# Verifica — Identità, accessi, governance e costi

Compila `consegne/UD03/03_VERIFICA.md`. Al termine controlla il file con `git diff`, aggiungi alla staging area soltanto questa consegna e verifica il risultato con `git diff --cached`.

## Parte A — Scelta singola

1. Un utente accede al portale ma non può leggere un resource group. Quale affermazione è corretta?
   - A. L'autenticazione è fallita
   - B. L'autenticazione è riuscita, ma manca un'autorizzazione applicabile
   - C. Il tenant non esiste
   - D. Deve ricevere Global Administrator

2. Quale elemento non appartiene alla role assignment Azure?
   - A. Principal
   - B. Role definition
   - C. Scope
   - D. Password

3. Un team deve soltanto consultare un resource group. Qual è la scelta minima?
   - A. Owner sulla sottoscrizione
   - B. Contributor sul resource group
   - C. Reader sul resource group
   - D. Global Administrator

4. Un ruolo assegnato alla sottoscrizione rispetto a un resource group figlio è normalmente:
   - A. eliminato
   - B. ereditato
   - C. convertito in ruolo Entra
   - D. valido solo per Cost Management

5. Quale ruolo può gestire risorse ma normalmente non creare role assignment?
   - A. Reader
   - B. Contributor
   - C. Owner
   - D. User Administrator

6. Un lock `CanNotDelete` applicato a un resource group:
   - A. impedisce anche ogni lettura
   - B. sostituisce Azure RBAC
   - C. impedisce l'eliminazione finché applicabile
   - D. elimina automaticamente il gruppo a scadenza

7. Un budget Azure al 100%:
   - A. arresta automaticamente tutte le risorse
   - B. genera una condizione di notifica, ma non costituisce un tetto automatico
   - C. assegna Reader al team FinOps
   - D. impedisce nuovi deployment in ogni sottoscrizione

8. Dove si gestisce normalmente la creazione di un utente cloud?
   - A. Azure RBAC sul resource group
   - B. Microsoft Entra ID con ruolo appropriato
   - C. Tag del resource group
   - D. Resource lock

## Parte B — Risposte brevi

9. Spiega perché assegnare ruoli a un gruppo è spesso preferibile alle assegnazioni individuali.
10. Distingui ruolo Microsoft Entra e ruolo Azure con un esempio per ciascuno.
11. Un utente ha Reader sul resource group e Contributor ereditato dalla sottoscrizione. Qual è l'accesso effettivo e perché?
12. Elenca in ordine almeno quattro controlli per diagnosticare `AuthorizationFailed`.
13. Spiega la differenza tra tag `deleteAfter`, lock `CanNotDelete` e budget.

## Parte C — Caso situazionale

Un tecnico deve consultare una VNet in `rg-network-prod`. Riceve Contributor sull'intera sottoscrizione. Successivamente non riesce ad assegnare Reader a un collega e, tentando il cleanup, riceve `ScopeLocked`.

14. Individua almeno due scelte o interpretazioni errate.
15. Proponi il ruolo e lo scope iniziali più appropriati.
16. Spiega separatamente perché non riesce ad assegnare il ruolo e perché non riesce a eliminare lo scope.

Controlla e prepara soltanto il file della verifica:

```bash
git diff -- consegne/UD03/03_VERIFICA.md
git add consegne/UD03/03_VERIFICA.md
git diff --cached -- consegne/UD03/03_VERIFICA.md
```

⏱
