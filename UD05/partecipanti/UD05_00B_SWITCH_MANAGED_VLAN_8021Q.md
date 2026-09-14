# UD05 — Managed Switch, VLAN e tagging 802.1Q
## Introduzione semplice con esempi e configurazione Cisco-like

Questo documento affianca il ripasso sui fondamenti di rete.

Obiettivo:

- capire che cosa distingue uno **switch managed** da uno switch non gestito;
- capire perché si usano le **VLAN**;
- distinguere porte **access** e **trunk**;
- comprendere il tagging **IEEE 802.1Q**;
- vedere un esempio di **Router-on-a-Stick**;
- eseguire configurazioni CLI in stile Cisco;
- avere una base utile prima di affrontare subnet, VNet, NSG e routing in Azure.

---

# 1. Switch non gestito e switch managed

## Switch non gestito

Uno switch non gestito lavora in modo semplice:

```text
PC1 ----\
         \
PC2 ------ [ SWITCH ] ------ Stampante
         /
PC3 ----/
```

Colleghiamo i dispositivi e lo switch inoltra i frame Ethernet.

Non possiamo normalmente configurare:

- VLAN;
- trunk;
- priorità;
- monitoraggio;
- sicurezza delle porte;
- Spanning Tree avanzato;
- gestione remota.

## Switch managed

Uno **switch managed** può essere configurato.

Esempi di funzionalità:

```text
VLAN
Trunk
Port Access
STP
Port Security
QoS
SNMP
Management IP
Logging
```

Schema:

```text
                 Managed Switch
                 +-------------+
PC Amm. -------- | VLAN 10     |
PC Docenti ----- | VLAN 20     |
PC Lab --------- | VLAN 30     |
                 +-------------+
```

Lo stesso apparato fisico può quindi ospitare reti logiche differenti.

---

# 2. Perché usare le VLAN

Senza VLAN, tutti i dispositivi collegati allo stesso switch appartengono normalmente allo stesso dominio Layer 2.

Con le VLAN possiamo separare logicamente gruppi diversi:

```text
                    Managed Switch
                 +------------------+
PC-A ----------- | VLAN 10          |
PC-B ----------- | VLAN 10          |
                 |                  |
PC-C ----------- | VLAN 20          |
PC-D ----------- | VLAN 20          |
                 +------------------+
```

Anche se sono collegati allo stesso switch:

```text
VLAN 10
≠
VLAN 20
```

I dispositivi delle due VLAN non comunicano direttamente a livello 2.

Per comunicare tra VLAN serve routing.

---

# 3. VLAN e subnet IP

Una scelta comune è associare una subnet IP diversa a ogni VLAN.

```text
VLAN 10 - Amministrazione - 192.168.10.0/24
VLAN 20 - Docenti        - 192.168.20.0/24
VLAN 30 - Laboratorio    - 192.168.30.0/24
```

Schema:

```text
VLAN 10              VLAN 20              VLAN 30
192.168.10.0/24      192.168.20.0/24      192.168.30.0/24

   PC-A                  PC-B                  PC-C
     |                     |                     |
     +----------[ Managed Switch ]--------------+
```

Le VLAN sono separate a livello 2. Per farle comunicare serve un dispositivo Layer 3.

---

# 4. Porte Access

Una porta **access** appartiene normalmente a una sola VLAN.

```text
PC-A
 |
 | frame Ethernet normale
 |
Switch port
Access VLAN 10
```

Il PC non deve conoscere il numero della VLAN: è la porta dello switch ad associare il traffico alla VLAN.

Configurazione Cisco-like:

```text
enable
configure terminal

interface gigabitEthernet 0/1
 switchport mode access
 switchport access vlan 10
 no shutdown
```

---

# 5. Creazione delle VLAN

```text
enable
configure terminal

vlan 10
 name AMMINISTRAZIONE

vlan 20
 name DOCENTI

vlan 30
 name LABORATORIO
```

Verifica:

