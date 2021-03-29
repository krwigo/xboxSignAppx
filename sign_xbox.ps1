# 2019.01.23
foreach ($file in Get-ChildItem -File "*.appx") {
	& powershell -file "D:\xboxSignAppx\xboxSignAppx.ps1" -in $file.FullName
}
foreach ($file in Get-ChildItem -File "*.appxbundle") {
	& powershell -file "D:\xboxSignAppx\xboxSignAppxBundle.ps1" -in $file.FullName
}
foreach ($file in Get-ChildItem -File "*.msixbundle") {
	& powershell -file "D:\xboxSignAppx\xboxSignAppxBundle.ps1" -in $file.FullName
}
Read-Host -Prompt "Press Enter to continue"
