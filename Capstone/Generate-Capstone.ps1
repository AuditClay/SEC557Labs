
#Lists
$GroupNameList = @(
    "Administrators",
    "Backup Operators",
    "Device Owners",
    "Distributed COM Users",
    "Event Log Readers",
    "Guests",
    "Performance Log Users",
    "Performance Monitor Users",
    "Power Users",
    "Remote Desktop Users",
    "Remote Management Users",
    "Replicator",
    "System Managed Accounts Group",
    "Users"
)

$SoftwareList = @(
    "SANS 5X7 AV",
    "SoapUI",
    "7-Zip 19.00 (x64)",
    "Git version",
    "Mozilla Firefox ESR (x64 en-US)",
    "OpenSSL (64-bit)",
    "PuTTY (64-bit)",
    "Windows Subsystem for Linux Update",
    "AWS Command Line Interface",
    "Java 8 (64-bit)",
    "Microsoft Visual C++ 2019 X64 Additional Runtime",
    "KeePassXC",
    "Microsoft Visual C++ 2008 Redistributable",
    "Microsoft Visual C++ 2019 X64 Minimum Runtime",
    "PowerShell",
    "VMware Tools",
    "Microsoft Visual Studio Code",
    "Wireshark 64-bit",
    "Java 8 Update",
    "Java Auto Updater",
    "Citrix XenCenter",
    "OpenOffice",
    "Microsoft Visual C++ 2008 Redistributable",
    "Microsoft Visual C++ 2015-2019 Redistributable (x64)",
    "Microsoft Visual C++ 2019 X86 Additional Runtime",
    "RVTools",
    "Microsoft Visual C++ 2015-2019 Redistributable (x86)",
    "Microsoft Visual C++ 2019 X86 Minimum Runtime",
    "XmlNotepad",
    "MySQL Connector Net",
    "Microsoft OneDrive",
    "Postman-win"
)


#============================================================

#Utilities
function Get-NumberedName {
    param (
        [string]$Name = "Test",
        [int]$Digit = 0,
        [int]$PadAmt = 3
    )
    $returnValue = "{0:d$PadAmt}" -f $Digit
    return $Name + $returnValue
}


#============================================================


#Generators

Function Get-HostPatchData {
    param( $PatchAgeMinWeeks = 0)
    $missingPatches = Get-Random -Minimum 0 -Maximum 15
    $patchList = @()
    for( $i = 0; $i -lt $missingPatches; ++$i){
        $ageFactor = Get-Random -Minimum 0 -Maximum 100

        #90% chance of 1-4 weeks of age
        if( $AgeFactor -lt 95 ){
            $weeks = Get-Random -Minimum $patchAgeMinWeeks -Maximum 4
        }
        elseif ($patchAge -lt 98){
            $weeks = Get-Random -Minimum 4 -Maximum 7
        } 
        else {
            $weeks = Get-Random -Minimum 7 -Maximum 10
        }
        $patchAge = ($weeks * 7) + 2
        $patchNum = Get-Random -Minimum 1000000 -Maximum 9999999
        $firstSeenDate = ((Get-Date).AddDays(0 - $patchAge )).ToShortDateString()
        $ageEntry = [PSCustomObject]@{
            FirstSeenDate = $firstSeenDate
            PatchID = $patchNum
        }
        $patchList += $ageEntry
     }
     $patchList 
}

