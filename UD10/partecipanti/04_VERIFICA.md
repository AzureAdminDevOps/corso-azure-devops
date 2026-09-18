# UD10 — Verifica individuale

## Parte A — Scelta singola

### 1. Una Docker image è:

- A. un processo in esecuzione
- B. un artefatto usato per creare container
- C. una VNet
- D. un volume Windows

### 2. Nel comando `docker build -f docker/backend.Dockerfile .`, il punto finale rappresenta:

- A. la porta
- B. il build context
- C. il tag
- D. il registry

### 3. `EXPOSE 8000`:

- A. pubblica automaticamente la porta sull'host
- B. documenta la porta prevista nell'immagine ma non sostituisce `-p`
- C. crea un NSG
- D. crea una rete

### 4. `127.0.0.1:8080:80` significa:

- A. host 80 → container 8080
- B. host 127.0.0.1:8080 → container 80
- C. backend → frontend
- D. DNS → volume

### 5. In Compose, due servizi sulla stessa rete possono normalmente raggiungersi tramite:

- A. IP statico obbligatorio
- B. nome del servizio
- C. subscription ID
- D. tag Git

### 6. Dentro il container frontend, `localhost` indica:

- A. sempre il backend
- B. il container frontend stesso
- C. l'host Windows
- D. Azure

### 7. `docker compose down -v`:

- A. conserva tutti i volumi
- B. rimuove anche i volumi del progetto
- C. fa push delle immagini
- D. crea container

### 8. Un container `running`:

- A. è necessariamente healthy
- B. può essere running ma unhealthy
- C. non produce log
- D. non appartiene a una rete

---

## Parte B — Risposte brevi

### 9. Distingui image, container e registry.

### 10. Spiega perché il build context dovrebbe essere limitato.

### 11. Distingui named volume e bind mount.

### 12. Perché le variabili d'ambiente permettono di riusare la stessa immagine?

### 13. Perché il backend Compose non deve necessariamente pubblicare una porta sull'host?

### 14. Quali comandi useresti per iniziare il troubleshooting di uno stack Compose che non risponde?

---

## Parte C — Scenario

> `docker compose ps` mostra frontend Running e backend Restarting. Il browser restituisce 502. Nei log backend compare `LOW_STOCK_THRESHOLD deve essere un intero, ricevuto: 'abc'`.

### 15. Qual è la causa più probabile e qual è la modifica minima?

### 16. È necessario ricostruire l'immagine? Quali verifiche eseguiresti dopo la correzione?

### 17. Una futura pipeline gira su `pool-ud09-wsl` e lo step `docker build` fallisce con errore di connessione al Docker daemon. Quale componente dell'ambiente controlleresti per primo e perché?

### 18. Distingui, rispetto alla disponibilità dei tool, un self-hosted Agent da un Microsoft-hosted Agent.

---

# Dopo la verifica — Cleanup finale della UD10

Questa sezione va eseguita soltanto dopo aver salvato le risposte della verifica.

## 1. Tornare allo stack

```bash
export LAB_REPO="$HOME/workspace/azure-devops-lab"
cd "$LAB_REPO/app/catalogo-prodotti"
```

Verificare lo stato:

```bash
docker compose ps
docker volume ls
docker image ls --filter reference='catalog-*'
```

## 2. Rimuovere container e rete, conservando temporaneamente il volume

```bash
docker compose down
```

Verificare che il named volume esista ancora:

```bash
docker volume ls
```

Questo conferma operativamente la differenza tra `down` e `down -v`.

## 3. Eliminare anche il volume del progetto

```bash
docker compose down -v
```

Verificare:

```bash
docker compose ps -a
docker volume ls
```

## 4. Rimuovere le immagini didattiche UD10

```bash
docker image rm \
  catalog-backend:ud10 \
  catalog-frontend:ud10
```

Se Docker segnala che un'immagine è ancora utilizzata, controllare:

```bash
docker ps -a
```

e individuare il container residuo invece di usare subito `--force`.

## 5. Non usare cleanup globale

Non eseguire:

```bash
docker system prune -a --volumes
```

perché potrebbe eliminare risorse appartenenti ad altri progetti.

Il cleanup della UD10 deve essere mirato alle sole risorse create dal laboratorio.

