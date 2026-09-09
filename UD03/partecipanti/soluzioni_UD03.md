# Soluzioni ai quesiti e alla verifica

Le risposte ai quesiti sui concetti corrispondono a `consegne/UD03/00_DOMANDE_CONCETTI.md`; le soluzioni della verifica corrispondono a `consegne/UD03/03_VERIFICA.md`.

## Domande di controllo dei concetti

### 1. Qual è la differenza tra autenticazione e autorizzazione?

**Risposta:**  
L'autenticazione conferma l'identità; l'autorizzazione valuta se quell'identità può eseguire una specifica azione su uno scope.

**Nota:**  
Ricorda la distinzione:
- autenticazione = *chi sei?*
- autorizzazione = *cosa puoi fare?*

---

### 2. Qual è la differenza tra un ruolo Microsoft Entra e un ruolo Azure RBAC?

**Risposta:**  
Un ruolo Entra governa oggetti della directory, per esempio utenti e gruppi; un ruolo Azure governa risorse Azure tramite Resource Manager.

**Nota:**  
Esempio:
- `User Administrator` → oggetti Microsoft Entra
- `Reader`, `Contributor`, `Owner` → risorse Azure

---

### 3. Quali sono i tre elementi fondamentali di una role assignment Azure RBAC?

**Risposta:**  
Principal, role definition e scope.

**Nota:**  

```text
Role Assignment
=
Security Principal
+
Role Definition
+
Scope
```

---

### 4. Perché Reader sul Resource Group è preferibile a Contributor sulla sottoscrizione quando serve soltanto consultare un progetto?

**Risposta:**  
Reader sul resource group concede soltanto lettura e limita l'ambito al progetto necessario; Contributor sulla sottoscrizione abilita modifiche su uno scope molto più ampio.

**Nota:**  
Collega questo concetto al principio del minimo privilegio.

---

### 5. Un'autorizzazione è ereditata da uno scope superiore. Dove deve essere modificata o rimossa?

**Risposta:**  
L'assegnazione è definita nello scope padre. Va rimossa o modificata nello scope nel quale è stata creata, non nella risorsa figlia.

**Nota:**  
Esempio:

```text
Subscription
   └── Contributor
       ↓ ereditato
Resource Group
   ↓
Resource
```

---

### 6. Il tag `deleteAfter` elimina automaticamente una risorsa alla data indicata?

**Risposta:**  
No. `deleteAfter` è un tag descrittivo; occorrono una persona, una policy o un'automazione che lo interpreti.

**Nota:**  
Un tag contiene metadati: da solo non esegue azioni.

---

### 7. Qual è la differenza tra il ruolo Reader e un Resource Lock `CanNotDelete`?

**Risposta:**  
Reader è un'autorizzazione RBAC che limita le azioni del principal; `CanNotDelete` è una protezione gestionale che blocca l'eliminazione anche per principal altrimenti autorizzati.

**Nota:**  
Ricorda di distinguere:
- RBAC → autorizzazioni dell'identità
- lock → protezione della risorsa

---

### 8. Un Azure Budget impedisce automaticamente di superare una determinata spesa?

**Risposta:**  
No. Il budget osserva il costo e genera notifiche; non arresta automaticamente risorse né impedisce nuovi consumi.

**Nota:**  
Budget ≠ hard spending limit.

---


## Verifica — Parte A

### Domanda 1
**Un utente riesce ad autenticarsi al portale Azure ma non riesce ad accedere a un Resource Group. Qual è la spiegazione più corretta?**

**Risposta corretta: B**

**Motivazione:**  
Il login riuscito dimostra autenticazione, non autorizzazione sul gruppo.

---

### Domanda 2
**Quale elemento NON fa parte di una role assignment Azure RBAC?**

**Risposta corretta: D**

**Motivazione:**  
La password non è parte della role assignment.

---

### Domanda 3
**Un utente deve soltanto leggere le risorse di un determinato Resource Group. Quale assegnazione rispetta meglio il minimo privilegio?**

**Risposta corretta: C**

**Motivazione:**  
Reader sul resource group soddisfa il requisito e limita lo scope al minimo necessario.

---

### Domanda 4
**Se un ruolo viene assegnato a livello di subscription, cosa accade normalmente agli scope figli?**

**Risposta corretta: B**

**Motivazione:**  
Gli scope figli ereditano normalmente le assegnazioni del padre.

---

### Domanda 5
**Quale ruolo predefinito permette di gestire risorse Azure ma non di assegnare normalmente ruoli RBAC?**

**Risposta corretta: B — Contributor**

