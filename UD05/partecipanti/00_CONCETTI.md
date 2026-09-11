# Concetti — Reti virtuali e connettività

## 1. Una VNet è un confine logico

Azure Virtual Network offre uno spazio IP privato nel quale collocare interfacce e servizi integrabili. La VNet non è una VLAN fisica e non genera traffico da sola: indirizzi, route e filtri diventano osservabili quando esistono risorse collegate.

Ogni VNet possiede uno o più prefissi CIDR. Le subnet ritagliano porzioni non sovrapposte dello spazio. Una subnet deve essere abbastanza ampia per crescita e indirizzi riservati da Azure; non si dimensiona soltanto per le risorse presenti oggi.

## 2. Leggere il CIDR

In IPv4, `/24` lascia 8 bit per gli indirizzi del blocco, quindi contiene 256 indirizzi complessivi; Azure ne riserva alcuni in ogni subnet. `/26` contiene 64 indirizzi complessivi. Un prefisso più alto indica una rete più piccola.

Esempio:

| Elemento | CIDR | Relazione |
|---|---|---|
| VNet | `10.40.0.0/16` | spazio complessivo |
| web | `10.40.10.0/24` | interno alla VNet |
| data | `10.40.20.0/24` | interno e non sovrapposto |

Gli spazi di VNet da collegare tramite peering o VPN non devono sovrapporsi. La [guida di pianificazione Microsoft](https://learn.microsoft.com/azure/virtual-network/virtual-network-vnet-plan-design-arm) richiama unicità e dimensionamento dei prefissi.

## 3. IP privato e pubblico

Un IP privato instrada all'interno di reti collegate. Un public IP rende possibile un endpoint pubblico solo quando è associato a una risorsa che ascolta e quando NSG, route e sistema operativo consentono il flusso. “Ha un IP pubblico” non equivale a “è raggiungibile”.

Nel laboratorio non creeremo public IP: non sono necessari per comprendere segmentazione e regole e riduciamo superficie esposta e risorse da gestire.

## 4. DNS

Azure fornisce risoluzione DNS predefinita nella VNet. In scenari aziendali possono essere configurati DNS personalizzati o Azure DNS Private Resolver. DNS traduce nomi in indirizzi; non autorizza il traffico e non sostituisce route o NSG.

## 5. Network Security Group

Un NSG contiene regole inbound e outbound che consentono o negano traffico in base a origine, destinazione, porta e protocollo. Può essere associato a subnet, NIC o entrambe.

Le regole hanno priorità da 100 a 4096. Il numero più basso viene valutato prima; alla prima corrispondenza l'elaborazione termina. Le regole predefinite hanno priorità più bassa, cioè numeri più alti, e non possono essere eliminate, ma possono essere superate da regole personalizzate. La [panoramica NSG Microsoft](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview) descrive valutazione e default.

Gli NSG sono stateful: se un flusso è consentito in una direzione, il traffico di risposta del flusso non richiede una regola speculare. Questo non autorizza una nuova connessione indipendente nella direzione opposta.

## 6. Subnet o NIC?

Un NSG sulla subnet applica una baseline a tutte le NIC collegate. Un NSG sulla NIC applica un filtro specifico. Quando entrambi esistono, il traffico deve essere consentito da entrambi; una regola `Allow` in uno non annulla un `Deny` nell'altro.

Per ambienti semplici privilegeremo una baseline sulla subnet, evitando combinazioni difficili da diagnosticare. Nel lavoro reale la scelta deve essere coerente e documentata.

## 7. Service tag e porte

Un service tag rappresenta gruppi di prefissi gestiti da Microsoft, per esempio `VirtualNetwork`, `Internet` o servizi Azure supportati. Riduce la manutenzione rispetto a elenchi IP manuali, ma non esprime automaticamente l'intento applicativo.

Aprire `Any` da `Internet` su tutte le porte non è una scorciatoia accettabile. Una regola deve specificare protocollo, porta, origine e scope minimi coerenti con il servizio.

## 8. Routing

Azure crea route di sistema per ogni subnet. Una route associa un prefisso di destinazione a un next hop. Le user-defined route permettono di modificare percorsi, per esempio verso un'appliance, ma una route errata può rendere irraggiungibile un servizio anche quando l'NSG consente il traffico.

Il troubleshooting deve separare almeno:

```text
risoluzione nome → route → NSG → endpoint/porta → servizio in ascolto
```

## 9. Peering, VPN e load balancing

Il peering collega VNet tramite backbone Microsoft, purché gli spazi non si sovrappongano. VPN Gateway collega reti tramite tunnel cifrati e comporta provisioning e costo. Load Balancer distribuisce traffico di livello 4; Application Gateway lavora a livello applicativo HTTP/HTTPS. Questi servizi vengono inquadrati, non creati nel laboratorio.

## 10. Diagnostica

Network Watcher include strumenti come IP Flow Verify, NSG diagnostics, Next Hop e Connection Troubleshoot. Molti richiedono una VM o un endpoint supportato. In questa UD useremo regole effettive e route effettive sulle NIC come verifica preventiva; in UD06, dopo aver creato la VM, completeremo il test di flusso reale. La [panoramica Network Watcher](https://learn.microsoft.com/azure/network-watcher/network-watcher-overview) chiarisce lo scopo degli strumenti.

⏱

## 11. Domande di controllo

Inserisci le risposte motivate in `consegne/UD05/00_DOMANDE_CONCETTI.md`.

1. Perché due VNet da collegare non devono avere CIDR sovrapposti?
2. Quale rete è più grande, `/24` o `/26`, e perché?
3. Perché un public IP non garantisce raggiungibilità?
4. Come viene scelta una regola NSG tra più corrispondenti?
5. Che cosa significa che un NSG è stateful?
6. Perché un `Allow` sulla NIC non supera un `Deny` applicabile sulla subnet?
7. Qual è la differenza tra DNS, routing e NSG?
8. Perché IP Flow Verify verrà completato dopo la creazione della VM?

⏱
