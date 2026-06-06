<#
    Mount-PW1Vera_copy_neu2.ps1
    Final Version 2026-06-03
#>

param(
    [switch]$DryRun
)

# ============================================
# Logging-Funktion
# ============================================
function Write-Log {
    param(
        [string]$Message,
        [string]$Type = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] [$Type] $Message"
    Add-Content -Path $global:LogFile -Value $logLine
    Write-Host $logLine
}

# ============================================
# Logfile initialisieren
# ============================================
$LogDir = "$PSScriptRoot\Logs"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }

$global:LogFile = "$LogDir\MountPW1_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

Write-Log "PowerShell-Version: $($PSVersionTable.PSVersion)"
Write-Log "DryRun: $DryRun"

Write-Log "=== VeraCrypt + Sync-Prozedur gestartet ===" "STEP"

# ============================================
# VeraCrypt Pfad
# ============================================
$vc = "C:\Program Files\VeraCrypt\VeraCrypt.exe"

# ============================================
# Whitelist laden
# ============================================
$WhitelistFile = "$PSScriptRoot\Whitelist_LW-PW.json"

if (-not (Test-Path $WhitelistFile)) {
    Write-Log "Whitelist-Datei nicht gefunden: $WhitelistFile" "ERROR"
    exit 10
}

try {
    $Whitelist = Get-Content $WhitelistFile -Raw | ConvertFrom-Json
    $allowedSerials = $Whitelist.AllowedSerials
    Write-Log "Whitelist erfolgreich geladen. Anzahl erlaubter Seriennummern: $($allowedSerials.Count)" "INFO"
}
catch {
    Write-Log "Fehler beim Laden der Whitelist-Datei!" "ERROR"
    exit 11
}


# Benutzer-Umgebungsvariable lesen
$pw = [System.Environment]::GetEnvironmentVariable("PW-1_Vera", "User")

if ([string]::IsNullOrWhiteSpace($pw)) {
    Write-Host "FEHLER: Benutzer-Variable 'PW-1_Vera' ist nicht gesetzt!" -ForegroundColor Red
    exit 1
}

# ============================================
# Laufwerk 1 (Container 1)
# ============================================
$LW1 = Read-Host "Bitte erstes Laufwerk eingeben (z.B. C)"
Write-Log "Eingabe Laufwerk 1: $LW1"

$container1 = "$LW1`:\Start_PW\_PW.hc"

Write-Log "Mounting VeraCrypt-Container 1..." "STEP"

# VeraCrypt ausführen
& $vc /v $container1 /l P /a /p $pw /q /e /m rm


# Warte-Schleife für P:
$timeout = 15
$elapsed = 0

Write-Log "Warte auf Mount von P: ..." "INFO"

while ($elapsed -lt $timeout) {
    if (Get-PSDrive P -ErrorAction SilentlyContinue) {
        Write-Log "Laufwerk P: erfolgreich erkannt." "OK"
        break
    }
    Start-Sleep -Milliseconds 500
    $elapsed += 0.5
}

if (-not (Get-PSDrive P -ErrorAction SilentlyContinue)) {
    Write-Log "FEHLER: Laufwerk P: wurde nicht gemountet (Timeout)!" "ERROR"
    exit 2
}

# ============================================
# Laufwerk 2 (Whitelist-Prüfung)
# ============================================
$LW2 = Read-Host "Bitte zweites Laufwerk eingeben (z.B. G)"
Write-Log "Eingabe Laufwerk 2: $LW2"

$disk = Get-Partition -DriveLetter $LW2 -ErrorAction SilentlyContinue | Get-Disk

if ($null -eq $disk) {
    Write-Log "Laufwerk $LW2 existiert nicht!" "ERROR"
    exit 3
}

$serial = $disk.SerialNumber.Trim()
Write-Log "Gefundene Seriennummer: $serial"

if ($allowedSerials -contains $serial) {
    Write-Log "Laufwerk ist in der Whitelist erlaubt." "OK"
}
else {
    Write-Log "Falsches Laufwerk! Seriennummer nicht in Whitelist." "ERROR"
    exit 3
}

# ============================================
# Mount Container 2
# ============================================
$container2 = "$LW2`:\Start_PW\_PW.hc"

Write-Log "Mounting VeraCrypt-Container 2..." "STEP"
# VeraCrypt ausführen
& $vc /v $container2 /l Q /a /p $pw /q /e /m rm

# Warte-Schleife für Q:
$timeout = 15
$elapsed = 0

Write-Log "Warte auf Mount von Q: ..." "INFO"

while ($elapsed -lt $timeout) {
    if (Get-PSDrive Q -ErrorAction SilentlyContinue) {
        Write-Log "Laufwerk Q: erfolgreich erkannt." "OK"
        break
    }
    Start-Sleep -Milliseconds 500
    $elapsed += 0.5
}

if (-not (Get-PSDrive Q -ErrorAction SilentlyContinue)) {
    Write-Log "FEHLER: Laufwerk Q: wurde nicht gemountet (Timeout)!" "ERROR"
    exit 2
}

# ============================================
# Robocopy Sync
# ============================================
Write-Log "Starte Robocopy-Sync..." "STEP"

# Robocopy Logfile
$roboLog = "$LogDir\Robocopy_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

$roboFlags = "/MIR /FFT /R:2 /W:2 /NP /TEE /LOG:$roboLog"

if ($DryRun) { $roboFlags += " /L" }

$cmd = "robocopy P:\ Q:\ *.* $roboFlags"

Write-Log "Robocopy-Befehl: $cmd" "INFO"

cmd.exe /c $cmd

Write-Log "Robocopy abgeschlossen." "OK"

# ============================================
# Fertig
# ============================================
Write-Log "=== Vorgang abgeschlossen ===" "STEP"

# ============================================
# Abfrage: Q: dismounten?
# ============================================
$antwort = Read-Host "Soll das Laufwerk Q: dismountet werden? (J/N)"

if ($antwort -match '^(J|j|Y|y)') {
    Write-Log "Dismount von Q: wird ausgeführt..." "STEP"
    & $vc /d Q /q
    Start-Sleep -Seconds 1

    if (-not (Get-PSDrive Q -ErrorAction SilentlyContinue)) {
        Write-Log "Laufwerk Q: erfolgreich dismountet." "OK"
    }
    else {
        Write-Log "WARNUNG: Laufwerk Q: konnte nicht dismountet werden." "ERROR"
    }
}
else {
    Write-Log "Dismount von Q: wurde vom Benutzer übersprungen." "INFO"
}