```text
show vlan brief
```

Output concettuale:

```text
VLAN Name             Ports
---- ---------------- ----------------
10   AMMINISTRAZIONE  Gi0/1, Gi0/2
20   DOCENTI          Gi0/3, Gi0/4
30   LABORATORIO      Gi0/5, Gi0/6
```

---

# 6. Configurazione semplice delle porte Access

## PC amministrazione

```text
interface gigabitEthernet 0/1
 switchport mode access
 switchport access vlan 10
```

## PC docente

```text
interface gigabitEthernet 0/3
 switchport mode access
 switchport access vlan 20
```

## PC laboratorio

```text
interface gigabitEthernet 0/5
 switchport mode access
 switchport access vlan 30
```

---

# 7. Collegare due switch: serve un trunk

Supponiamo di avere due switch:

```text
PC-A -- Switch 1 -------- Switch 2 -- PC-B
```

Se dobbiamo trasportare VLAN 10, 20 e 30 tra i due switch, non vogliamo usare un cavo separato per ogni VLAN.

Serve un collegamento:

```text
TRUNK
```

---

# 8. Porta Trunk

Una porta trunk può trasportare traffico appartenente a più VLAN.

```text
                TRUNK
          VLAN 10,20,30
Switch 1 ================= Switch 2
```

Il problema è: come fa lo switch ricevente a capire a quale VLAN appartiene ogni frame?

La risposta è:

```text
tagging 802.1Q
```

---

# 9. IEEE 802.1Q

IEEE 802.1Q definisce il tagging delle VLAN nei frame Ethernet.

Concettualmente:

```text
Frame Ethernet originale

[ MAC DST ][ MAC SRC ][ DATA ]
```

Su un trunk:

```text
[ MAC DST ][ MAC SRC ][ 802.1Q TAG ][ DATA ]
```

Nel tag è presente, tra le altre informazioni, il **VLAN ID**.

```text
Frame VLAN 10 → tag VLAN ID 10
Frame VLAN 20 → tag VLAN ID 20
```

---

# 10. Schema del tagging

```text
PC-A
VLAN 10
  |
  | frame non taggato
  v
Switch 1
  |
  | aggiunge tag VLAN 10
  |
  |=========== TRUNK ===========|
                              Switch 2
                                  |
                                  | rimuove il tag
                                  v
                                PC-B
                              VLAN 10
```

Il PC normalmente non vede il tag. Lo switch gestisce l'associazione tra porta e VLAN.

---

# 11. Access vs Trunk

| Porta | Trasporta | Tag 802.1Q |
|---|---|---|
| Access | una VLAN | normalmente no verso il client |
| Trunk | più VLAN | sì |
| Trunk Native VLAN | una VLAN può essere non taggata | dipende dalla configurazione |

Regola mentale:

```text
PC / stampante / server semplice
→ porta Access
```

```text
Switch ↔ Switch
Switch ↔ Router
Switch ↔ Hypervisor
→ spesso porta Trunk
```

---

# 12. Configurare un trunk

```text
interface gigabitEthernet 0/24
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30
 no shutdown
```

Verifica:

```text
show interfaces trunk
```

---

# 13. Allowed VLAN

Non è sempre necessario trasportare tutte le VLAN.

```text
switchport trunk allowed vlan 10,20
```

Sul trunk passano solo VLAN 10 e VLAN 20.

Aggiungere VLAN 30:

```text
switchport trunk allowed vlan add 30
```

---

# 14. Native VLAN

In un trunk 802.1Q può essere configurata una **native VLAN**.

```text
interface gigabitEthernet 0/24
 switchport mode trunk
 switchport trunk native vlan 99
```

Per questo corso è sufficiente ricordare:

```text
trunk → normalmente traffico taggato
native VLAN → eccezione possibile
```

I due lati del trunk devono avere configurazioni coerenti.

---

# 15. Comunicazione dentro la stessa VLAN

