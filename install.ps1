# Dployr installeren of bijwerken:  irm https://dployr.nl/install.ps1 | iex
#
# Haalt de nieuwste release van github.com/punneke/dployr op, controleert de installer
# tegen SHA256SUMS.txt uit dezelfde release en installeert hem stil voor deze gebruiker
# (geen beheerdersrechten). Daarna werkt Dployr zichzelf bij.
#
# Alles gaat over https naar GitHub; namen en adressen uit het antwoord van GitHub worden
# eerst gecontroleerd en nooit als commando uitgevoerd.

& {
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'   # Invoke-WebRequest is veel sneller zonder voortgangsbalk
    # Windows PowerShell 5.1 kent TLS 1.2 niet altijd vanzelf.
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    $repo = 'punneke/dployr'
    $downloads = "https://github.com/$repo/releases/download/"
    $setup = $null
    $sums = $null

    try {
        Write-Host 'Nieuwste versie van Dployr opzoeken...'
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest" -Headers @{ 'User-Agent' = 'dployr-install' }
        $version = [string]$release.tag_name
        if ($version -notmatch '^v\d+\.\d+\.\d+$') { throw "Onverwachte versie in de release: '$version'." }

        $asset = $release.assets | Where-Object { $_.name -match '^[\w.-]+_x64-setup\.exe$' } | Select-Object -First 1
        $list = $release.assets | Where-Object { $_.name -eq 'SHA256SUMS.txt' } | Select-Object -First 1
        if (-not $asset -or -not $list) { throw "Release $version mist de installer of SHA256SUMS.txt." }
        foreach ($a in @($asset, $list)) {
            if (-not ([string]$a.browser_download_url).StartsWith($downloads + $version + '/')) {
                throw "Onverwachte downloadlocatie: $($a.browser_download_url)"
            }
        }

        $setup = Join-Path $env:TEMP $asset.name
        $sums = Join-Path $env:TEMP "dployr-$version-SHA256SUMS.txt"
        Write-Host "Dployr $version downloaden..."
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $setup -UseBasicParsing
        Invoke-WebRequest -Uri $list.browser_download_url -OutFile $sums -UseBasicParsing

        # Regel "<sha256>  <bestandsnaam>", zoals sha256sum hem schrijft.
        $pattern = "^([0-9a-fA-F]{64})\s+\*?$([regex]::Escape($asset.name))\s*$"
        $line = Get-Content -LiteralPath $sums | Where-Object { $_ -match $pattern } | Select-Object -First 1
        if (-not $line) { throw "SHA256SUMS.txt noemt $($asset.name) niet." }
        $expected = ([regex]::Match($line, $pattern)).Groups[1].Value.ToUpperInvariant()
        $actual = (Get-FileHash -Algorithm SHA256 -Path $setup).Hash.ToUpperInvariant()
        if ($actual -ne $expected) { throw "De installer komt niet overeen met SHA256SUMS.txt (verwacht $expected, gekregen $actual). Er is niets geinstalleerd." }
        Write-Host 'Checksum klopt.'

        Write-Host 'Installeren...'
        $process = Start-Process -FilePath $setup -ArgumentList '/S' -Wait -PassThru
        if ($process.ExitCode -ne 0) { throw "De installer stopte met code $($process.ExitCode)." }
        Write-Host "Dployr $version is geinstalleerd. Je vindt het in het Start-menu; bijwerken doet de app voortaan zelf." -ForegroundColor Green
    }
    catch {
        Write-Host "Dployr installeren is mislukt: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        foreach ($file in @($setup, $sums)) {
            if ($file -and (Test-Path -LiteralPath $file)) { Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue }
        }
    }
}
