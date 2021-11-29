<#
Run script for the github issues metric database. This script will
be run in a scheduled task every day
#>
#Dot-source the file of automation utility functions
. c:\automation\AutomationFunctions.ps1

#Get the base name of the script to use as the base name of the transcript file
$scriptName = $MyInvocation.MyCommand.Name.Replace(".ps1","")
$logPath = "c:\automation\logs\$scriptName.txt"

#Delete any previous copies of the log file - just keep one run
Remove-Item $logPath -Force -ErrorAction SilentlyContinue
Start-Transcript -Path $logPath

c:\automation\GithubIssues.ps1 -verbose | 
    Send-TCPData -RemoteHost "ubuntu" -RemotePort 2003 -Verbose

Stop-Transcript