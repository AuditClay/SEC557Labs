#Run on Ubuntu host in pwsh
Set-Location /home/auditor/SEC557Labs/Lab1.3
./tableDemo.ps1 | mysql -pPassword1
./tableDemoGraphite.ps1 | nc -vv -N ubuntu 2003
