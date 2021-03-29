for %%i in (*.appx) do powershell D:\xboxSignAppx\xboxSignAppx.ps1 "%%~snxi"
for %%i in (*.appxbundle) do powershell D:\xboxSignAppx\xboxSignAppxBundle.ps1 "%%~snxi"
for %%i in (*.msixbundle) do powershell D:\xboxSignAppx\xboxSignAppxBundle.ps1 "%%~snxi"
pause
