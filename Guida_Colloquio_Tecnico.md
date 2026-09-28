# Guida al colloquio tecnico — domande ricorrenti nei colloqui

## Obiettivo

Questa guida serve per prepararsi a colloqui tecnici per ruoli Junior Cloud Engineer, Cloud Administrator, DevOps Engineer, IT Support/Infrastructure e ruoli affini.

Le risposte proposte **non vanno imparate a memoria parola per parola**. Devono essere usate come modello per costruire risposte chiare, semplici e tecnicamente corrette.

Durante un colloquio è utile seguire questo schema:

1. **Che cos'è?** — dare una definizione semplice.
2. **Come funziona?** — spiegare il meccanismo essenziale.
3. **A cosa serve?** — collegare il concetto a un problema concreto.
4. **Fammi un esempio.** — citare qualcosa che si è realmente fatto.

Se non si conosce una risposta, è preferibile dirlo chiaramente piuttosto che inventare dettagli tecnici.

---


# A. Presentazione ed esperienza

## 1. Parlami di te e del tuo percorso tecnico

**Possibile risposta**

> Il mio percorso recente è focalizzato sulle tecnologie cloud e DevOps. Ho lavorato in laboratorio su Microsoft Azure, utilizzando sia il Portale sia Azure CLI. Ho gestito Resource Group, reti virtuali, Storage, macchine virtuali, App Service, identità e permessi con Entra ID e RBAC. Ho inoltre utilizzato Git e GitHub per versionamento, branch e Pull Request e sto lavorando con Docker, Docker Compose e Azure DevOps. Mi interessa un ruolo in cui possa consolidare queste competenze lavorando su infrastrutture cloud reali e continuando a crescere soprattutto nell'automazione e nelle pipeline CI/CD.

La risposta dovrebbe durare circa 60–90 secondi.

## 2. Che cosa sai fare concretamente su Azure?

> So creare e organizzare risorse attraverso Subscription e Resource Group, creare reti virtuali e subnet, configurare NSG, lavorare con VM, Storage Account e App Service. Ho utilizzato Entra ID e RBAC per utenti, gruppi e autorizzazioni, Azure Policy per la governance e Azure Monitor e Log Analytics per il monitoraggio. So inoltre utilizzare Azure CLI per interrogare e creare risorse senza dipendere esclusivamente dal Portale.

È possibile aggiungere:

> Non direi di essere ancora un amministratore Azure senior, ma sono in grado di eseguire autonomamente le principali attività operative e di diagnosticare problemi di base.

## 3. Raccontami un problema che non sei riuscito a risolvere subito

> Quando incontro un problema cerco prima di evitare modifiche casuali. Raccolgo informazioni, controllo lo stato del servizio, verifico i log e cerco di delimitare il livello a cui si trova il problema. Per esempio, se un container non parte correttamente controllo prima `docker compose ps`, poi i log e la configurazione effettivamente interpretata da Compose. Solo dopo formulo un'ipotesi e provo una modifica. Se non riesco a risolverlo, documento quello che ho verificato e chiedo supporto fornendo già tutte le evidenze raccolte.

# B. Cloud generale

## 4. Che cos'è il cloud computing?

> Il cloud computing è un modello in cui risorse come server, storage, reti, database e piattaforme applicative vengono fornite come servizi attraverso un provider. Invece di acquistare e installare necessariamente tutto l'hardware in casa, posso creare risorse quando servono, modificarle, scalarle e rimuoverle attraverso portali o API. Un vantaggio importante è quindi la possibilità di fare provisioning rapidamente e pagare in funzione delle risorse utilizzate.

## 5. IaaS, PaaS e SaaS: qual è la differenza?

> La differenza principale riguarda quanta parte dello stack gestisce il cliente e quanta il provider. Con IaaS, per esempio una VM Azure, Microsoft gestisce l'infrastruttura fisica e la virtualizzazione, mentre io continuo a gestire sistema operativo, patch e applicazioni. Con PaaS, come Azure App Service, anche gran parte del sistema operativo e del runtime viene gestita dal provider e io mi concentro maggiormente sull'applicazione. Con SaaS, come Microsoft 365, utilizzo direttamente l'applicazione senza amministrarne l'infrastruttura sottostante.

