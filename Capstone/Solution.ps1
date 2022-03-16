[cmdletbinding()]
param(
    [Switch]$GraphiteImport
)

Set-Location C:\users\auditor\SEC557Labs\Capstone\
.\Generate-Capstone.ps1

# Store an epoch time for all metrics
$epochTime = Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0 -AsUTC -UFormat %s
$epochTime

#Get the Send-TCPData function
. C:\automation\AutomationFunctions.ps1

###########################################
#Demographic data needed throughout the script
###########################################

#get full inventory data
$hostInventory = Import-Csv .\hostInventory.csv

#get list of locations
$locations = $HostInventory.location | Sort-Object -Unique

#get list of OS types
$osTypes = $HostInventory.OS | Sort-Object -Unique

#Get an array of hostnames
$hostList = $hostInventory.Hostname

###########################################
#Host inventory
###########################################

#create empty array for graphite import lines
$outputLines = @()

#get counts per OS type, per location
foreach( $osType  in $osTypes){
    foreach( $location in $locations){
        $metricLocation = $location.ToLower() -replace " "
        $metricOS = $osType.ToLower() -replace " "
        $count = ($HostInventory | Where-Object { ($_.Location -eq $location) -and ($_.OS -eq $osType)} ).Count
        $outputLines += "capstone.inventory.$metricLocation.$metricOS $count $epochTime"
    }
}

if( $GraphiteImport){
    $outputLines | Send-TCPData -remoteHost ubuntu -remotePort 2003 -Verbose
}
else {
    $outputLines
}
###########################################
#Local Admin Count
###########################################

#Get the grouplist data into an object
$groupList = (Get-Content .\groupList.json | ConvertFrom-Json)

$outputLines = @()
foreach( $hostname in $hostList){
    #Find this host in the source data and get all the local admins
    $localAdminGroup = ($groupList |
        Where-Object Hostname -eq $hostname).Groups |
        Where-Object GroupName -eq 'Administrators'
    
    $localAdminCount = $localAdminGroup.Users.Count

    $outputLines += "capstone.hoststats.$hostname.admincount $localAdminCount $epochTime"
}

if( $GraphiteImport){
    $outputLines | Send-TCPData -remoteHost ubuntu -remotePort 2003 -Verbose
}
else {
    $outputLines
}
###########################################
#Patch Lag
###########################################

#get the vuln scan results into an object
$vulnData = (Get-Content .\VulnScans.json | ConvertFrom-Json)

$outputLines = @()
foreach( $hostname in $hostList){
    #get all the missing patches for this host
    $missingPatches = ($vulnData | 
        Where-Object Hostname -eq $hostname).MissingPatches
    
    $missingPatchCount = $missingPatches.Count

    "$hostname $missingPatchCount"
    #if missing patches are found for a host...
    if( $missingPatchCount -ne 0){
        #get the date of the oldest missing patch
        $oldestPatchDate = ($missingPatches | 
            Select-Object @{n='patchDate';e={Get-Date -date $_.FirstSeenDate}} | 
            Sort-Object -Property PatchDate | 
            Select-Object -First 1).PatchDate
    
        #get the "patch lag" for this host
        $patchLag = (New-TimeSpan -Start $oldestPatchDate -End (Get-Date)).Days
    }
    #if no patches are missing, set patch lag to 0
    else {
        $patchLag = 0
    }
    
    $outputLines += "capstone.hoststats.$hostname.patchlag $patchLag $epochTime"
}

if( $GraphiteImport){
    $outputLines | Send-TCPData -remoteHost ubuntu -remotePort 2003 -Verbose
}
else {
    $outputLines
}
###########################################
#Vulnerabilities
###########################################

#get the vuln scan results into an object
$vulnData = (Get-Content .\VulnScans.json | ConvertFrom-Json)

$outputLines = @()
foreach( $hostname in $hostList){
    #get all the missing patches for this host
    $vulns = ($vulnData | 
        Where-Object Hostname -eq $hostname).Vulnerabilities
    
    
    
    $outputLines += "capstone.hoststats.$hostname.vuln.patchlag $patchLag $epochTime"
}

if( $GraphiteImport){
    $outputLines | Send-TCPData -remoteHost ubuntu -remotePort 2003 -Verbose
}
else {
    $outputLines
}