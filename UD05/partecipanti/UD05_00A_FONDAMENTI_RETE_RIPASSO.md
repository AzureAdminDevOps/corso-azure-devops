# UD05 — Fondamenti di rete: ripasso essenziale prima di Azure Networking

## Perché questo documento

Prima di lavorare con:

- Azure Virtual Network (VNet);
- subnet;
- Network Security Group (NSG);
- routing;
- DNS;
- IP pubblici e privati;

è utile avere un modello mentale semplice di come funziona una rete IP tradizionale.

Questo documento è pensato sia per chi parte quasi da zero sia per chi vuole un ripasso rapido prima di affrontare Azure Networking.

---

# 1. Il percorso di un dato in rete

Quando un'applicazione comunica con un'altra macchina, il dato attraversa più livelli logici.

Esempio:

```text
Browser
   ↓
HTTP / HTTPS
   ↓
TCP
   ↓
IP
   ↓
Ethernet / Wi-Fi
   ↓
Scheda di rete
   ↓
Switch / Access Point
   ↓
Router
   ↓
Internet
```

Ogni livello risolve un problema differente.

---

# 2. Modello ISO/OSI

Il modello ISO/OSI divide la comunicazione in **7 livelli**.

```text
┌───────────────────────────────────────┐
│ 7  Application                       │
├───────────────────────────────────────┤
│ 6  Presentation                      │
├───────────────────────────────────────┤
│ 5  Session                           │
├───────────────────────────────────────┤
│ 4  Transport                         │
├───────────────────────────────────────┤
│ 3  Network                           │
├───────────────────────────────────────┤
│ 2  Data Link                         │
├───────────────────────────────────────┤
│ 1  Physical                          │
└───────────────────────────────────────┘
```

Non è necessario immaginare che ogni protocollo moderno appartenga sempre in modo perfetto a un solo livello. Il modello serve soprattutto per **ragionare e fare troubleshooting**.

---

# 3. Livelli OSI, protocolli e apparati

| Livello | Nome | Che cosa gestisce | Esempi | Apparati/elementi tipici |
|---:|---|---|---|---|
| 7 | Application | Servizi utilizzati dalle applicazioni | HTTP, HTTPS, DNS, DHCP, SSH, SMTP | Proxy, application gateway, application firewall |
| 6 | Presentation | Formato, codifica, cifratura | TLS, codifiche, formati | Funzioni software |
| 5 | Session | Gestione delle sessioni | Sessioni applicative | Funzioni software |
| 4 | Transport | Comunicazione tra processi e porte | TCP, UDP | Firewall stateful, load balancer L4 |
| 3 | Network | Indirizzamento e routing | IPv4, IPv6, ICMP | Router, Layer-3 switch |
| 2 | Data Link | Comunicazione nella LAN, frame, MAC | Ethernet 802.3, Wi-Fi 802.11, VLAN 802.1Q | Switch, bridge, access point |
| 1 | Physical | Trasmissione dei bit | rame, fibra, radio | cavi, hub, repeater, transceiver |

> Molti apparati moderni lavorano su più livelli contemporaneamente. La tabella indica il livello prevalente utile per il ragionamento.

---

# 4. Modello TCP/IP

Nella pratica Internet viene spesso descritto con il modello TCP/IP.

```text
OSI                          TCP/IP

7 Application ┐
6 Presentation├──────────►  Application
5 Session     ┘

4 Transport   ───────────►  Transport

3 Network     ───────────►  Internet

2 Data Link   ┐
1 Physical    ┘──────────►  Network Access
```

Per il troubleshooting quotidiano è spesso sufficiente pensare:

```text
Applicazione
     ↓
TCP / UDP
     ↓
IP
     ↓
Ethernet / Wi-Fi
```

---

# 5. Ethernet e indirizzi MAC

All'interno di una LAN Ethernet, le interfacce sono identificate da indirizzi **MAC**.

Esempio:

```text
00-1A-2B-3C-4D-5E
```

Un MAC identifica logicamente un'interfaccia a livello 2.

Uno switch Ethernet apprende quali MAC sono raggiungibili attraverso le proprie porte.

Schema:

```text
PC-A --------\
              \
               [ SWITCH ] -------- PC-C
              /
PC-B --------/
```

Lo switch inoltra i frame nella LAN.

---

# 6. Switch e router: differenza fondamentale

## Switch

Opera principalmente a livello 2.

Usa:

```text
MAC address
```

per inoltrare frame all'interno della LAN.