## 6. Public, private e hybrid cloud?

> Nel public cloud le risorse vengono erogate da un provider come Microsoft Azure su infrastruttura condivisa tra clienti ma logicamente isolata. Nel private cloud l'infrastruttura cloud è dedicata a una singola organizzazione. Nell'hybrid cloud si integrano infrastrutture on-premises o private con servizi public cloud. Per esempio, un'azienda può mantenere alcuni sistemi nei propri datacenter e utilizzare Azure per applicazioni web, backup o capacità aggiuntiva.

## 7. Scalabilità verticale e orizzontale?

> La scalabilità verticale significa aumentare le risorse di una singola macchina, per esempio passando da 2 a 8 CPU e aumentando la RAM. La scalabilità orizzontale significa invece aumentare il numero di istanze, per esempio passando da due a cinque server dietro un load balancer. Quella orizzontale è spesso più adatta ad applicazioni cloud progettate per essere distribuite.

# C. Azure amministrazione

## 8. Che cos'è Microsoft Azure?

> Microsoft Azure è la piattaforma cloud di Microsoft. Offre servizi di compute, rete, storage, database, identità, monitoraggio, sicurezza e molti altri servizi gestiti. Le risorse possono essere create e amministrate tramite Portale, CLI, PowerShell, API e strumenti Infrastructure as Code.

## 9. Subscription e Resource Group?

> La Subscription è uno scope amministrativo di alto livello collegato anche a billing, quote e governance. All'interno della Subscription creo Resource Group. Un Resource Group è un contenitore logico che raccoglie risorse correlate, per esempio una VM, la sua NIC e altre risorse della stessa applicazione. È utile anche perché posso applicare permessi e policy a livello di Resource Group.

## 10. Cos'è un NSG?

> Un Network Security Group è un meccanismo Azure che filtra traffico in ingresso e uscita. Contiene regole basate su protocollo, indirizzi, porte e priorità e può essere associato a subnet o interfacce di rete. Per esempio posso permettere TCP 22 verso una VM Linux solo da un determinato indirizzo sorgente.

## 11. VM o App Service: quando useresti uno o l'altro?

> Userei una VM quando ho bisogno di controllo maggiore sul sistema operativo, installazioni particolari o software non facilmente compatibile con PaaS. Utilizzerei App Service quando devo pubblicare un'applicazione web e preferisco che Microsoft gestisca gran parte dell'infrastruttura, del sistema operativo e della scalabilità. App Service riduce il carico amministrativo.

## 12. Come controlli i costi Azure?

> Utilizzerei Azure Cost Management per analizzare la spesa e creare budget e alert. Userei tag per attribuire i costi a progetto, ambiente o reparto. Verificherei anche VM sovradimensionate, dischi inutilizzati, risorse lasciate attive e servizi non più necessari. In cloud il controllo dei costi deve essere continuo.

## 13. Che cos'è Azure Storage?

> Azure Storage è la famiglia di servizi Azure per memorizzare dati. Comprende Blob per oggetti e file non strutturati, Azure Files per condivisioni SMB/NFS, Queue per messaggi e Table per dati NoSQL key-value.

# D. Identity, RBAC e sicurezza

## 14. Che cos'è la gestione delle identità e degli accessi?

> È l'insieme di tecnologie e regole utilizzate per stabilire chi o che cosa può autenticarsi e quali operazioni può eseguire. In Azure questo tema coinvolge soprattutto Microsoft Entra ID per le identità e Azure RBAC per le autorizzazioni sulle risorse.

## 15. Authentication e Authorization?

> Authentication significa verificare chi è l'utente o l'identità. Authorization significa stabilire cosa quell'identità è autorizzata a fare. Per esempio effettuo login con Entra ID: questa è autenticazione. Se poi posso leggere una VM ma non eliminarla, quello dipende dall'autorizzazione.

## 16. Cos'è Microsoft Entra ID?

> È il servizio cloud Microsoft per gestione delle identità e degli accessi. Gestisce utenti, gruppi, applicazioni e autenticazione e viene utilizzato dai servizi Microsoft cloud per stabilire chi sta accedendo.

