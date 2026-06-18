function newrepo {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )

    $basePath = "C:\GitHub"
    $localPath = Join-Path $basePath $Name
    $githubUser = "Reinhold-Gr"   # <- falls du Organisation willst: "AktivSenioren"

    # Ordner anlegen
    if (-not (Test-Path $localPath)) {
        dbg "Erstelle lokalen Ordner: $localPath"
        New-Item -ItemType Directory -Path $localPath | Out-Null
    }

    Set-Location $localPath

    # Git initialisieren
    if (-not (Test-Path "$localPath\.git")) {
        dbg "Initialisiere Git-Repository"
        git init | Out-Null
    }

    # Erste Datei erzeugen, falls leer
    if (-not (Get-ChildItem $localPath)) {
        dbg "Erstelle README.md"
        "## $Name" | Out-File "$localPath\README.md"
    }

    # Commit
    dbg "Erster Commit"
    git add .
    git commit -m "Initial commit for $Name" | Out-Null

    # Remote setzen
    $remoteUrl = "https://github.com/$githubUser/$Name.git"
    dbg "Setze Remote: $remoteUrl"
    git remote add origin $remoteUrl

    # Push
    dbg "Push nach GitHub"
    git branch -M main
    git push -u origin main

    dbg "Repository erfolgreich erstellt!"
    Write-Host "GitHub URL: $remoteUrl"
}
