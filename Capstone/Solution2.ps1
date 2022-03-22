[cmdletbinding()]
param(
    [Switch]$GraphiteImport
)

Set-Location C:\users\auditor\SEC557Labs\Capstone\
.\Generate-capstone.ps1

# Store an epoch time for all metrics
$epochTime = Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0 -AsUTC -UFormat %s
$epochTime

#Get the Send-TCPData function
. .\AutomationFunctions.ps1

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

#hash table for risk scores
$vulnScore = @{}
$vulnScore['critical']=8
$vulnScore['high']=4
$vulnScore['medium']=2
$vulnScore['low']=1

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
        $outputLines += "sec557.inventory.$metricLocation.$metricOS $count $epochTime"
    }
}

if( $GraphiteImport){
    $outputLines | Send-TCPData -remoteHost ubuntu -remotePort 2003 -Verbose
}
else {
    $outputLines
}

#Get the grouplist data into an object
$groupList = (Get-Content .\groupList.json | ConvertFrom-Json)

#get the file data into an object
$softwareInventory = import-csv .\softwareInventory.csv

#get the vuln scan results into an object
$vulnData = (Get-Content .\VulnScans.json | ConvertFrom-Json)

foreach( $hostname in $hostList){
    #Set initial risk score to zero - later tests will add to it
    $riskScore = 0

    #Get the location and OS type for this host
    $metricLocation = ($hostInventory | Where-Object Hostname -eq $hostname).location.ToLower() -replace " "
    $metricOS = ($hostInventory | Where-Object Hostname -eq $hostname).OS.ToLower() -replace " "    
    
    ###########################################
    #Local Admin Count
    ###########################################

    #Find this host in the source data and get all the local admins
    $localAdminGroup = ($groupList |
        Where-Object Hostname -eq $hostname).Groups |
        Where-Object GroupName -eq 'Administrators'
    
    $localAdminCount = $localAdminGroup.Users.Count
    $outputLines += "sec557.hoststats.$metricLocation.$metricOS.$hostname.admincount $localAdminCount $epochTime"

    ###########################################
    #AV Status
    ###########################################

    #get the version of AV running on this host
    $avVersion = ($softwareInventory | 
      Where-Object { ($_.Hostname -eq $hostname) -and ($_.AppName -eq 'SANS 5X7 AV') }).AppVersion

    #Check AV version - add to risk score if non-compliant
    if( $avVersion -ne '1.235' ) {
      #Fail - add 100 to the tisk score
      $riskScore += 100
    } 

    ###########################################
    #Vulnerabilities
    ###########################################

    #get all the vulnerabilities for this host
    $vulns = ($vulnData | 
    Where-Object Hostname -eq $hostname).Vulnerabilities
  
    foreach ( $crit in 'critical', 'high','medium','low' ) { 
      $count = ($vulns | Where-Object Criticality -eq $crit).Count
      $outputLines += "sec557.hoststats.$metricLocation.$metricOS.$hostname.vuln.$crit $count $epochTime"

      $riskScore += ($vulnScore[$crit] * $count)
    }

    ###########################################
    #Patch Lag
    ###########################################

    #get all the missing patches for this host
    $missingPatches = ($vulnData | 
        Where-Object Hostname -eq $hostname).MissingPatches
    
    $missingPatchCount = $missingPatches.Count

    #if missing patches are found for a host,
    #then calculate the patch lag
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
    
    $outputLines += "sec557.hoststats.$metricLocation.$metricOS.$hostname.patchlag $patchLag $epochTime"

    #Output the risk score after everything is added to it
    $outputLines += "sec557.hoststats.$metricLocation.$metricOS.$hostname.riskscore $riskScore $epochTime"
}

if( $GraphiteImport){
    $outputLines | Send-TCPData -remoteHost ubuntu -remotePort 2003 -Verbose
}
else {
    $outputLines
}