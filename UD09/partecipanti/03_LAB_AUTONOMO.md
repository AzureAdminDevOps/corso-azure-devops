# UD09 — Laboratorio autonomo
## Audit di sicurezza e readiness Azure DevOps

## Obiettivo

Verificare autonomamente che l'ambiente creato nella UD09 sia:

```text
coerente
+
minimo
+
sicuro
+
riutilizzabile
```

---

# Attività 1 — Organization e Project

Documenta:

```text
Organization:
Project:
Visibility:
Source repository:
```

Rispondi:

1. perché il Project è privato?
2. perché il source repository rimane GitHub?

---

# Attività 2 — Matrice gruppi

Completa:

| Gruppo | Scopo essenziale | Lo assegneresti a tutti? Perché? |
|---|---|---|
| Project Administrators | | |
| Contributors | | |
| Readers | | |
| Build Administrators | | |

---

# Attività 3 — GitHub integration readiness

Da WSL2:

```bash
cd ~/workspace/azure-devops-lab

gh auth status
gh repo view --json nameWithOwner,url,isPrivate
git fetch
```

Documenta:

```text
repository:
private:
gh auth:
git fetch:
```

Rispondi:

1. perché in UD09 non abbiamo creato una service connection GitHub OAuth/PAT?
2. quale metodo useremo quando creeremo la prima pipeline GitHub?
3. perché evitare di duplicare il repository in Azure Repos?

---

# Attività 4 — Parallel jobs

Documenta:

```text
Microsoft-hosted:
Self-hosted:
```

Scenario:

> Microsoft-hosted = 0, self-hosted = 1.

Rispondi:

1. il corso è bloccato?
2. quanti job self-hosted possono essere eseguiti contemporaneamente con un solo parallel job?
3. registrare 3 agent aumenta automaticamente a 3 i job concorrenti?

---

# Attività 5 — Agent audit

Verifica:

```text
pool:
agent:
status:
version:
```

Capability:

```text
Agent.OS:
Agent.Version:
git:
python:
```

---

# Attività 6 — Audit dell'autenticazione di registrazione

Se hai usato un PAT, verifica in:

```text
User settings
→ Personal access tokens
```

che:

```text
ud09-agent-registration
```

sia `Revoked` oppure non più attivo.

Se hai usato Device Code Flow, annota:

```text
PAT: N/A
Registration: Device Code Flow
```

Rispondi:

1. perché l'agent resta Online anche dopo la revoca del PAT?
2. perché non serve un PAT Full access?
3. perché Device Code Flow è un fallback migliore rispetto ad allargare una policy PAT?

---

# Attività 7 — Test Offline/Online

Nel terminale agent:

```text
Ctrl+C
```

Verificare nel portale:

```text
Offline
```

Poi, nel terminale dedicato all'agent:

```bash
cd "$HOME/azdo-agent"
./run.sh
```

Verificare:

```text
Online
```

Lasciare quel terminale occupato dal processo. Per compilare la consegna o svolgere altri comandi usare il secondo terminale WSL2.

Non riconfigurare l'agent.

---

# Attività 8 — Troubleshooting scenario

Scenario:

```text
Agent configurato ma Offline.
```

Costruisci una checklist nell'ordine:

1. processo `run.sh`;
2. rete/HTTPS;
3. Organization URL;
4. pool;
5. directory agent/configurazione;
6. diagnostica.

Comando disponibile:

```bash
cd ~/azdo-agent
./run.sh --diagnostics
```

Non eseguire rimozione/re-registrazione come prima azione.

---

# Attività 9 — Readiness finale

Assegna:

```text
PASS
```

oppure:

```text
FAIL
```

a ogni voce:

| Controllo | Stato |
|---|---|
| Organization | |
| Private Project | |
| GitHub integration readiness | |
| Hosted status documentato | |
| Self-hosted pool | |
| Agent Online | |
| PAT revocato / Device Code Flow | |
| Capability controllate | |
| Restart Online/Offline testato | |
| Nessun segreto nel repository | |

Se una voce è `FAIL`, scrivi:

```text
causa
→ azione correttiva
→ verifica
```
