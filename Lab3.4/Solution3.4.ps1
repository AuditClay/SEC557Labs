#In PowerShell Core on Ubuntu

Set-Location /home/auditor/inspec/
. /home/auditor/SEC557Labs/Functions.ps1

$password = ConvertTo-SecureString "Password1!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList("auditor",$password)

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
$vmwareCred = Get-Secret -Name vmware
$esxiUser = $vmwareCred.UserName
$esxiPassword = $vmwareCred.GetNetworkCredential().Password

inspec exec vmware-esxi-6.5-stig-baseline -t "vmware://$esxiuser`:$esxiPassword@10.50.7.31" --reporter=cli json:esxi.json

Convert-InspecResults -FileName ./esxi.json -MetricPath benchmark.vmware.esxi1 -DateRun (Get-Date).ToShortDateString() | nc -vv -N ubuntu 2003

