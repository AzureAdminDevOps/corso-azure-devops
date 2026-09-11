# UD05 — Reti virtuali e connettività

La VNet è già stata creata una prima volta dal portale in UD02; verrà quindi ricreata da CLI. Il primo NSG, la prima regola personalizzata e la prima interfaccia di rete saranno invece configurati dal portale, spiegando campo, priorità e associazione prima di ripetere le operazioni da CLI.

## Percorso dell'unità

| Fascia | Attività |
|---|---|
| 09:00–11:00 | VNet, subnet, CIDR, IP, DNS, NSG, priorità, statefulness, routing, peering, VPN e bilanciamento |
| 11:15–11:55 | Approfondimento guidato dei concetti: progettazione e valutazione di un flusso |
| 11:55–13:00 | Laboratorio guidato: VNet e subnet da CLI, primo NSG e prima regola dal portale |
| 14:00–16:00 | Associazioni, prima NIC dal portale, seconda da CLI, regole e route effettive, modifica controllata |
| 16:15–17:10 | Laboratorio autonomo con guasto intenzionale |
| 17:10–17:35 | Verifica individuale |
| 17:35–18:00 | Cleanup, controllo dei costi, evidenza e commit |

## Ordine dei materiali e delle consegne

1. Nel repository personale crea `consegne/UD05` e copia i quattro file presenti in `partecipanti/modelli`:

   ```bash
   cd ~/workspace/azure-devops-lab
   mkdir -p consegne/UD05
   cp ~/workspace/corso-azure-devops/UD05/partecipanti/modelli/*.md consegne/UD05/
   ```

2. Studia `00_CONCETTI.md` e inserisci le risposte richieste in `consegne/UD05/00_DOMANDE_CONCETTI.md`.
3. Esegui `02_LAB_GUIDATO.md` e documenta piano di indirizzamento, NSG e verifiche in `consegne/UD05/01_LAB_GUIDATO.md`.
4. Svolgi `03_LAB_AUTONOMO.md` e compila `consegne/UD05/02_LAB_AUTONOMO.md`.
5. Completa `04_VERIFICA.md` in `consegne/UD05/03_VERIFICA.md`.

I modelli pubblicati con il materiale del corso rimangono invariati; si lavora soltanto sulle copie del repository personale.

## Consegne richieste

```text
azure-devops-lab/
└── consegne/
    └── UD05/
        ├── 00_DOMANDE_CONCETTI.md
        ├── 01_LAB_GUIDATO.md
        ├── 02_LAB_AUTONOMO.md
        └── 03_VERIFICA.md
```

Non pubblicare subscription ID, object ID, indirizzi pubblici personali o dati estranei al laboratorio.
