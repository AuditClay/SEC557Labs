
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

Function Generate-HostScanData {
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
function Get-VulnScanData {
    param (
        [int]$MaxHosts = 100,
        [int]$MaxMissingPatches = 10,
        [int]$MaxWeeks = 10
    )

    #Setup
    $ScannedHosts = @()
    $MissingPatches = @()

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
    
        $patchList = Generate-HostScanData -PatchAgeMinWeeks $patchAgeMinWeeks
        $patchEntry = [PSCustomObject]@{
            Hostname = $hostName
            LastScanDate = $lastScanDate
            MissingPatches = $patchList
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

Get-VulnScanData -MaxHosts 100 -MaxMissingPatches 10 | ConvertTo-Json -Depth 5 | Out-File VulnScans.json

#Get-Content .\VulnScans.json | ConvertFrom-Json | Select-Object Hostname, @{n='MaxPatchAge';e={(New-TimeSpan -Start ($_.MissingPatches | Sort-Object FirstSeenDate | Select-Object -first 1).FirstSeenDate -End (Get-Date)).TotalDays}} | Select-Object Hostname, MaxPatchAge, @{n='ZeroMax';e={if ($null -eq $_.MaxPatchAge){0} else {$_.MaxPatchAge}}}