## 17. Cos'è RBAC?

> Role-Based Access Control permette di assegnare ruoli a utenti, gruppi, service principal o managed identity su uno specifico scope. Per esempio posso assegnare Reader a un gruppo su un Resource Group. Il ruolo definisce le operazioni consentite e lo scope definisce dove quelle autorizzazioni si applicano.

## 18. Owner, Contributor e Reader?

> Reader può vedere le risorse ma non modificarle. Contributor può creare e modificare risorse ma normalmente non può gestire le assegnazioni di accesso. Owner può gestire sia le risorse sia l'accesso. Per sicurezza conviene assegnare il ruolo minimo necessario.

## 19. Che cos'è una Managed Identity?

> È un'identità gestita da Azure associata a una risorsa o creata come risorsa autonoma. Permette a servizi Azure di autenticarsi verso altri servizi senza dover memorizzare manualmente password o client secret.

# E. Networking

## 20. Che cos'è una rete di computer?

> È un insieme di sistemi e dispositivi collegati in modo da poter scambiare dati utilizzando protocolli condivisi. Una rete comprende indirizzamento, routing, protocolli di trasporto, servizi di risoluzione dei nomi e meccanismi di sicurezza.

## 21. Che cos'è il modello ISO/OSI?

> È un modello concettuale a sette livelli utilizzato per descrivere le funzioni della comunicazione di rete. È utile soprattutto per ragionare e fare troubleshooting separando problemi fisici, di collegamento, rete, trasporto e applicazione.

## 22. A quali livelli collocheresti IP, TCP e HTTP?

> IP opera al livello Rete, TCP al livello Trasporto e HTTP al livello Applicazione. Ethernet viene normalmente associato ai livelli Fisico e Data Link.

## 23. Cos'è una subnet?

> È una suddivisione logica di una rete IP. Permette di organizzare gli indirizzi e separare gruppi di risorse. In Azure una VNet può avere più subnet, per esempio una per frontend e una per backend.

## 24. TCP e UDP: differenza?

> TCP è connection-oriented: stabilisce una connessione e fornisce meccanismi per ordine, ritrasmissione e affidabilità. UDP invia datagrammi senza stabilire una connessione e con meno overhead, ma senza garantire consegna e ordine. Per questo vengono scelti in funzione delle esigenze dell'applicazione.

## 25. A cosa serve DNS?

> DNS traduce nomi comprensibili, per esempio `example.com`, in indirizzi IP e gestisce anche altri tipi di record. Senza DNS dovremmo conoscere direttamente gli indirizzi dei servizi.

## 26. Load Balancer e Application Gateway?

> In modo semplificato Azure Load Balancer lavora principalmente a livello 4, quindi TCP e UDP, distribuendo connessioni tra backend. Application Gateway opera a livello HTTP/HTTPS e può prendere decisioni basate su elementi applicativi, come host o URL, e può offrire funzionalità come TLS termination e Web Application Firewall.

---

# F. Troubleshooting

## 27. Che cos'è il troubleshooting tecnico?

> È un processo sistematico per identificare la causa di un problema e ripristinare il servizio. Un buon troubleshooting parte dai sintomi, raccoglie evidenze, delimita il livello coinvolto, formula ipotesi verificabili e modifica la configurazione soltanto dopo aver raccolto dati sufficienti.

## 28. VM Running ma SSH non funziona. Come procedi?

> Partirei senza modificare nulla. Verificherei che la VM sia effettivamente Running, che abbia l'indirizzo corretto e che sto usando la destinazione giusta. Poi controllerei NSG e regole sulla porta 22, NIC e subnet, eventuali route e successivamente il sistema operativo: servizio SSH, porta in ascolto e firewall Linux. Controllerei anche i log. Solo dopo aver identificato il livello problematico farei una modifica.

## 29. Il sito è lento. Da dove inizi?

> Cercherei prima di misurare il problema: è lento per tutti? Da quando? Su tutte le richieste o alcune? Poi guarderei metriche come CPU, memoria, latenza e numero di richieste e controllerei log applicativi. Verificherei anche dipendenze come database, API e rete. Eviterei di aumentare subito le risorse senza capire dove sia il collo di bottiglia.