## Router

Opera principalmente a livello 3.

Usa:

```text
IP address
+
routing table
```

per inoltrare pacchetti tra reti differenti.

Schema:

```text
LAN A
192.168.10.0/24
      |
   [Switch]
      |
   [Router]
      |
   [Switch]
      |
LAN B
192.168.20.0/24
```

Il router collega reti IP differenti.

---

# 7. IPv4

Un indirizzo IPv4 è composto da 32 bit.

Esempio:

```text
192.168.1.25
```

In binario:

```text
11000000.10101000.00000001.00011001
```

Per l'amministrazione quotidiana normalmente utilizziamo la forma decimale.

---

# 8. Indirizzo IP e subnet mask

Un IP da solo non è sufficiente.

Occorre sapere quale parte identifica:

```text
RETE
```

e quale parte identifica:

```text
HOST
```

Esempio:

```text
IP:          192.168.1.25
Subnet mask: 255.255.255.0
```

equivalente a:

```text
192.168.1.25/24
```

La rete è:

```text
192.168.1.0/24
```

---

# 9. CIDR

La notazione CIDR indica quanti bit appartengono alla parte di rete.

Esempi:

| CIDR | Subnet mask | Totale indirizzi IPv4 |
|---|---|---:|
| /8 | 255.0.0.0 | 16.777.216 |
| /16 | 255.255.0.0 | 65.536 |
| /24 | 255.255.255.0 | 256 |
| /25 | 255.255.255.128 | 128 |
| /26 | 255.255.255.192 | 64 |
| /27 | 255.255.255.224 | 32 |
| /28 | 255.255.255.240 | 16 |

In una LAN IPv4 tradizionale una `/24` ha:

```text
256 indirizzi totali
254 host tradizionalmente utilizzabili
```

perché network address e broadcast non vengono assegnati agli host.

## Attenzione in Azure

Azure riserva **5 indirizzi per ogni subnet**.

Quindi una subnet Azure `/24` offre:

```text
256 - 5 = 251 indirizzi utilizzabili
```

Questo sarà importante durante la progettazione delle VNet.

---

# 10. Indirizzi IPv4 privati

Gli intervalli privati IPv4 principali sono:

```text
10.0.0.0/8
```

```text
172.16.0.0/12
```

```text
192.168.0.0/16
```

Vengono utilizzati nelle reti interne e non sono instradati direttamente su Internet.

Esempio domestico:

```text
PC            192.168.1.25
Smartphone    192.168.1.31
Stampante     192.168.1.50
Router        192.168.1.1
```

---

# 11. Default Gateway

Supponiamo:

```text
PC:      192.168.1.25/24
Gateway: 192.168.1.1
```

Il PC vuole comunicare con:

```text
192.168.1.80
```

È nella stessa subnet:

```text
192.168.1.0/24
```

Il traffico può rimanere nella LAN.

Se invece vuole raggiungere:

```text
8.8.8.8
```

la destinazione non è locale.

Il PC invia il traffico al:

```text
default gateway
```

Schema:

```text
192.168.1.25
     PC
      |
      | destinazione non locale
      v
192.168.1.1
   Router
      |
      v
   Internet
```

---

# 12. ARP: IP → MAC nella LAN

Quando un PC conosce l'IP di un dispositivo locale ma deve inviare un frame Ethernet, deve conoscere il MAC associato.

Il meccanismo è ARP.

Concettualmente:

```text
"Chi possiede 192.168.1.1?"
          ↓
       richiesta ARP
          ↓
"192.168.1.1 sono io.
 Il mio MAC è XX-XX-XX-XX-XX-XX"
```

ARP collega quindi il ragionamento:

```text
IP
↕
MAC
```

nella LAN IPv4.

---

# 13. DHCP

DHCP permette di assegnare automaticamente parametri di rete.

Tipicamente un client riceve:

```text
IP address
Subnet mask
Default gateway
DNS server
```

Senza DHCP sarebbe necessario configurare manualmente ogni host.

Esempio:

```text
DHCP Server
     |
     +----> PC-A 192.168.1.20
     |
     +----> PC-B 192.168.1.21
     |
     +----> PC-C 192.168.1.22
```

---

# 14. DNS

Gli utenti lavorano con nomi:

```text
www.microsoft.com
```

i computer comunicano utilizzando indirizzi IP.

DNS esegue la risoluzione:

```text
www.microsoft.com
        ↓
       DNS
        ↓
indirizzo IP
```