Function Get-HostVulnData {
    param( $PatchAgeMinWeeks = 0)
    $vulnCount = Get-Random -Minimum 0 -Maximum 15
    $vulnList = @()
    for( $i = 0; $i -lt $vulnCount; ++$i){
        $ageFactor = Get-Random -Minimum 0 -Maximum 100

        #95% chance of 1-4 weeks of age
        if( $AgeFactor -lt 95 ){
            $weeks = Get-Random -Minimum $patchAgeMinWeeks -Maximum 4
        }
        elseif ($patchAge -lt 98){
            $weeks = Get-Random -Minimum 4 -Maximum 7
        } 
        else {
            $weeks = Get-Random -Minimum 7 -Maximum 10
        }
        #93% low, 4% Medium, 2% High, 1% Critical
        $critFactor = Get-Random -Minimum 0 -Maximum 100
        if( $critFactor -lt 93 ){
            $criticality = "Low"
        }
        elseif( $critFactor -lt 97 ){
            $criticality = "Medium"
        }
        elseif( $critFactor -lt 99 ){
            $criticality = "High"
        }
        else {
            $criticality = "Critical"
        }

        $patchAge = ($weeks * 7) + 2
        $CVENum = "CVE2021-" + (Get-Random -Minimum 1000 -Maximum 9999).ToString()
        $firstSeenDate = ((Get-Date).AddDays(0 - $patchAge )).ToShortDateString()
        $ageEntry = [PSCustomObject]@{
            FirstSeenDate = $firstSeenDate
            CVE = $CVENum
            Criticality = $criticality
        }
        $vulnList += $ageEntry
     }
     $vulnList 
}

function Get-SoftwareList {
    param (
        [int]$MaxHosts = 100,
        [int]$failPercent = 4
    )
    $softwareEntries = @()
    for ($hostCount = 0; $hostCount -lt $MaxHosts; $hostCount++) {
        $hostName = Get-NumberedName -Name "Host" -Digit ($hostCount + 1)

        foreach( $appName in $SoftwareList){
            if( $appName -eq "SANS 5X7 AV" ){
                $failFactor = Get-Random -Minimum 0 -Maximum 100
                if( $failFactor -lt $failPercent ){
                    $appVersion = '1.234'
                }
                else {
                    $appVersion = '1.235'
                }
            }
            else {
                $appVersion = ($appName -split " ").Count.ToString()
                $appVersion += "." 
                $appVersion += ($appName.Length - (Get-Random -Minimum 0 -Maximum 3)).ToString()
                #$appVersion = [float](Get-Random -Minimum 1100 -Maximum 9999) / 1000.0
            }

            if( $appName -like '*64*'){
                $installPath = "C:\Program Files\$appName"
            }
            else {
                $installPath = "C:\Program Files (x86)\$appName"
            }
            $softwareEntry = [PSCustomObject] @{
                "Hostname" = $hostName
                "AppName" = $appname
                "InstallPath" = $installPath
                "AppVersion" = $appVersion
            }
            $softwareEntries += $softwareEntry
        }
    }
    $softwareEntries
}
function Get-VulnScanData {
    param (
        [int]$MaxHosts = 100,
        [int]$MaxMissingPatches = 10,
        [int]$MaxWeeks = 10
    )

    #Setup
    $ScannedHosts = @()

    for ($hostCount = 0; $hostCount -lt $MaxHosts; $hostCount++) {
        $hostName = Get-NumberedName -Name "Host" -Digit ($hostCount + 1)

        $missedThisWeekFactor = Get-Random -Minimum 0 -Maximum 100
        if($missedThisWeekFactor -lt 3) {
            $patchAgeMinWeeks = 1
        }
        else {
            $patchAgeMinWeeks = 0
        }
        $scanAge = ($patchAgeMinWeeks * 7) + 2
        $lastScanDate = ((Get-Date).AddDays(0 - $scanAge )).ToShortDateString()
    
        $patchList = Get-HostPatchData -PatchAgeMinWeeks $patchAgeMinWeeks
        $vulnList = Get-HostVulnData -PatchAgeMinWeeks $patchAgeMinWeeks
        $patchEntry = [PSCustomObject]@{
            Hostname = $hostName
            LastScanDate = $lastScanDate
            MissingPatches = $patchList
            Vulnerabilities = $vulnList
        }
        $ScannedHosts += $patchEntry
    }

    return $ScannedHosts
}

