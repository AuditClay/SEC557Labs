<#
This script retrieves multiple days of closed issue data from GitHub to ingest into a Graphite database. 
It is intended to be run daily through a scheduled task.
#>
#CmdletBinding allows the script to see the Verbosity settings from the caller.
#Useful for using write-verbose in the script.

#Accept HistoryDays from the user, in case they want to override the number of days retrieved
[cmdletbinding()]
param (
    [int]$HistoryDays = 90
)

#Get a date in the ISO format required by Github for the earliest closed issue date
#Default value is 90 days worth of data, for the 90-day mean time to resolution
#required by management
function Get-SinceDate{
    [CmdletBinding()]
    param (
        [int]$HistoryDays = 90
    )

    #Calculate the date into a variable so we can output it in the verbose output
    $returnValue = Get-Date -Date (Get-Date).addDays(-$HistoryDays) -AsUtc -Format "yyyyMMddTHHmmssZ" `
        -Hour 0 -Minute 0 -Second 0 -Millisecond 0
    #If the user added the -verbose switch parameter to the script invocation
    #then use write-verbose for debugging/informational messages
    Write-Verbose "Setting -since date to $returnValue"
    #Return the "since" date to the caller. the "return" keyword is optional
    return $returnValue
}

#Read the GitHub credentials from the calling user's PowerShell secret store
Write-Verbose "Retrieving GitHub credentials"
$ghcred = Get-Secret -Name GitHub

#Validate the credentials are not null, and throw an exception if they are, since the
#authenticated API access would fail
if( $null -eq $ghcred) {
    Throw "Credentials not found. Aborting"
}

#Github issues API returns a maximum of 100 issues per results "page"
$resultsPerPage = 100

#Get the start date for data to be returned by issues API in ISO format
$since = Get-SinceDate -HistoryDays 90  

#Create the URI for the REST GET call
$uri = "https://api.github.com/repos/PowerShell/PowerShell/issues?"
$uri += "page=0&per_page=$resultsPerPage&state=closed&since=$since"

#Instantiate an empty variable to store the results returned from the API
$issues = $null

#Counter variables
#Which page we are  loading; gets incremented inside the while loop, so start at -1
$page = -1
#Count how many results have been returned on this call. Set initially to
# $resultsPerPage to allow entry into the while loop
$count = $resultsPerPage

#Loop until you receive < $resultsPerPage results on the page
while ( $count -eq $resultsPerPage)
{  
    #increment the page counter
    $page++
    Write-Verbose "Processing page: $page"
    
    #Set the URL for the request, plugging in $page as the page number
    $uri = "https://api.github.com/repos/PowerShell/PowerShell/issues?"
    $uri += "page=$page&per_page=$resultsPerPage&state=closed&since=$since"

    #Get the next page and add the contents to the $issues variable
    $nextPage = Invoke-RestMethod -Method Get -Credential $cred -Uri $uri
    $count = $nextPage.count
    Write-Verbose "$count results returned in this query"
    #Add the issues returned by this request to the array of results
    $issues += $nextPage
}
Write-Verbose "$($issues.count) issues retrieved for the last $HistoryDays days"

#Dump the issues closed per day to the pipeline in Graphite import format. One day
#per line
$issues | 
    Select-Object @{n='ClosedDate'; e={Get-Date -Date $_.closed_at -Hour 0 -Min 0 -Second 0 -Millisecond 0 -AsUTC -UFormat %s}} | 
    Group-Object ClosedDate | 
    Foreach-Object {"issues.closed " + $_.count.ToString() + " " +$_.Name.ToString()}

#Dump the 90-day MTTR to the pipeline in Graphite import format
$MTTR = ($issues | 
    Select-Object @{n='TimeToResolve'; e={(New-TimeSpan -Start (Get-Date -date $_.created_at) -End ($_.closed_at)).TotalDays} } | 
    Measure-Object -Property TimeToResolve -Average).Average

"issues.mttr $MTTR " + (Get-Date -Hour 0 -Min 0 -Second 0 -Millisecond 0 -AsUTC -UFormat %s)