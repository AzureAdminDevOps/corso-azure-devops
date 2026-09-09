# UD03 – Consolidamento Microsoft Learn
## Percorso AZ-104: Manage identities and governance in Azure
### Versione PARTECIPANTE

Percorso ufficiale di riferimento:

https://learn.microsoft.com/en-us/training/paths/az-104-manage-identities-governance/

> Obiettivo: consolidare i contenuti della UD03 con una selezione mirata del percorso Microsoft Learn. Non è richiesto completare linearmente tutti i moduli del learning path.

---

# 1. Selezione del percorso Microsoft Learn

Il percorso ufficiale contiene 6 moduli. Per questa UD useremo la seguente selezione.

| # | Modulo Microsoft Learn | Cosa fare | Priorità |
|---|---|---|---|
| 1 | Understand Microsoft Entra ID | **Quasi completo** | Alta |
| 2 | Create, configure, and manage identities | **Selezione di unità** | Alta |
| 3 | Describe the core architectural components of Azure | **Solo ripasso della gerarchia di gestione** | Bassa |
| 4 | Azure Policy initiatives | **Selezione di unità + laboratorio** | Alta |
| 5 | Secure your Azure resources with Azure RBAC | **Completo** | Massima |
| 6 | Allow users to reset their password with Microsoft Entra self-service password reset | **Parte concettuale** | Media |

---

# 2. Modulo 1 – Understand Microsoft Entra ID

## Da svolgere

- Introduction
- Examine Microsoft Entra ID
- Compare Microsoft Entra ID and Active Directory Domain Services
- Examine Microsoft Entra ID as a directory service for cloud apps
- Compare Microsoft Entra ID P1 and P2 plans
- Examine Microsoft Entra Domain Services
- Module assessment
- Summary

## Concetti da fissare

- tenant
- directory
- utenti
- gruppi
- identità cloud
- Microsoft Entra ID
- differenza generale tra Microsoft Entra ID e AD DS
- ruolo generale dei piani P1/P2
- Microsoft Entra Domain Services

## Domande di controllo

1. Tenant Entra ID e subscription Azure sono la stessa cosa?
2. Qual è il ruolo di Microsoft Entra ID?
3. Qual è la differenza generale tra Microsoft Entra ID e Active Directory Domain Services?
4. Perché un'applicazione cloud può utilizzare Microsoft Entra ID?

---

# 3. Modulo 2 – Create, configure, and manage identities

## Da svolgere

- Introduction
- Create, configure, and manage users
- Exercise – Restore or remove deleted users
- Create, configure, and manage groups
- Exercise – Add groups in Microsoft Entra ID
- Manage licenses
- Module assessment
- Summary and resources

## Da leggere rapidamente / facoltativo oggi

- Exercise – Assign licenses to users
- Exercise – Modify group license assignments
- Exercise – Modify user license assignments

## Da rimandare

- Configure and manage device registration
- Create custom security attributes
- Explore automatic user provisioning

## Concetti da fissare

- utenti
- gruppi
- appartenenza ai gruppi
- gestione delle licenze
- assegnazione di autorizzazioni tramite gruppi
- principio del minimo privilegio

### Domanda

Hai 12 sistemisti che devono ricevere gli stessi permessi su un Resource Group.

Quale soluzione è preferibile?

A. 12 assegnazioni separate agli utenti  
B. Creare un gruppo e assegnare il ruolo al gruppo

---

# 4. Modulo 3 – Core architectural components of Azure

## Non svolgere integralmente oggi

Ripassare solo questa gerarchia:

```text
Management Group
        ↓
Subscription
        ↓
Resource Group
        ↓
Resource
```

Questa gerarchia sarà usata per comprendere lo **scope** di RBAC e Azure Policy.

---

# 5. Modulo 5 – Azure RBAC
## Secure your Azure resources with Azure role-based access control

Questo modulo è **prioritario** e va svolto integralmente.

## Da svolgere

- Introduction
- What is Azure role-based access control?
- Knowledge check
- Exercise – Get a list of access using Azure RBAC and the Azure portal
- Exercise – Grant access using Azure RBAC and the Azure portal
- Exercise – View activity logs for Azure RBAC changes
- Module assessment
- Summary

## Concetti da fissare

```text
Role Assignment =
Security Principal
        +
Role Definition
        +
Scope
```

### Security principal

Può essere, ad esempio:

