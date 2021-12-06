#Ubuntu
Set-Location /home/auditor/inspec
. /home/auditor/SEC557Labs/Functions.ps1

inspec exec ./aws-foundations-cis-baseline/ -t aws:// --reporter cli json:aws.json
Convert-InspecResults -FileName ./aws.json `
    -MetricPath benchmark.infrastructure.aws `
    -DateRun (Get-Date).ToShortDateString() | 
    nc -vv -N ubuntu 2003