# G. Monitoraggio, Azure Monitor, Log Analytics e KQL

## 30. Che cos'è il monitoraggio di un sistema?

> È la raccolta e l'analisi di segnali che descrivono stato e comportamento di infrastruttura e applicazioni. Serve a individuare problemi, misurare prestazioni, verificare disponibilità e comprendere come cambia il sistema nel tempo.

## 31. Che cos'è Azure Monitor?

> È la piattaforma di monitoraggio di Azure. Raccoglie e rende disponibili metriche, log, alert e altri segnali provenienti da risorse Azure e applicazioni.

## 32. Che differenza c'è tra metriche e log?

> Le metriche sono valori numerici raccolti nel tempo, per esempio CPU o numero di richieste. I log contengono eventi e record più dettagliati, utili per analisi e troubleshooting.

## 33. Che cos'è un Log Analytics Workspace?

> È un ambiente Azure nel quale vengono raccolti log interrogabili. Permette di utilizzare Kusto Query Language per filtrare, aggregare e correlare i dati.

## 34. Che cos'è KQL?

> Kusto Query Language è il linguaggio di interrogazione utilizzato da diversi servizi Microsoft per analizzare dati di log e telemetria. È orientato alla lettura e all'analisi e utilizza una sintassi a pipeline.

## 35. Come filtri in KQL gli eventi dell'ultima ora?

> Si usa normalmente `where` insieme a `ago()` sul campo temporale.

```kusto
AzureActivity
| where TimeGenerated > ago(1h)
```

# H. Linux

## 36. Che cos'è Linux?

> Linux è una famiglia di sistemi operativi Unix-like basati sul kernel Linux. È molto diffuso su server, cloud, container e sistemi embedded ed è amministrato spesso tramite shell e strumenti a riga di comando.

## 37. Che cos'è una shell?

> È un'interfaccia che interpreta i comandi dell'utente e li esegue nel sistema operativo. Bash è una delle shell più comuni in ambiente Linux.

## 38. Come cerchi una stringa dentro un file?

> Tipicamente con `grep`, per esempio `grep "ERROR" app.log`.

## 39. Come controlli i processi?

> Posso utilizzare `ps`, per esempio `ps aux`, e strumenti interattivi come `top`. Se sto cercando un processo specifico posso combinare `ps` con `grep` o utilizzare strumenti equivalenti.

## 40. Come vedi quali porte sono in ascolto?

> Su Linux moderno utilizzerei per esempio `ss -lntp`, in base ai privilegi disponibili. Mi permette di vedere socket in ascolto e spesso anche il processo associato.

# I. Windows e virtualizzazione

## 41. Che cos'è la virtualizzazione?

> È la tecnologia che permette di eseguire più ambienti virtuali isolati sopra la stessa infrastruttura fisica. Un hypervisor assegna alle VM CPU, memoria, storage e dispositivi virtualizzati.

## 42. Cos'è un hypervisor?

> È il componente che permette di creare ed eseguire macchine virtuali, gestendo l'accesso delle VM alle risorse fisiche come CPU, memoria e dispositivi.

## 43. Cos'è Active Directory?

> Active Directory Domain Services è il servizio directory Microsoft tradizionalmente utilizzato nelle reti aziendali on-premises. Gestisce domini, utenti, computer, gruppi, autenticazione e policy centralizzate.

## 44. AD DS ed Entra ID sono la stessa cosa?

> No. Entrambi riguardano identità, ma hanno architettura e protocolli differenti. AD DS è una directory tradizionale basata su domini e tecnologie come LDAP e Kerberos. Entra ID è un identity service cloud progettato anche per SaaS e applicazioni moderne.

# J. Git

## 45. Che cos'è Git?

> Git è un sistema distribuito di versionamento. Tiene traccia delle modifiche ai file, permette di lavorare con branch e commit e consente a più persone di collaborare mantenendo una storia verificabile del progetto.

## 46. Git e GitHub sono la stessa cosa?

