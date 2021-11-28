<#
This script retrieves multiple days of closed issue data from GitHub to ingest into a Graphite database. 
It is intended to be run daily through a scheduled task.
#>
#Comdlet binding allows the script to see the Verbosity settings from the caller.
#Useful for using write-verbose in the script.

[cmdletbinding()]
param (
    [int]$HistoryDays = 90
)

function Get-SinceDate{
    [CmdletBinding()]
    param (
        [int]$HistoryDays = 90
    )

    $returnValue = Get-Date -Date (Get-Date).addDays(-$HistoryDays) -AsUtc -Format "yyyyMMddTHHmmssZ" `
        -Hour 0 -Minute 0 -Second 0 -Millisecond 0
    Write-Verbose "Setting -since date to $returnValue"
    return $returnValue
}

#Read the GitHub credentials from the PowerShell secret store
$ghcred = Get-Secret -Name GitHub

Write-Verbose "Retrieving GitHub credentials"
if( $null -eq $ghcred) {
    Throw "Credentials not found. Aborting"
}

$resultsPerPage = 100
$since = Get-SinceDate -HistoryDays 90  
$uri = "https://api.github.com/repos/PowerShell/PowerShell/issues?"
$uri += "page=0&per_page=$resultsPerPage&state=closed&since=$since"
$issues = $null

#Counter variables
#Which page are we loading, gets incremented in the loop, so start at -1
$page = -1
#Count how many results have been returned overall
$count = 100

#Loop until you receive < $resultsPerPage results on the page
while ( $count -eq $resultsPerPage)
{  
    $page++
    Write-Verbose "Processing page: $page"
    
    #Set the URL for the request, plugging in $page as the page number
    $uri = "https://api.github.com/repos/PowerShell/PowerShell/issues?"
    $uri += "page=$page&per_page=$resultsPerPage&state=closed&since=$since"

    #Get the next page and add the contents to the $issues variable
    $nextPage = Invoke-RestMethod -Credential $cred -Uri $uri
    $count = $nextPage.count
    Write-Verbose "$count results returned in this query"
    $issues += $nextPage
}
Write-Verbose "${$issues.count} issues retrieved for the last $HistoryDays days"

#Dump the issues to the pipeline in Graphite import format
$issues | 
  Select-Object @{n='ClosedDate'; e={Get-Date -Date $_.closed_at -Hour 0 -Min 0 -Second 0 -Millisecond 0 -AsUTC -UFormat %s}} | 
  Group-Object ClosedDate | 
  Foreach {"issues.closed " + $_.count.ToString() + " " +$_.Name.ToString()}