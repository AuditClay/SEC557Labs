#Run on Win10
"Ensure that the 557WinDC VM is running..."
Set-Location C:\Users\auditor\SEC557Labs\Lab3.3\
$password = ConvertTo-SecureString "Password1" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList("auditor",$password)

.\ADDemographics.ps1 -Credential $cred -Server 10.50.7.10 | 
  wsl nc -N -vv ubuntu 2003