> No. Git è un sistema distribuito di versionamento. GitHub è una piattaforma che ospita repository Git e aggiunge collaborazione, Pull Request, issue, automazione e altre funzionalità.

## 47. Commit e push?

> Commit salva una nuova revisione nel repository Git locale. Push trasferisce i commit locali verso un repository remoto come GitHub.

## 48. Fetch e pull?

> `git fetch` recupera dal remoto nuovi commit e riferimenti senza integrare automaticamente il mio branch. `git pull` normalmente combina un fetch con un'operazione di integrazione, per esempio merge o rebase a seconda della configurazione.

## 49. Perché utilizzare branch?

> Per isolare il lavoro. Posso sviluppare una modifica o correzione senza cambiare direttamente il branch principale e poi proporla tramite Pull Request.

## 50. Cos'è una Pull Request?

> È una richiesta di integrare modifiche da un branch verso un altro. Permette review, commenti, controlli automatici e approvazione prima del merge.

# K. Docker

## 51. Che cos'è Docker?

> Docker è una piattaforma per costruire, distribuire ed eseguire applicazioni in container. Permette di creare immagini riproducibili e di avviare processi isolati con filesystem, rete e configurazione controllati.

## 52. Container e VM: differenza?

> Una VM virtualizza una macchina completa e normalmente include un proprio sistema operativo guest. Un container condivide il kernel dell'host ma isola processi, filesystem, rete e altre risorse. Per questo i container tendono a essere più leggeri e veloci da avviare.

## 53. Image e container?

> L'image è l'artefatto riutilizzabile che contiene filesystem, applicazione e configurazione necessaria. Un container è un'istanza runtime creata a partire dall'image. Una stessa image può generare più container.

## 54. Come si crea un'image Docker?

> Si prepara normalmente un Dockerfile e si esegue `docker build`, indicando un build context. Docker interpreta le istruzioni, parte da una image base, copia file ed esegue i passaggi di build fino a produrre una nuova image.

## 55. Cos'è il build context?

> È l'insieme dei file e directory che il builder Docker può utilizzare durante la build. Nel comando `docker build ... .`, il punto indica la directory corrente come build context.

## 56. EXPOSE rende la porta accessibile dal PC?

> No. `EXPOSE` documenta che l'applicazione utilizza una porta. Per rendere la porta raggiungibile dall'host devo pubblicarla al runtime, per esempio con `docker run -p 8080:80`.

## 57. Come capisci perché un container è terminato?

> Controllerei prima lo stato con `docker ps -a` o `docker compose ps` e poi leggerei i log con `docker logs` o `docker compose logs`. Se necessario utilizzerei `docker inspect` per verificare configurazione e stato.

# L. Docker Compose e Web

## 58. Cos'è Docker Compose?

> È uno strumento che permette di descrivere un'applicazione multi-container in un file YAML. Posso definire servizi, build o image, environment, reti, volumi, porte, healthcheck e dipendenze e poi gestire l'intero stack con comandi come `docker compose up`.

## 59. Dockerfile e Compose sono la stessa cosa?

> No. Il Dockerfile descrive come costruire una singola image. Compose descrive come più servizi o container devono essere configurati e funzionare insieme e può utilizzare i Dockerfile per costruirne le image.

## 60. Cos'è un reverse proxy?

> È un componente che riceve richieste dai client e le inoltra verso uno o più servizi backend. Il client vede il reverse proxy come punto di ingresso. Può essere utilizzato per routing, TLS, bilanciamento, caching o centralizzazione degli accessi. Nel nostro laboratorio Nginx riceve le richieste e inoltra quelle API verso il container backend.

## 61. Perché non `localhost:8000`?

> Perché dal container frontend, localhost indica il container frontend stesso. Il backend è un altro container e deve essere raggiunto attraverso la rete Docker usando il nome del servizio.

# M. DevOps e CI/CD

## 62. Cos'è DevOps?

> DevOps non è un singolo prodotto. È un insieme di pratiche e cultura che mira a migliorare collaborazione tra sviluppo e operations, automazione, feedback e affidabilità. Tecnologie come Git, pipeline, Infrastructure as Code, container e monitoraggio servono a implementare questi principi.

