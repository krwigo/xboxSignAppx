param (
    [string]$In,
    [string]$Pw = '1234'
    )

$fileName = Split-Path $In -Leaf
$tempDir = $env:TEMP + '\' + $fileName

# 2018.07.23 signing with openssl instead of makecert without password prompt
# ref https://serverfault.com/a/573038
$env:Path += ";C:\xboxSignAppx"

# 2018.10.19
$env:Path += ";D:\xboxSignAppx"
# $env:Path += ";D:\xboxSignAppx8.1"
# $env:Path += ";D:\xboxSignAppx8.1\openssl-1.0.2o-x64_86-win64"
# $env:Path += ";C:\Program Files (x86)\Windows Kits\10\bin\10.0.18272.0\x64"
# $env:Path += ";C:\Program Files (x86)\Windows Kits\10\bin\10.0.18290.0\x64"
# $env:Path += ";C:\Program Files (x86)\Windows Kits\10\bin\10.0.17134.0\x64"
# $env:Path += ";C:\Program Files (x86)\Windows Kits\10\bin\x64"
# $env:Path += ";C:\Program Files (x86)\Windows Kits\8.1\bin\x64"

# 2018.11.28 sdk 17682,18272 adds support for "UAPAugmentedBinaryXbox_*.msixbundle" files.
# ref https://www.tenforums.com/windows-10-news/111839-msix-support-introduced-windows-10-insider-build-17682-a.html
# note: $In is a DOS short name; $Out = $In -Replace "msixbundle$","appxbundle"
# $env:Path += ";C:\Program Files (x86)\Windows Kits\10\bin\10.0.18272.0\x64"
# $env:Path += ";C:\Program Files (x86)\Windows Kits\10\bin\10.0.18272.0\x64"
# $env:Path += ";C:\Program Files (x86)\Windows Kits\10\bin\10.0.18290.0\x64"
# $env:Path += ";C:\Program Files (x86)\Windows Kits\10\bin\10.0.17134.0\x64"

# 2019.01.23 find windows sdk automatically
$p = Get-Childitem -Path "C:\Program Files (x86)\Windows Kits\10\bin" -Filter "signtool.exe" -File -Recurse -ErrorAction SilentlyContinue |Where-Object {$_.FullName -like "*x64*"} |Sort-Object desc |Select-Object -First 1 -Expand Directory
$env:Path += ";"+$p

Remove-Item $tempDir -Recurse -Force -ErrorAction Ignore
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::ExtractToDirectory($In, $tempDir)

$xmlPath = $tempDir + '\' + 'AppxManifest.xml'

[xml]$xml = Get-Content $xmlPath
$publisher = $xml.Package.Identity.Publisher

$tempDirPvk = $tempDir + '\' + 'MyKey.pvk'
$tempDirCer = $tempDir + '\' + 'MyKey.cer'
$tempDirPfx = $tempDir + '\' + 'MyKey.pfx'

# & 'C:\Program Files (x86)\Windows Kits\8.1\bin\x64\makecert.exe' /n $publisher /r /h 0 /eku "1.3.6.1.5.5.7.3.3,1.3.6.1.4.1.311.10.3.13" /sv $tempDirPvk $tempDirCer
# & 'C:\Program Files (x86)\Windows Kits\8.1\bin\x64\pvk2pfx.exe' /pvk $tempDirPvk /pi $Pw /spc $tempDirCer /pfx $tempDirPfx /po $Pw -f
# & 'C:\Program Files (x86)\Windows Kits\8.1\bin\x64\signtool.exe' sign /fd SHA256 /a /f $tempDirPfx /p $Pw $In

$configPublisher = ([regex]"CN=([a-zA-Z0-9\-]+)").Match($publisher).Groups[1]
$configFile = $tempDir + '\openssl_config'
Set-Content -Path $configFile -Value @"
[ req ]
prompt = no
distinguished_name = my dn
[ my dn ]
commonName = $($configPublisher)
[ myserverexts ]
extendedKeyUsage = 1.3.6.1.5.5.7.3.3,1.3.6.1.4.1.311.10.3.13
"@

& openssl.exe req -x509 -config $configFile -extensions 'myserverexts' -nodes -days 365 -newkey rsa:2048 -keyout $tempDirPvk -out $tempDirCer
& openssl.exe pkcs12 -export -out $tempDirPfx -inkey $tempDirPvk -in $tempDirCer -passout pass:$Pw
& signtool.exe sign /fd SHA256 /v /a /f $tempDirPfx /p $Pw $In

# xbox does not accept msixbundle files
$fn = Get-Childitem $In |Select-Object -Expand FullName
$tg = $fn -Replace "msixbundle$","appxbundle"
Rename-Item -Path $In -NewName $tg

# add cert to system for sideloading
# Start-Process powershell -Verb runAs -ArgumentList "& certutil.exe -addStore Root $($tempDirCer)" -WindowStyle Minimized
# Start-Process powershell -Verb runAs -ArgumentList "& certutil.exe -addStore TrustedPeople $($tempDirCer)" -WindowStyle Minimized
