<#
Run script for the github issues metric database. This script will
be run in a scheduled task every day
#>
#Get the base name of the script to use as the base name of the transcript file
$scriptName = $MyInvocation.MyCommand.Name.Replace(".ps1","")
$logPath = "c:\automation\logs\$scriptName.txt"
Start-Transcript -Path $logPath
c:\automation\GithubIssues.ps1 -verbose
Stop-Transcript