## 63. Che cos'è Azure DevOps?

> Azure DevOps è una piattaforma Microsoft per il ciclo di vita del software. Comprende servizi come Azure Pipelines, Repos, Boards, Artifacts e Test Plans. Nel percorso svolto abbiamo utilizzato soprattutto Azure Pipelines, agent e service connection, mantenendo GitHub come repository remoto.

## 64. Cos'è CI?

> Continuous Integration significa integrare frequentemente le modifiche del codice e verificare automaticamente che non introducano problemi. Una pipeline CI può eseguire checkout, test, build e creare artefatti o immagini.

## 65. Cos'è CD?

> CD può significare Continuous Delivery o Continuous Deployment. Con Continuous Delivery l'applicazione viene mantenuta pronta per il rilascio ma può esserci un'approvazione manuale prima della produzione. Continuous Deployment porta automaticamente in produzione ogni modifica che supera tutti i controlli previsti.

## 66. Pipeline, Stage, Job e Step?

> La pipeline rappresenta l'intero processo automatizzato. Può essere suddivisa in Stage, per esempio Test, Build e Deploy. Ogni Stage contiene uno o più Job. Un Job viene assegnato a un Agent e contiene Step, cioè i singoli comandi o task da eseguire.

## 67. Cos'è un Agent?

> È la macchina o ambiente che esegue concretamente il Job della pipeline. Azure DevOps orchestra il processo, ma sono gli Agent che eseguono comandi come Python, Docker, Terraform o Azure CLI.

## 68. Microsoft-hosted e self-hosted?

> Con Microsoft-hosted la macchina Agent viene creata e gestita da Microsoft per il Job. Con self-hosted l'organizzazione gestisce il compute e il software Agent. Self-hosted non significa necessariamente PC dello sviluppatore: in produzione sarebbe tipicamente una VM o server del team.

## 69. Che cos'è Azure Pipelines?

> È il servizio di Azure DevOps che orchestra build, test, deployment e altre automazioni. Una pipeline YAML viene versionata e descrive stage, job, step, task e variabili.

## 70. Che cos'è una Service Connection Azure Resource Manager?

> È una service connection che consente a una pipeline di operare su risorse Azure attraverso un'identità autorizzata. Può essere configurata con Workload Identity Federation.

## 71. Che cos'è uno smoke test?

> È un controllo rapido eseguito dopo il deployment per verificare che le funzioni essenziali del servizio siano effettivamente disponibili, per esempio che un endpoint `/health` risponda correttamente.

# N. Infrastructure as Code, Bicep e Terraform

## 72. Che cos'è Infrastructure as Code?

> È l'approccio che descrive infrastruttura e configurazioni attraverso file versionabili invece di affidarsi soltanto a operazioni manuali nel portale. Permette ripetibilità, review, automazione e tracciabilità.

## 73. Che cos'è Bicep?

> Bicep è un linguaggio dichiarativo Microsoft per definire risorse Azure. Viene tradotto in template ARM e permette di descrivere risorse, parametri, dipendenze e output con una sintassi più leggibile rispetto al JSON ARM.

## 74. Che cos'è Terraform?

> Terraform è uno strumento Infrastructure as Code dichiarativo. Attraverso provider come AzureRM descrive le risorse desiderate, confronta configurazione e stato e calcola le modifiche necessarie.

## 75. Che cos'è un provider Terraform?

> È il componente che permette a Terraform di comunicare con una piattaforma o servizio. Nel nostro caso il provider AzureRM espone risorse e data source per Microsoft Azure.

## 76. Che cos'è Terraform State?

> È il meccanismo con cui Terraform mantiene la relazione tra configurazione e risorse gestite. Non è un normale file sorgente e deve essere protetto, soprattutto quando più persone o pipeline lavorano sulla stessa infrastruttura.

## 77. Perché usare uno state remoto in una pipeline?

> Perché run e Job differenti devono poter leggere lo stesso stato e non possono dipendere dal filesystem locale di un singolo agent. Un backend remoto offre anche meccanismi di locking e gestione centralizzata.

## 78. A cosa serve `terraform plan`?

