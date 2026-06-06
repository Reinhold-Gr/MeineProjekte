# ============================================
# Mount-PW1Vera.ps1  für V7
# PowerShell-Version des Batch-Skripts
# .\Scripte_PS\PW1Vera.ps1
# ============================================
Write-Host "Version: $($PSVersionTable.PSVersion)"

if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "Starte neu in PowerShell 7..."
    & pwsh.exe -File $PSCommandPath
    exit
}

# Laufwerksbuchstaben abfragen
$LW = Read-Host "Bitte Laufwerksbuchstaben eingeben (z.B. D)"

# Benutzer-Umgebungsvariable lesen
$pw = [System.Environment]::GetEnvironmentVariable("PW-1_Vera", "User")

if ([string]::IsNullOrWhiteSpace($pw)) {
    Write-Host "FEHLER: Benutzer-Variable 'PW-1_Vera' ist nicht gesetzt!" -ForegroundColor Red
    exit 1
}

# VeraCrypt-Pfad
$vc = "C:\Program Files\VeraCrypt\VeraCrypt.exe"

# Prüfen ob VeraCrypt existiert
if (-not (Test-Path $vc)) {
    Write-Host "FEHLER: VeraCrypt wurde nicht gefunden unter: $vc" -ForegroundColor Red
    exit 1
}

# Containerpfad
$container = "$LW`:\Start_PW\_PW.hc"

# VeraCrypt ausführen
& $vc /v $container /l P /a /p $pw /q /e /m rm

Write-Host "VeraCrypt wurde ausgeführt." -ForegroundColor Green
Pause