```text
PC-A
192.168.10.10/24
VLAN 10

PC-B
192.168.10.20/24
VLAN 10
```

```text
PC-A
 |
 | access VLAN 10
 |
Switch
 |
 | access VLAN 10
 |
PC-B
```

I due host possono comunicare direttamente a livello 2, senza router.

---

# 16. Comunicazione tra VLAN diverse

```text
PC-A 192.168.10.10/24 VLAN 10
PC-B 192.168.20.10/24 VLAN 20
```

Non possono comunicare direttamente.

Serve **inter-VLAN routing**, per esempio tramite:

```text
Router
```

oppure:

```text
Layer 3 Switch
```

---

# 17. Router-on-a-Stick

Il **Router-on-a-Stick** permette di fare routing tra più VLAN usando una sola interfaccia fisica del router.

```text
                   Router
                     |
                     | Gi0/0
                     | trunk 802.1Q
                     |
              +--------------+
              | Managed      |
              | Switch       |
              +--------------+
               /            \
              /              \
      Access VLAN 10      Access VLAN 20
          |                    |
         PC-A                  PC-B
```

---

# 18. Subinterface

Sul router vengono create interfacce logiche:

```text
Gi0/0.10
Gi0/0.20
Gi0/0.30
```

Ogni subinterface è associata a una VLAN.

```text
interface gigabitEthernet 0/0.10
 encapsulation dot1Q 10
 ip address 192.168.10.1 255.255.255.0
```

```text
interface gigabitEthernet 0/0.20
 encapsulation dot1Q 20
 ip address 192.168.20.1 255.255.255.0
```

---

# 19. Configurazione completa Router-on-a-Stick

## Switch

```text
enable
configure terminal

vlan 10
 name AMMINISTRAZIONE

vlan 20
 name DOCENTI
```

Porte client:

```text
interface gigabitEthernet 0/1
 switchport mode access
 switchport access vlan 10
```

```text
interface gigabitEthernet 0/2
 switchport mode access
 switchport access vlan 20
```

Porta verso router:

```text
interface gigabitEthernet 0/24
 switchport mode trunk
 switchport trunk allowed vlan 10,20
```

## Router

```text
interface gigabitEthernet 0/0
 no shutdown
```

```text
interface gigabitEthernet 0/0.10
 encapsulation dot1Q 10
 ip address 192.168.10.1 255.255.255.0
```

```text
interface gigabitEthernet 0/0.20
 encapsulation dot1Q 20
 ip address 192.168.20.1 255.255.255.0
```

---

# 20. Gateway dei client

PC VLAN 10:

```text
IP:      192.168.10.10
Mask:    255.255.255.0
Gateway: 192.168.10.1
```

PC VLAN 20:

```text
IP:      192.168.20.10
Mask:    255.255.255.0
Gateway: 192.168.20.1
```

---

# 21. Flusso di un pacchetto tra VLAN

```text
192.168.10.10
        ↓
destinazione 192.168.20.10
        ↓
rete differente
        ↓
Default Gateway 192.168.10.1
        ↓
Router
        ↓
Routing
        ↓
VLAN 20
        ↓
192.168.20.10
```

---

# 22. Layer 3 Switch

In reti più strutturate, il routing tra VLAN può essere effettuato direttamente da uno switch Layer 3 usando SVI.

```text
interface vlan 10
 ip address 192.168.10.1 255.255.255.0
 no shutdown
```

```text
interface vlan 20
 ip address 192.168.20.1 255.255.255.0
 no shutdown
```

Poi:

```text
ip routing
```

Per questo corso è sufficiente comprendere il concetto.

---

# 23. Management IP dello switch

Uno switch managed può avere un indirizzo IP di gestione.

Esempio:

```text
VLAN 99 MANAGEMENT
192.168.99.0/24
```

Switch:

```text
192.168.99.10
```

Configurazione Cisco-like:

```text
interface vlan 99
 ip address 192.168.99.10 255.255.255.0
 no shutdown
```

