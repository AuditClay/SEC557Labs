#From PowerShell Core on Ubuntu
Set-Location /home/auditor/inspec/
. /home/auditor/SEC557Labs/Functions.ps1

inspec exec ./microsoft-windows-10-stig-baseline -t winrm://auditor@10.50.7.101 --port 5985 --password Password1 --input-file /home/auditor/win10input.yml --reporter cli json:win10Results.json

Convert-InspecResults -FileName ./win10Results.json -MetricPath benchmark.windows.win10 `
 -DateRun (Get-Date).ToShortDateString() | nc -vv -N ubuntu 2003

inspec exec ./microsoft-windows-server-2016-stig-baseline -t winrm://auditor@10.50.7.10:5985 --password Password1 --reporter cli json:winDC.json

Convert-InspecResults -FileName ./winDC.json -MetricPath 'benchmark.windows.windc' | nc -vv -N ubuntu 2003
