# Verifica — Reti virtuali e connettività

Compila `consegne/UD05/03_VERIFICA.md`. Al termine controlla il file con `git diff`, aggiungi alla staging area soltanto questa consegna e verifica il risultato con `git diff --cached`.

## Parte A — Scelta singola

1. Quale subnet è più grande?
   - A. `/26`
   - B. `/24`
   - C. sono uguali
   - D. dipende dall'NSG
2. Due VNet da collegare hanno entrambe `10.0.0.0/16`. Il problema principale è:
   - A. TLS
   - B. sovrapposizione degli indirizzi
   - C. DNS pubblico
   - D. account key
3. Tra regole NSG con priorità 200 e 300 viene valutata prima:
   - A. 300
   - B. 200
   - C. quella creata prima
   - D. quella con nome alfabeticamente minore
4. Un NSG può essere associato a:
   - A. subnet e NIC
   - B. soltanto subscription
   - C. soltanto tenant
   - D. account Storage
5. Se subnet e NIC hanno NSG, il traffico deve essere:
   - A. consentito da entrambi
   - B. consentito solo dalla NIC
   - C. consentito solo dalla subnet
   - D. sempre consentito dalla route
6. DNS serve principalmente a:
   - A. tradurre nomi in indirizzi
   - B. assegnare ruoli
   - C. filtrare porte
   - D. creare route
7. Quale strumento indica la regola che consente o nega un flusso su una VM?
   - A. Cost Analysis
   - B. IP Flow Verify
   - C. Lifecycle management
   - D. Azure Files
8. Un public IP senza servizio in ascolto e regole coerenti:
   - A. garantisce raggiungibilità
   - B. non garantisce raggiungibilità
   - C. disabilita il DNS
   - D. crea una VPN

## Parte B — Risposte brevi

9. Spiega perché le subnet devono lasciare margine di crescita.
10. Distingui NSG, route e DNS.
11. Spiega la statefulness di un NSG.
12. Perché una baseline NSG sulla subnet può essere più semplice da governare?
13. Quali verifiche sono possibili su una NIC senza VM e quale prova manca?

## Parte C — Caso situazionale

Una regola `Allow-Web` priorità 400 consente TCP 443 da `10.60.10.0/24`. Una regola `Deny-Web` priorità 150 nega TCP 443 dalla stessa origine. Il tecnico cambia il nome della prima in `AAA-Allow-Web`, ma il traffico resta negato.

14. Spiega perché il cambio di nome non modifica l'esito.
15. Proponi una correzione minima senza aprire Internet.
16. Elenca i controlli successivi se, dopo la correzione, l'applicazione resta irraggiungibile.

Controlla e prepara soltanto il file della verifica:

```bash
git diff -- consegne/UD05/03_VERIFICA.md
git add consegne/UD05/03_VERIFICA.md
git diff --cached -- consegne/UD05/03_VERIFICA.md
```

⏱