```text
ip default-gateway 192.168.99.1
```

Questo IP serve per gestione remota, SSH, GUI, SNMP e monitoraggio. Non è necessario per il normale switching Layer 2.

---

# 24. Comandi di verifica principali

VLAN:

```text
show vlan brief
```

Trunk:

```text
show interfaces trunk
```

Porta:

```text
show interfaces gigabitEthernet 0/1 switchport
```

MAC table:

```text
show mac address-table
```

Configurazione:

```text
show running-config
```

Interfacce:

```text
show interfaces status
```

Routing:

```text
show ip route
```

---

# 25. Troubleshooting semplice VLAN

Scenario:

```text
PC-A VLAN 10
non raggiunge
PC-B VLAN 10
```

Checklist:

```text
1. Il link è up?
2. Entrambe le porte sono access?
3. Entrambe sono nella VLAN 10?
4. La VLAN 10 esiste?
5. Gli IP appartengono alla stessa subnet?
6. La subnet mask è corretta?
```

Comandi:

```text
show vlan brief
show interfaces status
show mac address-table
```

---

# 26. Troubleshooting semplice trunk

Scenario:

```text
PC-A VLAN 20 su Switch 1
non raggiunge
PC-B VLAN 20 su Switch 2
```

Checklist:

```text
1. Il trunk è attivo?
2. VLAN 20 esiste su entrambi gli switch?
3. VLAN 20 è allowed sul trunk?
4. Le porte dei PC sono access VLAN 20?
```

Comandi:

```text
show interfaces trunk
show vlan brief
```

---

# 27. Troubleshooting Router-on-a-Stick

Checklist:

```text
1. Le VLAN esistono?
2. Le porte client sono nella VLAN corretta?
3. La porta switch-router è trunk?
4. VLAN 10 e 20 sono allowed sul trunk?
5. Le subinterface esistono?
6. encapsulation dot1Q usa il VLAN ID corretto?
7. Gli IP gateway sono corretti?
8. I client usano il gateway giusto?
```

Router:

```text
show ip interface brief
show running-config
show ip route
```

---

# 28. Errori tipici

## Porta access nella VLAN sbagliata

Errato:

```text
interface Gi0/1
 switchport access vlan 20
```

Se il PC deve stare in VLAN 10:

```text
interface Gi0/1
 switchport access vlan 10
```

## VLAN non permessa sul trunk

```text
switchport trunk allowed vlan 10,20
```

VLAN 30 non passa.

Correzione:

```text
switchport trunk allowed vlan add 30
```

## Subinterface sbagliata

Errato:

```text
interface Gi0/0.20
 encapsulation dot1Q 30
 ip address 192.168.20.1 255.255.255.0
```

Corretto:

```text
interface Gi0/0.20
 encapsulation dot1Q 20
```

---

# 29. Dove si usano le VLAN

Le VLAN sono comuni in:

```text
reti aziendali
campus
scuole
datacenter
VoIP
Wi-Fi enterprise
virtualizzazione
```

Esempio:

```text
VLAN 10 → utenti
VLAN 20 → server
VLAN 30 → telefoni VoIP
VLAN 40 → guest Wi-Fi
VLAN 99 → management
```

---

# 30. VLAN nei sistemi virtualizzati

```text
               Trunk 802.1Q
Switch ============================= Hypervisor
                                    |
                                    +-- VM VLAN 10
                                    |
                                    +-- VM VLAN 20
                                    |
                                    +-- VM VLAN 30
```

---

# 31. VLAN e Wi-Fi enterprise

```text
SSID Aziendale → VLAN 10
SSID Guest     → VLAN 40
```

L'uplink dell'Access Point verso lo switch può essere un trunk.

---

# 32. VLAN e sicurezza

Una VLAN introduce segmentazione Layer 2, ma non è da sola una soluzione completa di sicurezza.

Per controllare il traffico tra VLAN si utilizzano ACL, firewall o altre policy Layer 3/4.

