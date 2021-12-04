#In pwsh on Ubuntu

#Add Ubuntu to the pach dashboard
Set-Location /home/auditor
. /home/auditor/SEC557Labs/Functions.ps1
($lines | Where-Object { $_ -match "^[0-9]" }) -replace " .*$" | 
    Group-Object | 
    Convert-PatchVelocity -MetricPath patchvelocity.ubuntu | 
    nc -N -vv 10.50.7.50 2003
   
$lastPatchDate = ($lines | 
    Where-Object { $_ -match "^[0-9]" }) -replace " .*$"  | 
    Select-Object -last 1
$patchAge = (New-TimeSpan -Start (Get-Date -date $lastPatchDate) `
    -End (Get-Date)).TotalDays

$epochTime = Get-date -Date $lastPatchDate -AsUTC -UFormat %s
$hostname = (hostname)

"patchage.$hostname $patchAge $epochTime" | nc -N -vv 10.50.7.50 2003


#Inspec Benchmarks
Set-Location /home/auditor/inspec
inspec exec ./cis-dil-benchmark/ --reporter cli json:ubuntu.json

Convert-InspecResults -FileName ./ubuntu.json `
    -MetricPath 'benchmark.linux.ubuntu' `
    -DateRun (Get-Date).ToShortDateString() | 
    nc -vv -N 10.50.7.50 2003