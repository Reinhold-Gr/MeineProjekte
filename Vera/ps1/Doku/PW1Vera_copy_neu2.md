# PW1Vera_copy_neu2 – PowerShell Automation Script

Dieses PowerShell‑Skript automatisiert das **Mounten zweier VeraCrypt‑Container**, führt eine **Whitelist‑Prüfung** der zweiten Festplatte durch und startet anschließend einen **Robocopy‑Sync** zwischen den gemounteten Laufwerken.

Es unterstützt einen **Dry‑Run‑Modus**, erzeugt detaillierte **Logfiles** und enthält robuste Fehlerbehandlung.

---

## 🚀 Features

- Mount von **Container 1** auf Laufwerk `P:`
- Whitelist‑Validierung der Seriennummer von Laufwerk 2
- Mount von **Container 2** auf Laufwerk `Q:`
- Automatischer **Robocopy‑Sync** (`P:` → `Q:`)
- **DryRun‑Modus** (`-DryRun`) für gefahrloses Testen  
  → Robocopy wird simuliert (`/L`)
- Ausführliches Logging mit Zeitstempeln
- Timeout‑Überwachung für Mount‑Vorgänge

---

## 📁 Verzeichnisstruktur

/VERA
-  PW1Vera_copy_neu2.ps1
-   Whitelist_LW-PW.json
---
/Logs
-   MountPW1_YYYYMMDD_HHMMSS.log
-    Robocopy_20260604_141000.log
---


## ⚙️ Parameter

### `-DryRun`

Führt alle Schritte aus, **aber ohne echte Dateiänderungen**.

- VeraCrypt‑Mounts werden **real** ausgeführt  
- Robocopy läuft mit `/L` → **nur Simulation**

Beispiel:

```powershell
.\PW1Vera_copy_neu2.ps1 -DryRun


🔐 Whitelist

Die Datei Whitelist_LW-PW.json enthält erlaubte Seriennummern:

json
{
    "AllowedSerials": [
        "1234567890ABCDEF",
        "0987654321FEDCBA"
    ]
}
Nur wenn die Seriennummer des zweiten Laufwerks enthalten ist, wird Container 2 gemountet.

🔄 Ablauf
Logfile initialisieren

Whitelist laden

Benutzer fragt nach Laufwerk 1

Mount Container 1 → P:

Benutzer fragt nach Laufwerk 2

Seriennummer prüfen

Mount Container 2 → Q:

Robocopy‑Sync starten

Abschlussmeldung

📝 Logging
Alle Schritte werden in einem Logfile gespeichert:

Code
Logs/MountPW1_YYYYMMDD_HHMMSS.log

Beispielauszug:

Code
[2026-06-04 12:10:31] [INFO] PowerShell-Version: 7.6.2
[2026-06-04 12:10:31] [INFO] DryRun: True
[2026-06-04 12:10:36] [STEP] Mounting VeraCrypt-Container 1...
[2026-06-04 12:10:52] [OK] Laufwerk P: erfolgreich erkannt.