```text
VLAN 10
   |
   | routing
   v
Firewall / ACL
   |
   v
VLAN 20
```

---

# 33. VLAN e Azure VNet

Non confondere i due concetti.

```text
VLAN
→ Layer 2
→ Ethernet
→ switch
→ 802.1Q
```

```text
Azure VNet
→ rete IP virtuale Azure
→ subnet
→ routing
→ NSG
```

Mappa concettuale:

| On-premises | Azure |
|---|---|
| VLAN + subnet | subnet Azure dentro VNet |
| router/L3 switch | routing Azure |
| ACL | NSG |
| firewall | Azure Firewall |
| VPN concentrator | VPN Gateway |

Sono analogie utili, non equivalenze hardware perfette.

---

# 34. Esercizio guidato semplice

Scenario:

```text
VLAN 10 AMMINISTRAZIONE 192.168.10.0/24
VLAN 20 DOCENTI        192.168.20.0/24
```

PC-A:

```text
192.168.10.10/24
Gateway 192.168.10.1
```

PC-B:

```text
192.168.20.10/24
Gateway 192.168.20.1
```

## Passo 1 — creare VLAN

```text
enable
configure terminal

vlan 10
 name AMMINISTRAZIONE

vlan 20
 name DOCENTI
```

## Passo 2 — porte client

```text
interface Gi0/1
 switchport mode access
 switchport access vlan 10
```

```text
interface Gi0/2
 switchport mode access
 switchport access vlan 20
```

## Passo 3 — trunk verso router

```text
interface Gi0/24
 switchport mode trunk
 switchport trunk allowed vlan 10,20
```

## Passo 4 — router

```text
interface Gi0/0
 no shutdown
```

```text
interface Gi0/0.10
 encapsulation dot1Q 10
 ip address 192.168.10.1 255.255.255.0
```

```text
interface Gi0/0.20
 encapsulation dot1Q 20
 ip address 192.168.20.1 255.255.255.0
```

## Passo 5 — verificare

Switch:

```text
show vlan brief
show interfaces trunk
```

Router:

```text
show ip interface brief
show ip route
```

Client:

```text
ping 192.168.10.1
ping 192.168.20.1
```

Poi provare comunicazione PC-A → PC-B.

---

# 35. Domande finali di autoverifica

1. Che cosa distingue uno switch managed da uno unmanaged?
2. A cosa serve una VLAN?
3. Che cosa significa porta Access?
4. Che cosa significa porta Trunk?
5. Perché serve il tagging 802.1Q?
6. Che cosa identifica il VLAN ID?
7. Perché due VLAN diverse non comunicano direttamente?
8. Che cos'è il Router-on-a-Stick?
9. Che cos'è una subinterface?
10. A cosa serve `encapsulation dot1Q 10`?
11. Perché il gateway della VLAN 10 può essere `192.168.10.1`?
12. Che differenza c'è tra VLAN e VNet?
13. Quali comandi useresti per verificare VLAN e trunk?
14. Che cosa controlleresti se una VLAN non passa su un trunk?

---

# 36. Mappa mentale finale

```text
                 MANAGED SWITCH
                        |
        +---------------+---------------+
        |                               |
      ACCESS                           TRUNK
        |                               |
    una VLAN                      più VLAN
        |                               |
 frame non taggato                802.1Q tag
                                        |
                                        v
                                  VLAN ID
```

Inter-VLAN:

```text
VLAN 10
   \
    \
     Router / L3 Switch
    /
   /
VLAN 20
```

Router-on-a-Stick:

```text
VLAN 10 ----\
             \
              [ Switch ]
             /
VLAN 20 ----/
              ||
              || trunk 802.1Q
              ||
            [ Router ]
           Gi0/0.10
           Gi0/0.20
```

Concetto fondamentale:

```text
VLAN
→ segmentazione Layer 2

802.1Q
→ identifica la VLAN sul trunk

Router
→ comunica tra reti/VLAN diverse
```