> Confronta configurazione e stato e mostra le modifiche che Terraform propone di eseguire. È il passaggio fondamentale per capire cosa cambierà prima dell'apply.

## 79. A cosa serve `terraform apply`?

> Applica le modifiche previste dal piano e modifica realmente l'infrastruttura.

# O. Azure Container Registry e Azure Container Apps

## 80. Che cos'è un container registry?

> È un servizio che conserva e distribuisce container image e relativi tag. Le pipeline pubblicano immagini nel registry e gli ambienti di esecuzione le scaricano per avviare i container.

## 81. Che cos'è Azure Container Registry?

> Azure Container Registry, ACR, è il registry gestito di Azure per container image e artifact compatibili. Permette repository privati, autenticazione tramite identità Azure e integrazione con pipeline e servizi container.

## 82. Che cosa rappresenta il tag di una container image?

> È un'etichetta associata a una versione dell'immagine, per esempio `catalog-backend:1234`. In una pipeline può essere collegato al Build ID per mantenere la tracciabilità della release.

## 83. Che cos'è Azure Container Apps?

> È un servizio Azure gestito per eseguire applicazioni containerizzate senza amministrare direttamente un cluster Kubernetes. Gestisce environment, revision, ingress, scaling e integrazione con identità e registry.

## 84. Che cos'è l'ingress in Azure Container Apps?

> È la configurazione che espone la Container App al traffico e stabilisce, tra le altre cose, se l'accesso è esterno e verso quale porta del container deve essere inoltrato.

## 85. AcrPush e AcrPull: differenza?

> `AcrPush` permette di pubblicare immagini e include anche capacità di lettura nel modello RBAC classico di ACR. `AcrPull` è adatto al runtime che deve soltanto scaricare immagini.

# P. SQL e database relazionali

## 86. Che cos'è SQL?

> SQL è il linguaggio utilizzato per definire, interrogare e modificare dati nei database relazionali. Le operazioni più comuni comprendono SELECT, INSERT, UPDATE e DELETE.

## 87. Che cos'è un database relazionale?

> È un database che organizza i dati in tabelle composte da righe e colonne e permette di collegare le tabelle attraverso chiavi e relazioni.

## 88. Che cos'è una chiave primaria?

> È una colonna o combinazione di colonne che identifica in modo univoco ogni riga di una tabella.

## 89. Come filtri le righe in SQL?

> Si usa normalmente la clausola `WHERE`.

```sql
SELECT id, name, price
FROM products
WHERE price > 100;
```

## 90. Che cos'è una JOIN?

> È un'operazione che combina righe provenienti da tabelle diverse utilizzando una condizione di relazione.

# Q. Scripting e programmazione

## 91. Che cos'è lo scripting?

> È l'automazione di attività attraverso piccoli programmi eseguiti da un interprete, per esempio Bash, PowerShell o Python. È molto usato in amministrazione e DevOps per rendere ripetibili controlli, configurazioni e operazioni.

## 92. Cos'è una variabile d'ambiente?

> È una coppia nome-valore disponibile nell'ambiente di esecuzione di un processo. È spesso utilizzata per configurare applicazioni senza modificare direttamente il codice, per esempio porta, ambiente o endpoint.

## 93. JSON e YAML: a cosa servono?

> Sono formati testuali utilizzati per rappresentare dati strutturati e configurazioni. JSON utilizza parentesi e una sintassi più rigida; YAML privilegia indentazione e leggibilità. Nel mondo DevOps YAML viene molto utilizzato per pipeline e configurazioni.

# R. Domande avanzate che potrebbero comunque comparire

## 94. Cos'è Kubernetes?

> È una piattaforma di orchestrazione di container. Permette di gestire deployment, scaling, networking e lifecycle di applicazioni containerizzate distribuite su un cluster. Non l'ho ancora utilizzato operativamente nel percorso attuale, quindi preferirei non entrare in dettagli configurativi che non ho ancora sperimentato.

## 95. Cos'è Ansible?

> È uno strumento di automazione e configuration management. Permette di descrivere attività da eseguire su molti sistemi, tipicamente attraverso playbook YAML, ed è molto utilizzato per configurazione e amministrazione automatizzata.