**Motivazione:**  
Contributor gestisce risorse ma non assegna ruoli.

---

### Domanda 6
**Che effetto ha un Resource Lock `CanNotDelete`?**

**Risposta corretta: C**

**Motivazione:**  
Il lock impedisce l'eliminazione finché non viene rimosso.

---

### Domanda 7
**Quale affermazione descrive correttamente un Azure Budget?**

**Risposta corretta: B**

**Motivazione:**  
Il budget avvisa; non è un limite tecnico automatico.

---

### Domanda 8
**Gli utenti Microsoft Entra sono principalmente oggetti di quale ambito?**

**Risposta corretta: B**

**Motivazione:**  
Gli utenti sono oggetti Microsoft Entra.

---

## Verifica — Parte B

### Domanda 9
**Perché è preferibile assegnare un ruolo Azure a un gruppo Microsoft Entra invece che a molti utenti singolarmente?**

**Risposta:**  
Il gruppo separa assegnazione e ciclo di vita delle persone. Si concede il ruolo una volta e si gestiscono ingressi/uscite tramite membership, riducendo duplicazioni e accessi residui.

**Nota:**  
Collega questo concetto alla scalabilità amministrativa e al principio del minimo privilegio.

---

### Domanda 10
**Qual è la differenza operativa tra `User Administrator` e `Reader` su un Resource Group?**

**Risposta:**  
User Administrator può gestire utenti Microsoft Entra nei limiti previsti. Reader su un resource group può leggere le risorse Azure contenute senza modificarle.

**Nota:**  
Usa questa distinzione per separare i ruoli di directory dai ruoli Azure Resource Manager.

---

### Domanda 11
**Un utente ha Contributor ereditato dalla subscription e Reader assegnato direttamente sul Resource Group. Quali permessi effettivi possiede?**

**Risposta:**  
Contributor ereditato concede anche modifica. Reader non sottrae i permessi concessi da un'altra assegnazione; le autorizzazioni applicabili si combinano, salvo deny assignment o altri controlli.

**Nota:**  
Una role assignment meno permissiva a scope inferiore non “nega” quella più permissiva ereditata.

---

### Domanda 12
**Quali elementi devono essere verificati quando un utente riceve un errore di autorizzazione in Azure?**

**Risposta:**  
Verificare:
- identità effettiva;
- tenant e sottoscrizione;
- azione negata;
- scope dell'errore;
- assegnazioni dirette;
- assegnazioni di gruppo;
- assegnazioni ereditate;
- eventuale propagazione;
- lock o deny assignment quando pertinenti.

**Nota:**  
Questa può essere usata come checklist di troubleshooting RBAC.

---

### Domanda 13
**Confronta il comportamento di un tag `deleteAfter`, di un Resource Lock e di un Budget.**

**Risposta:**  
Il tag descrive una data ma non agisce. Il lock impedisce l'eliminazione. Il budget confronta costi e soglie e può notificare, senza arrestare automaticamente le risorse.

**Nota:**  

```text
Tag    → metadato
Lock   → protezione
Budget → monitoraggio/alert
```

---

## Verifica — Parte C

### Domanda 14
**Per leggere una sola VNet, perché assegnare Contributor sulla subscription è una scelta errata? Inoltre, Contributor può assegnare ruoli RBAC?**

**Risposta:**  
Contributor sulla sottoscrizione è più ampio del necessario per leggere una sola VNet. È inoltre errato supporre che Contributor possa assegnare ruoli. `ScopeLocked` non indica un problema RBAC ordinario.

**Nota:**  
Qui devi riconoscere due concetti:
1. minimo privilegio;
2. Contributor non equivale a gestione degli accessi.

---

### Domanda 15
**Quale assegnazione sarebbe più appropriata per un utente che deve consultare una VNet o più risorse dello stesso progetto?**

**Risposta:**  
Reader sulla VNet oppure sul resource group `rg-network-prod` se deve consultare più risorse del progetto. La scelta dipende dall'ampiezza reale del requisito.

**Nota:**  
Scegli sempre lo scope minimo compatibile con il requisito.

---

### Domanda 16
**Perché un'assegnazione RBAC può fallire per un Contributor e perché una cancellazione può fallire anche se l'utente possiede autorizzazioni sulla risorsa?**

**Risposta:**  
L'assegnazione RBAC fallisce perché Contributor non include normalmente `roleAssignments/write`. L'eliminazione fallisce per un lock applicato allo scope o ereditato, che deve essere individuato e rimosso da chi è autorizzato.

**Nota:**  
Ricorda di distinguere:
- autorizzazione RBAC;
- protezioni gestionali come Resource Lock.

---