È essenziale distinguere:

```text
risoluzione DNS
```

da:

```text
connettività IP
```

Un nome può essere risolto correttamente anche se il servizio non è raggiungibile.

---

# 15. TCP e UDP

## TCP

TCP è orientato alla connessione.

Caratteristiche principali:

- controllo della connessione;
- affidabilità;
- ordinamento dei dati;
- ritrasmissione.

Esempi tipici:

```text
HTTPS
SSH
SMTP
```

## UDP

UDP non instaura una connessione equivalente a TCP e introduce meno overhead.

Esempi comuni:

```text
DNS
streaming
VoIP
```

Alcuni protocolli possono utilizzare TCP, UDP o entrambi a seconda dello scenario.

---

# 16. Porte TCP/UDP

L'indirizzo IP identifica un host/interfaccia.

La porta identifica un servizio/processo di rete.

Esempio:

```text
IP
192.168.1.50

porta
443

endpoint logico
192.168.1.50:443
```

Porte note:

| Servizio | Porta tipica |
|---|---:|
| HTTP | TCP 80 |
| HTTPS | TCP 443 |
| SSH | TCP 22 |
| DNS | UDP/TCP 53 |
| RDP | TCP/UDP 3389 |

Non è necessario memorizzare centinaia di porte: bisogna comprenderne il ruolo.

---

# 17. Routing

Un router usa una **routing table** per decidere dove inoltrare un pacchetto.

Esempio semplificato:

```text
Destinazione        Next hop

10.0.0.0/24         rete locale
10.1.0.0/24         Router B
0.0.0.0/0           Internet Gateway
```

La route:

```text
0.0.0.0/0
```

rappresenta normalmente la:

```text
default route
```

---

# 18. Switching

Lo switching riguarda prevalentemente la comunicazione Layer 2.

Uno switch costruisce una tabella simile a:

```text
MAC address          Porta

AA-AA-AA-AA-AA-01    Gi0/1
AA-AA-AA-AA-AA-02    Gi0/2
AA-AA-AA-AA-AA-03    Gi0/5
```

Quando conosce il MAC di destinazione, inoltra il frame verso la porta appropriata.

---

# 19. VLAN

Una VLAN permette di creare segmenti Layer 2 logicamente separati sulla stessa infrastruttura fisica di switching.

Esempio:

```text
Switch fisico
|
+-- VLAN 10  Amministrazione
|
+-- VLAN 20  Docenti
|
+-- VLAN 30  Laboratorio
```

Anche se usano lo stesso switch fisico:

```text
VLAN 10
≠
VLAN 20
```

Per comunicare tra VLAN differenti serve routing, per esempio tramite:

```text
router
```

oppure:

```text
Layer-3 switch
```

---

# 20. VLAN e subnet IP

Spesso, ma non obbligatoriamente come concetto teorico, viene associata una subnet IP distinta a ogni VLAN.

Esempio:

```text
VLAN 10
192.168.10.0/24

VLAN 20
192.168.20.0/24

VLAN 30
192.168.30.0/24
```

Schema:

```text
VLAN 10 ----------------\
                         \
                          [Router / L3 Switch]
                         /
VLAN 20 ----------------/
```

---

# 21. VLAN NON è VNet

Questa distinzione è fondamentale per Azure.

## VLAN

Tecnologia Layer 2 tipica delle reti Ethernet.

```text
VLAN
→ segmentazione Layer 2
→ switch
→ 802.1Q
```

## Azure VNet

Rete virtuale software-defined di Azure.

```text
VNet
→ rete IP logica Azure
→ subnet
→ routing
→ security controls
```

Non bisogna ragionare così:

```text
VNet = VLAN nel cloud
```

È una semplificazione eccessiva.

È meglio pensare:

```text
Rete tradizionale             Azure

rete IP                  →    VNet
subnet IP                →    Subnet
router/routing table     →    Azure routing / route table
firewall ACL             →    NSG / Azure Firewall
VPN gateway              →    VPN Gateway
```

Azure nasconde al cliente gran parte dell'infrastruttura fisica Layer 2 sottostante.

---

# 22. NAT

NAT significa:

```text
Network Address Translation
```

Permette di modificare gli indirizzi IP durante il transito.

Scenario domestico:

```text
PC
192.168.1.25
     |
     v
Router NAT
Public IP: 93.x.x.x
     |
     v
Internet
```

Molti dispositivi privati possono utilizzare un unico IP pubblico.