## 96. OAuth e OIDC?

> OAuth 2.0 è principalmente un framework di autorizzazione che permette di concedere accesso a risorse senza condividere direttamente le credenziali dell'utente. OpenID Connect aggiunge un livello di autenticazione sopra OAuth 2.0 e permette di ottenere informazioni sull'identità autenticata.

# S. Domande HR e comportamentali

## 97. Perché dovremmo assumere te?

> Credo di poter portare una buona combinazione di basi tecniche, metodo e disponibilità ad apprendere. Non mi presento come una figura senior, ma ho lavorato concretamente con Azure, networking, Git, Docker e strumenti DevOps e sono abituato a verificare ciò che faccio invece di procedere per tentativi. Sono motivato a trasformare queste competenze di laboratorio in esperienza operativa reale.

## 98. Qual è il tuo punto debole?

> Quando incontro una tecnologia nuova tendo inizialmente a voler approfondire molti dettagli. Sto imparando a distinguere meglio ciò che è necessario per risolvere il problema immediato da ciò che posso approfondire successivamente. Mi aiuta molto definire prima l'obiettivo e procedere per priorità.

## 99. Cosa fai se non sai risolvere un ticket?

> Non provo modifiche casuali. Raccolgo dati, cerco di riprodurre il problema, controllo documentazione e log e verifico le possibili cause. Se devo fare escalation, invio già tutte le informazioni raccolte: sintomi, orari, log, test eseguiti e modifiche recenti. In questo modo chi riceve l'escalation non deve ricominciare da zero.

## 100. Come spieghi un problema tecnico a un cliente non tecnico?

> Eviterei gergo non necessario. Spiegherei prima l'impatto: cosa non funziona, chi è coinvolto e cosa stiamo facendo. Per esempio invece di dire “il backend restituisce HTTP 503 per saturation del pool”, potrei dire “il servizio è temporaneamente sovraccarico e alcune richieste non vengono completate; stiamo lavorando per ripristinare la capacità”. Se serve posso poi aggiungere dettagli tecnici.

# T. La domanda più importante: “Non lo so”

## 101. Non conosci la risposta. Che cosa fai?

**Possibile risposta**

> Non ho ancora utilizzato direttamente questa tecnologia e preferisco non inventare una risposta. Posso però dirle ciò che conosco a livello concettuale e provare a ragionare sul problema partendo dalle tecnologie che conosco. In un ambiente di lavoro verificherei la documentazione ufficiale e farei una prova controllata prima di intervenire su produzione.

Dire chiaramente ciò che non si conosce è preferibile a inventare dettagli tecnici.

---

# Metodo consigliato durante il colloquio


Per quasi ogni domanda tecnica conviene seguire questa sequenza:

```text
1. definizione semplice
2. funzionamento essenziale
3. utilità pratica
4. esempio concreto
```

## Esempio: Docker Compose

**Domanda**

> Cos'è Docker Compose?

**Risposta debole**

> Serve per gestire più container.

**Risposta migliore**

> Docker Compose è uno strumento che permette di descrivere un'applicazione multi-container attraverso un file YAML. Nel file posso definire servizi, image o build, reti, volumi, environment e porte. Nella nostra applicazione, per esempio, Compose crea e collega il frontend Nginx e il backend Python sulla stessa rete Docker, crea il volume utilizzato dal backend e pubblica il frontend sulla porta 8080. In questo modo non devo ricreare manualmente tutta la configurazione con molti `docker run`.

---

# Regola finale

Durante un colloquio tecnico non è necessario ricordare ogni parametro a memoria.

È molto più importante dimostrare:

```text
comprensione
+
metodo
+
capacità di ragionamento
+
capacità di comunicare
```

Se non si ricorda un comando esatto, è possibile dire:

> Non ricordo in questo momento l'opzione esatta, ma so quale informazione devo ottenere e quale sarebbe il percorso di troubleshooting. Verificherei la sintassi nella documentazione prima di eseguire il comando in un ambiente reale.

Questa risposta è molto più professionale rispetto all'esecuzione di comandi casuali.
