# Dployr

Dployr is een Windows-app om sites te deployen over SSH, per site en omgeving (test,
accept, productie). Je ziet per omgeving wat er op de server staat en wat Bitbucket
nieuwer heeft, deployt met een preview en controles vooraf, volgt de uitvoer live en
opent een terminal in de map van de site.

Deze repository bevat alleen de releases: de installer, zijn handtekening, `latest.json`
voor de updater en `SHA256SUMS.txt`. De broncode is privé.

## Installeren

In PowerShell:

```powershell
irm https://dployr.nl/install.ps1 | iex
```

Het script ([install.ps1](install.ps1)) haalt de nieuwste release op, controleert de
installer tegen `SHA256SUMS.txt` en installeert Dployr voor jouw gebruiker, zonder
beheerdersrechten. Dployr staat daarna in het Start-menu.

Of download `Dployr_<versie>_x64-setup.exe` zelf van de
[releases-pagina](https://github.com/punneke/dployr/releases/latest) en start hem. De
installer is (nog) niet met een certificaat ondertekend, dus Windows SmartScreen meldt
"Windows heeft uw pc beschermd". Kies **Meer info** en dan **Toch uitvoeren**.

## Bijwerken

Dat doet Dployr zelf: bij het starten en daarna elk uur kijkt de app of er een nieuwe
versie is, downloadt die en installeert hem pas als de handtekening klopt. Je kiest zelf
wanneer ("Bijwerken en herstarten" in de Toolbox), of het gebeurt bij de volgende start.