---

# 23. PAT / NAT Overload

Quando più connessioni condividono lo stesso IP pubblico, vengono spesso distinti anche tramite le porte.

Esempio concettuale:

```text
192.168.1.20:51001 \
                    \
192.168.1.21:51002 ----> 93.x.x.x
                    /
192.168.1.22:51003 /
```

Questo meccanismo viene spesso chiamato:

```text
PAT
```

o:

```text
NAT overload
```

---

# 24. Firewall

Un firewall decide quali flussi sono consentiti.

Esempio:

```text
Internet
   |
   v
[ Firewall ]
   |
   +---- Allow TCP 443
   |
   +---- Deny TCP 23
   |
   v
LAN / Server
```

Un firewall moderno può operare a più livelli:

```text
L3 → IP
L4 → TCP/UDP e porte
L7 → protocolli/applicazioni
```

---

# 25. DMZ

Una DMZ è un segmento di rete destinato a sistemi che devono essere maggiormente esposti o separati dalla rete interna.

Schema classico semplificato:

```text
              Internet
                  |
              Firewall
              /       \
             /         \
           DMZ          LAN interna
            |               |
        Web Server       Client / DB
```

Obiettivo:

```text
separare
```

i sistemi esposti dalla rete interna.

La DMZ non è semplicemente:

```text
"una rete dove metto i server"
```

ma una scelta architetturale di segmentazione e controllo dei flussi.

---

# 26. VPN

VPN significa:

```text
Virtual Private Network
```

Crea un tunnel protetto attraverso una rete non fidata, tipicamente Internet.

## Site-to-Site VPN

Collega due reti.

```text
Sede A
10.10.0.0/16
     |
 VPN Gateway
     ║
     ║ Internet
     ║
 VPN Gateway
     |
Sede B
10.20.0.0/16
```

## Point-to-Site VPN

Collega un singolo client a una rete remota.

```text
Laptop
   |
   ║ VPN
   |
Rete aziendale
```

In Azure questi concetti ritornano con Azure VPN Gateway.

---

# 27. Dalla rete tradizionale ad Azure

Mappa concettuale:

| Networking tradizionale | Azure |
|---|---|
| Rete IP | Virtual Network |
| Segmento/subnet | Subnet |
| Routing table | Route table / system routes |
| Router virtuale | Routing gestito da Azure |
| ACL/firewall L3-L4 | NSG |
| Firewall centralizzato | Azure Firewall |
| NIC | Network Interface |
| IP privato | Private IP |
| IP pubblico | Public IP |
| VPN concentrator/gateway | Azure VPN Gateway |
| DNS | Azure DNS / DNS configurato nella VNet |

Questa tabella serve come ponte concettuale, non come equivalenza hardware uno-a-uno.

---

# 28. Metodo generale di troubleshooting

Quando una comunicazione non funziona, evitare modifiche casuali.

Usare una sequenza.

```text
1. Interfaccia
      ↓
2. Indirizzo IP
      ↓
3. Subnet mask
      ↓
4. Default gateway
      ↓
5. DNS
      ↓
6. Routing
      ↓
7. Firewall / filtro
      ↓
8. Porta
      ↓
9. Applicazione
```

Domanda fondamentale:

```text
A quale livello smette di funzionare?
```

---

# 29. Troubleshooting guidato — singolo PC Windows

## Scenario

Un utente segnala:

> "Il PC è collegato alla rete ma non riesco ad aprire alcuni siti."

Non modifichiamo subito la configurazione.

Prima raccogliamo evidenze.

---

# 30. Passo 1 — Visualizzare la configurazione

Aprire:

```text
Prompt dei comandi
```

ed eseguire:

```cmd
ipconfig
```

Individuare la scheda attiva.

Esempio:

```text
Scheda Ethernet:

   Indirizzo IPv4. . . . . . . . . . : 192.168.1.25
   Subnet mask . . . . . . . . . . . : 255.255.255.0
   Gateway predefinito . . . . . . . : 192.168.1.1
```

Interpretazione:

```text
PC       192.168.1.25
Network  192.168.1.0/24
Gateway  192.168.1.1
```

---

# 31. Passo 2 — Visualizzare tutti i parametri

Eseguire:

```cmd
ipconfig /all
```

Cercare:

- IPv4 Address;
- Subnet Mask;
- Default Gateway;
- DHCP Enabled;
- DHCP Server;
- DNS Servers;
- MAC address / Physical Address.

Creare una piccola tabella:

