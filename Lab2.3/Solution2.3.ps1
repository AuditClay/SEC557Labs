
Set-Location C:\Users\auditor\SEC557Labs\Lab2.3\

$ghcred = Get-Credential -Message "Enter your GitHub credentials"

$HistoryDays = 90

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
    $nextPage = Invoke-RestMethod -Method Get -Credential $ghcred -Uri $uri
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


















# Set-Location C:\SEC557\Lab2.1

# #Set the location of the files
# $keyFile = ".\keyFile"
# $tokenFile = ".\githubToken"

# #Create a new key byte array and fill it
# $Key = New-Object Byte[] 16
# [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)

# #Send to the key file
# $Key | Out-File $keyFile

# #Use the encryption key to encrypt the password and dump the encrypted password to a file
# $Password = Read-Host -AsSecureString "Paste in GitHub Token"

# $Password | ConvertFrom-SecureString -Key $Key | Out-File $tokenFile

# #Retrieving data from the files
# $keyFile = ".\keyFile"
# $tokenFile = ".\githubToken"
# #Grab the key/token, decrypt the password and store it in a credentials object
# $key = Get-Content $keyFile
# $token = Get-Content $tokenFile

# $githubUsername = Read-Host "Enter your github username"

# $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $githubUsername, ($token | ConvertTo-SecureString -Key $key)

# #last 3 months in UTC time
# $since = (Get-Date -Date (Get-Date).addDays(-90) -Format "yyyyMMddTHHmmssZ" -Hour 0 -Minute 0 -Second 0 -Millisecond 0)

# $issues = $null
# #Counter variables
# $page = -1
# $count = 100

# #Loop until you receive < 100 results on the page
# while ( $count -eq 100)
# {  
#     $page++
#     "Processing page: $page"

#     #Set the URL for the request, plugging in $page as the page number
#     $uri = "https://api.github.com/repos/PowerShell/PowerShell/issues?page=$page&per_page=100&state=closed&since=$since"

#     #Get the next page and add the contents to the $issues variable
#     $nextPage = Invoke-RestMethod -Credential $cred -Uri $uri
#     $count = $nextPage.count
#     $issues += $nextPage
# }

# "Importing:"
# $issues | 
#   Select-Object @{n='ClosedDate'; e={Get-Date -Date $_.closed_at -Hour 0 -Min 0 -Second 0 -Millisecond 0 -AsUTC -UFormat %s}} | 
#   Group-Object ClosedDate | 
#   Foreach {"issues.closed " + $_.count.ToString() + " " +$_.Name.ToString()}


# $issues | 
#   Select-Object @{n='ClosedDate'; e={Get-Date -Date $_.closed_at -Hour 0 -Min 0 -Second 0 -Millisecond 0 -AsUTC -UFormat %s}} | 
#   Group-Object ClosedDate | 
#   Foreach {"issues.closed " + $_.count.ToString() + " " +$_.Name.ToString()} | 
#   wsl nc -vv -N 10.50.7.50 2003

#   $MTTR = ($issues | 
#   Select-Object @{n='TimeToResolve'; e={(New-TimeSpan -Start (Get-Date -date $_.created_at) -End ($_.closed_at)).TotalDays} } | 
#   Measure-Object -Property TimeToResolve -Average).Average


# "Importing: issues.mttr $MTTR " + (Get-Date -Hour 0 -Min 0 -Second 0 -Millisecond 0 -AsUTC -UFormat %s)
# "issues.mttr $MTTR " + (Get-Date -Hour 0 -Min 0 -Second 0 -Millisecond 0 -AsUTC -UFormat %s) | 
#   wsl nc -vv -N 10.50.7.50 2003