function Get-HostInventory {
    param (
        [int]$MaxHosts = 10,
        [int]$LocationBias = 4,
        [int]$OSBias = 2
    )

    #Inventory Setup
    $Inventory = @()

    for ($hostCount = 0; $hostCount -lt $MaxHosts; $hostCount++) {
        $hostName = Get-NumberedName -Name "Host" -Digit ($hostCount + 1)      

        $locationValue = Get-Random -Minimum 0 -Maximum 10
        
        if ($locationValue -ge $LocationBias) {
            $locationName = "Main Office"
        }
        else {
            $locationName = "Branch Office"
        }

        $osValue = Get-Random -Minimum 0 -Maximum 10
        
        if ($osValue -ge $OSBias) {
            $osName = "Workstation"
        }
        else {            
            $osName = "Server"
        }

        $inventoryEntry = [PSCustomObject] @{
            "Hostname" = $hostName
            "Location" = $locationName
            "OS" = $osName
        }
        
        $Inventory += $inventoryEntry
    }
    return $Inventory
}

function Get-HostGrouplists {
    param (
        [int]$MaxHosts = 100,

        [int]$MaxGroups = 15,
        [int]$MinGroups = 2,

        [int]$MaxUsers = 11,
        [int]$MinUsers = 1
    )

    #40% of machines meet compliance standards
    #Admin count between 1-10

    $Hosts = @()
    for ($hostCount = 0; $hostCount -lt $MaxHosts; $hostCount++) {

        $hostName = Get-NumberedName -Name "Host" -Digit ($hostCount + 1)
        
        #Group Setup
        $numGroups = Get-Random -Minimum $MinGroups -Maximum $MaxGroups
        $Groups = @()

        for ($groupCount = 0; $groupCount -lt $numGroups; $groupCount++) {
            
            $groupName = $GroupNameList[$groupCount]

            #Users Setup
            $numUsers = Get-Random -Minimum $MinUsers -Maximum $MaxUsers
            $Users = @()

            for ($userCount = 0; $userCount -lt $numUsers; $userCount++) {
                
                $userEntry = [PSCustomObject] @{
                    "Name" = Get-NumberedName -Name "User" -Digit ($userCount + 1)
                }

                $Users += $userEntry
            }

            $groupEntry = [PSCustomObject] @{
                "Groupname" = $groupName
                "Users" = $Users
            }

            $Groups += $groupEntry
        }

        $hostEntry = [PSCustomObject] @{
            "Hostname" = $hostName
            "Groups" = $Groups
        }
        $Hosts += $hostEntry
    }

    return $Hosts
}

#Set Random
Get-Random -SetSeed 314159 | out-null

Get-HostInventory -MaxHosts 100 | ConvertTo-Csv | Out-File "hostInventory.csv"

$GroupListData = Get-HostGrouplists
$GroupListData | ConvertTo-Json -Depth 5 -Compress | Out-File "groupList.json"
#Solution:
#.\Generate-Capstone.ps1 | ConvertFrom-Json | Select-Object @{Name="Hostname"; Expression={$_.Hostname}}, @{N="Admincount"; E={($_.Groups | Where-Object Groupname -eq "Administrators").Users.Count}}
#Get-Content .\groupList.json | ConvertFrom-Json | Select-Object @{Name="Hostname"; Expression={$_.Hostname}}, @{N="Admincount"; E={($_.Groups | Where-Object Groupname -eq "Administrators").Users.Count}} | Where-Object Admincount -gt 4 | Measure-Object

Get-VulnScanData -MaxHosts 100 -MaxMissingPatches 10 | ConvertTo-Json -Depth 5  -Compress | Out-File VulnScans.json

Get-SoftwareList -MaxHosts 100 | Export-Csv "softwareInventory.csv"
#Get-Content .\VulnScans.json | ConvertFrom-Json | Select-Object Hostname, @{n='MaxPatchAge';e={(New-TimeSpan -Start ($_.MissingPatches | Sort-Object FirstSeenDate | Select-Object -first 1).FirstSeenDate -End (Get-Date)).TotalDays}} | Select-Object Hostname, MaxPatchAge, @{n='ZeroMax';e={if ($null -eq $_.MaxPatchAge){0} else {$_.MaxPatchAge}}}