| Parametro | Valore rilevato |
|---|---|
| IPv4 | ... |
| Mask | ... |
| Gateway | ... |
| DHCP | ... |
| DNS | ... |

---

# 32. Caso anomalo — indirizzo 169.254.x.x

Se il PC presenta un indirizzo simile a:

```text
169.254.45.17
```

è un segnale importante.

Può indicare che il client non ha ottenuto correttamente una configurazione IPv4 da DHCP e ha usato un indirizzo link-local/APIPA.

Schema:

```text
PC
 |
 | richiesta configurazione
 v
DHCP
 X
nessuna risposta utile
 |
 v
169.254.x.x
```

Prima ipotesi di troubleshooting:

```text
problema DHCP
oppure
problema di collegamento alla rete
```

Non è ancora una prova definitiva della causa.

---

# 33. Passo 3 — Verifica DNS con nslookup

Eseguire:

```cmd
nslookup www.microsoft.com
```

Esempio semplificato:

```text
Server:  dns-router.local
Address: 192.168.1.1

Non-authoritative answer:
Name:    www.microsoft.com
Address: 20.x.x.x
```

Questo dimostra almeno che:

```text
il client ha raggiunto un resolver DNS
+
ha ottenuto una risposta
```

Non dimostra ancora che:

```text
HTTPS verso il sito funzioni
```

---

# 34. Test diretto del DNS configurato

Eseguire:

```cmd
nslookup
```

La prima parte mostra il DNS utilizzato.

Oppure:

```cmd
nslookup www.microsoft.com 8.8.8.8
```

per interrogare esplicitamente un resolver differente, se la rete lo consente.

Confronto:

```text
DNS configurato    → fallisce
DNS alternativo    → risponde
```

può suggerire un problema legato al resolver DNS configurato.

Non cambiare però configurazioni aziendali senza autorizzazione.

---

# 35. Caso: nome non risolto

Esempio:

```cmd
nslookup server-lab
```

risultato:

```text
Non-existent domain
```

Possibili ipotesi:

- nome errato;
- record DNS assente;
- DNS server non corretto per quella zona;
- suffisso DNS mancante;
- risorsa non registrata.

La conclusione corretta non è:

```text
"la rete è guasta"
```

ma:

```text
"la risoluzione di questo nome non ha prodotto il risultato atteso"
```

---

# 36. Passo opzionale — ping

Quando consentito dalla rete:

```cmd
ping 127.0.0.1
```

verifica lo stack TCP/IP locale.

```cmd
ping <proprio-IP>
```

verifica la configurazione locale dell'interfaccia.

```cmd
ping <gateway>
```

può aiutare a verificare la raggiungibilità Layer 3 del gateway.

Attenzione:

```text
ping fallito
```

non significa sempre:

```text
host irraggiungibile
```

perché ICMP può essere filtrato.

---

# 37. Passo opzionale — tracert

Per osservare il percorso IP:

```cmd
tracert www.microsoft.com
```

Esempio concettuale:

```text
PC
 ↓
Gateway LAN
 ↓
Router ISP
 ↓
Internet
 ↓
Destinazione
```

`tracert` è utile per capire fino a dove il traffico sembra procedere, ma alcuni router possono non rispondere alle sonde.

---

# 38. Esercizio guidato completo

## Situazione

Il PC presenta:

```text
IPv4:    192.168.10.44
Mask:    255.255.255.0
Gateway: 192.168.10.1
DNS:     192.168.10.1
```

## Domanda 1

A quale rete appartiene il PC?

### Risposta

```text
192.168.10.0/24
```

---

## Domanda 2

`192.168.10.80` è locale oppure richiede il default gateway?

### Risposta

È nella stessa subnet `/24`, quindi è una destinazione locale.

---

## Domanda 3

`10.20.0.15` è locale?

### Risposta

No.

Il PC deve utilizzare una route appropriata, normalmente iniziando dal default gateway se non esiste una route più specifica.

---

## Domanda 4

Esegui:

```cmd
nslookup www.microsoft.com
```

e ricevi una risposta IP.

Puoi concludere che il sito HTTPS funziona?

### Risposta

No.

Puoi concludere che la risoluzione DNS ha funzionato.

Rimangono da verificare altri livelli:

```text
routing
firewall
TCP
porta 443
servizio remoto
```

---

# 39. Mini-scenario A — DHCP

Output:

```text
IPv4 Address: 169.254.20.18
Subnet Mask:  255.255.0.0
Default Gateway:
```

