Get-ChildItem -Path "C:\" -Recurse -ErrorAction SilentlyContinue |
Where-Object {
    -not $_.PSIsContainer -and
    $_.Length -gt 1GB -and
    $_.LastWriteTime -ge (Get-Date).Date.AddDays(-1) -and
    $_.LastWriteTime -lt (Get-Date).Date
} |
Select-Object FullName, @{Name="Größe (GB)";Expression={[math]::Round($_.Length/1GB,2)}}, LastWriteTime |
Sort-Object Length -Descending