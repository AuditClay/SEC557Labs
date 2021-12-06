#Run on Ubuntu host in pwsh
Set-Location /home/auditor/SEC557Labs/Lab1.4/
./PyramidData.ps1 | nc -vv -N ubuntu 2003