Qual è il primo sospetto?

### Risposta

Il client probabilmente non ha ricevuto una configurazione IPv4 corretta da DHCP oppure non riesce a comunicare correttamente con la rete.

Controllare prima:

```text
collegamento
Wi-Fi/Ethernet
DHCP
```

---

# 40. Mini-scenario B — DNS

Configurazione:

```text
IPv4:    192.168.1.50
Gateway: 192.168.1.1
DNS:     192.168.1.200
```

`nslookup www.microsoft.com` restituisce timeout.

Quale componente merita verifica immediata?

### Risposta

Il percorso e la disponibilità del DNS configurato:

```text
192.168.1.200
```

Non è ancora necessario modificare IP, mask o gateway se risultano coerenti.

---

# 41. Mini-scenario C — configurazione IP errata

Rete prevista:

```text
192.168.1.0/24
Gateway 192.168.1.1
```

PC:

```text
IP:      192.168.10.25
Mask:    255.255.255.0
Gateway: 192.168.1.1
```

Qual è l'anomalia?

### Risposta

Con `/24`:

```text
PC      → 192.168.10.0/24
Gateway → 192.168.1.0/24
```

PC e gateway non appartengono alla stessa subnet.

La configurazione è incoerente.

---

# 42. Checklist operativa per un singolo PC

Quando un PC ha problemi di rete:

```text
□ La scheda è attiva?
□ Ha un IPv4 valido?
□ Ha la subnet mask prevista?
□ Ha un default gateway?
□ IP e gateway sono coerenti?
□ Usa DHCP o configurazione statica?
□ Quale DNS usa?
□ nslookup restituisce una risposta?
□ Il problema è DNS o connettività?
□ Il problema riguarda tutti i servizi o uno solo?
```

Non modificare più parametri contemporaneamente.

Metodo:

```text
osserva
↓
formula un'ipotesi
↓
esegui un test
↓
modifica una sola variabile
↓
verifica nuovamente
```

---

# 43. Dal troubleshooting locale a UD05 Azure

Quanto imparato sul PC ritornerà in Azure.

```text
LAN locale                  Azure

IP address              →   Private IP
Subnet                  →   Azure Subnet
Rete                    →   VNet
Gateway/routing         →   Azure system routes / Route Table
Firewall L3-L4          →   NSG / Azure Firewall
NIC                     →   Azure Network Interface
DNS                     →   DNS configurato nella VNet
VPN                     →   Azure VPN Gateway
```

La logica di diagnosi resta simile:

```text
indirizzamento
↓
subnet
↓
DNS
↓
routing
↓
filtri
↓
porta
↓
servizio
```

---

# 44. Concetti da conoscere prima del laboratorio Azure

Prima di iniziare il laboratorio UD05 devi saper rispondere senza consultare il documento:

1. Qual è la differenza tra switch e router?
2. Qual è la differenza tra MAC e IP?
3. Che cosa significa `/24`?
4. Che cos'è il default gateway?
5. A cosa serve DHCP?
6. A cosa serve DNS?
7. Qual è la differenza tra TCP e UDP?
8. Che cos'è una porta?
9. Che cosa fa una route?
10. Che cosa fa un firewall?
11. Che cos'è una VLAN?
12. Perché VLAN e VNet non sono la stessa cosa?
13. Che cosa fa NAT?
14. Che cosa rappresenta una DMZ?
15. Qual è lo scopo di una VPN?
16. Che informazioni fornisce `ipconfig /all`?
17. Che cosa verifica `nslookup`?
18. Perché un DNS funzionante non garantisce la connettività applicativa?

---

# 45. Mappa mentale finale

```text
                           RETE
                            |
          +-----------------+-----------------+
          |                 |                 |
       Livello 2         Livello 3         Livello 4+
          |                 |                 |
     MAC / VLAN          IP / CIDR          TCP / UDP
          |                 |                 |
       Switch            Router            Porte
                            |
                 +----------+----------+
                 |                     |
              Routing                 NAT
                 |
              Gateway
                 |
        +--------+--------+
        |                 |
       DNS               VPN
        |
     Nomi → IP
```

Quando passeremo ad Azure:

```text
VNet
 ├── Subnet
 ├── NIC
 ├── Private/Public IP
 ├── NSG
 ├── Route
 ├── DNS
 └── VPN / Firewall
```

La tecnologia cambia, ma il metodo di ragionamento rimane lo stesso.