- utente
- gruppo
- service principal
- managed identity

### Ruoli principali

| Ruolo | Significato generale |
|---|---|
| Reader | Visualizza |
| Contributor | Gestisce risorse |
| Owner | Gestisce risorse e accessi |

### Scope

```text
Management Group
        ↓
Subscription
        ↓
Resource Group
        ↓
Resource
```

Le autorizzazioni assegnate a uno scope superiore possono essere ereditate dagli scope inferiori.

---

# 6. Modulo 4 – Azure Policy initiatives

Percorso:

https://learn.microsoft.com/en-us/training/modules/sovereignty-policy-initiatives/

## Da svolgere

- Introduction
- Azure Policy design principles
- Azure Policy resources
- Azure Policy definitions
- Evaluation of resources through Azure Policy
- Check your knowledge
- Summary

## Da leggere solo rapidamente

- Cloud Adoption Framework for Azure

L'obiettivo di oggi non è approfondire Microsoft Cloud for Sovereignty, ma comprendere Azure Policy e le Policy Initiatives.

## Concetti da fissare

```text
Policy Definition
        ↓
singola regola
```

```text
Policy Initiative
        ↓
insieme di più Policy Definition
con un obiettivo comune
```

```text
Policy Assignment
        ↓
applicazione della policy/initiative
a uno scope
```

```text
Compliance
        ↓
verifica della conformità
```

---

# 7. Laboratorio – Governance Baseline con Azure Policy

## Scenario

L'organizzazione stabilisce che le risorse dell'ambiente di formazione:

1. possano essere create solo nelle regioni autorizzate;
2. debbano avere il tag:

```text
Environment = Training
```

L'obiettivo è rappresentare queste regole tramite Azure Policy.

## Fase 1 – Creare il Resource Group

Dal portale Azure creare:

```text
rg-ud03-policy
```

Usare una regione disponibile nella propria subscription, ad esempio:

```text
West Europe
```

## Fase 2 – Esplorare le Policy built-in

Nel portale:

```text
Policy
  → Definitions
```

Cercare le definizioni built-in relative a:

```text
Allowed locations
```

e a una policy che richieda un tag e un valore sulle risorse, ad esempio:

```text
Require a tag and its value on resources
```

Individuare:

- nome della Policy Definition;
- categoria;
- effetto;
- parametri.

## Fase 3 – Ragionare come amministratore

Le due regole fanno parte dello stesso obiettivo aziendale:

```text
Training Governance Baseline
```

Rappresentazione:

```text
Training Governance Baseline
        |
        +-- Allowed locations
        |
        +-- Require Environment=Training
```

Individuare nel portale la sezione relativa alle **Initiatives** e osservare come più Policy Definition possano essere raggruppate.

> Se la creazione di una custom Initiative non è disponibile o richiede più tempo del previsto, proseguire assegnando le due Policy singolarmente allo stesso Resource Group. L'obiettivo didattico rimane invariato.

## Fase 4 – Assegnazione

Scope:

```text
rg-ud03-policy
```

Configurare le regioni consentite scegliendo regioni effettivamente utilizzabili nella subscription.

Configurare:

```text
Tag name: Environment
Tag value: Training
```

Attendere il tempo necessario perché le assegnazioni diventino effettive.

---

# 8. Test di conformità

Usare una risorsa semplice e a basso impatto, ad esempio una Virtual Network.

## Test A – Regione autorizzata, tag mancante

```text
Name: vnet-test01
Region: regione autorizzata
Tag: assente
```

Prima di avviare la creazione, prevedere il risultato.

## Test B – Tag corretto, regione non autorizzata

```text
Name: vnet-test02
Region: regione NON autorizzata
Environment = Training
```

Prevedere il risultato.

## Test C – Configurazione conforme

```text
Name: vnet-test03
Region: regione autorizzata
Environment = Training
```

Prevedere il risultato.

---

# 9. RBAC vs Policy

Scenario:

Un utente è **Owner** del Resource Group.

Una Policy consente solo determinate regioni.

L'utente prova a distribuire una risorsa in una regione non consentita.

Domanda:

> Il fatto che l'utente sia Owner gli consente di ignorare automaticamente la Policy?

Spiegare la risposta distinguendo:

```text
RBAC
CHI può fare COSA
```

da:

```text
POLICY
QUALE CONFIGURAZIONE è consentita
```

---

