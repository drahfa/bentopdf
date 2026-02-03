Get-ChildItem -Path "D:\GitHub\bentopdf\public\locales" -Directory | ForEach-Object {
    $jsonFile = Join-Path $_.FullName "common.json"
    if (Test-Path $jsonFile) {
        $content = Get-Content $jsonFile -Raw
        $updatedContent = $content -replace '"copyright"\s*:\s*"([^"]*?)BentoPDF([^"]*)"', '"copyright": "$1SitiPDF$2"'
        Set-Content -Path $jsonFile -Value $updatedContent
        Write-Host "Updated: $($_.Name)"
    }
}