# 10. Modulo 6 – Self-service password reset

## Da svolgere oggi

- Introduction
- What is Microsoft Entra self-service password reset?
- Implement Microsoft Entra self-service password reset
- Summary

## Esercitazione facoltativa

- Exercise – Configure self-service password reset

L'esercitazione pratica va svolta solo se tenant, licenze e autorizzazioni disponibili lo consentono.

## Da rimandare

- tutorial relativo al branding

## Concetti da fissare

- che cos'è SSPR;
- perché riduce il carico amministrativo;
- prerequisiti generali;
- registrazione dei metodi di autenticazione;
- differenza tra autenticazione e autorizzazione.

---

# 11. Matrice di riepilogo UD03

| Tecnologia | Domanda principale |
|---|---|
| Microsoft Entra ID | Chi è l'identità? |
| Azure RBAC | Cosa può fare quell'identità e su quale scope? |
| Azure Policy | Quali configurazioni sono consentite? |
| Policy Initiative | Come raggruppo più Policy sotto uno stesso obiettivo? |
| Resource Lock | Come proteggo una risorsa da modifiche/eliminazioni? |
| Budget | Quanto sto spendendo e quando devo essere avvisato? |

---

# 12. Quiz finale – stile AZ-104

## 1

Un utente ha **Reader** su un Resource Group ma **Contributor** sulla subscription che contiene il Resource Group.

Quali autorizzazioni effettive possiede sul Resource Group?

A. Solo Reader  
B. Contributor  
C. Owner  
D. Nessuna

## 2

Un tecnico deve creare e modificare VM, dischi e reti ma non deve assegnare ruoli RBAC.

A. Reader  
B. Contributor  
C. Owner  
D. Global Administrator

## 3

Quale componente Azure RBAC identifica chi riceve le autorizzazioni?

A. Scope  
B. Role definition  
C. Security principal  
D. Resource Lock

## 4

Quale componente Azure RBAC definisce quali operazioni sono consentite?

A. Role definition  
B. Tenant  
C. Management Group  
D. Security principal

## 5

L'organizzazione deve impedire la distribuzione di risorse al di fuori delle regioni autorizzate.

A. Azure RBAC  
B. Azure Policy  
C. Resource Lock  
D. NSG

## 6

Una risorsa critica di produzione non deve essere eliminata accidentalmente.

A. Reader  
B. Policy con Audit  
C. Resource Lock CanNotDelete  
D. Budget

## 7

Un Resource Group ha un lock **CanNotDelete**.

A. Non può essere modificato né eliminato  
B. Può essere modificato ma non eliminato  
C. Può essere eliminato dagli Owner  
D. Sono bloccate solo modifiche di rete

## 8

È stato impostato un Budget mensile di 100 euro. Cosa accade normalmente superando 100 euro?

A. Azure arresta tutte le VM  
B. Azure elimina alcune risorse  
C. Il Budget può generare avvisi, ma non blocca automaticamente la spesa  
D. La subscription viene sospesa immediatamente

## 9

Un utente deve visualizzare le risorse di un Resource Group senza modificarle.

A. Reader  
B. Contributor  
C. Owner  
D. User Access Administrator

## 10

Quale descrizione distingue correttamente RBAC e Policy?

A. RBAC controlla la rete e Policy gli utenti  
B. RBAC stabilisce chi può eseguire operazioni; Policy stabilisce quali configurazioni sono consentite  
C. RBAC si applica solo alle VM  
D. Sono la stessa funzionalità

---

# 13. Autovalutazione finale

Al termine devi saper spiegare:

1. Microsoft Entra ID vs AD DS.
2. Tenant vs subscription.
3. Utente vs gruppo.
4. Security principal, role definition e scope.
5. Reader vs Contributor vs Owner.
6. RBAC vs Azure Policy.
7. Policy Definition vs Initiative.
8. Assignment e compliance.
9. CanNotDelete vs ReadOnly.
10. Budget vs limite tecnico di spesa.
11. Funzione generale di SSPR.

---

# Riferimenti ufficiali

- Learning path AZ-104 – Manage identities and governance in Azure  
  https://learn.microsoft.com/en-us/training/paths/az-104-manage-identities-governance/

- Study guide AZ-104  
  https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-104

- Azure Policy initiatives  
  https://learn.microsoft.com/en-us/training/modules/sovereignty-policy-initiatives/
