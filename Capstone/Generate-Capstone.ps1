
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

        $scanValue = Get-Random -Minimum 0 -Maximum 99

        if ($scanValue -ge 10) {
            $scanDateOffset = -2
        }
        elseif ($scanValue -eq 4) {
            $scanDateOffset = -9
        }
        elseif ($scanValue -eq 0) {
            $scanDateOffset = -16
        }
        else {
            $scanDateOffset = -99
        }
        

        #$baseDate = Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0
        $baseDate = Get-Date -Date ((Get-Date).ToShortDateString())
        $lastScannedDate = ($baseDate.AddDays($scanDateOffset)).ToShortDateString()


        for ($missingPatchCount = 0; $missingPatchCount -lt $MaxMissingPatches; $missingPatchCount++) {

            $patchNumber = Get-Random -Minimum 11111 -Maximum 99999999
            $patchID = Get-NumberedName -Name "" -Digit ($patchNumber) -PadAmt 8

            $foundWeek = Get-Random -Minimum 0 -Maximum $MaxWeeks

            if ($foundWeek -ge 2) {
                $foundWeekOffset = (($foundWeek * 7) + 2) * -1
            }
            elseif ($foundWeek -eq 1) {
                $foundWeekOffset = (($foundWeek * 7) + 2) * -1
            }
            elseif ($foundWeek -eq 0) {
                $foundWeekOffset = (($foundWeek * 7) + 2) * -1
            }
            else {
                $foundWeekOffset = -99
            }

            $lastScannedDateValue = (Get-Date -Date ((Get-Date).ToShortDateString())).AddDays($scanDateOffset)
            $baseFoundDate = Get-Date -Date (($lastScannedDateValue).ToShortDateString())
            $firstFoundDate = ($baseFoundDate.AddDays($foundWeekOffset)).ToShortDateString()

            $missingPatchEntry = [PSCustomObject] @{
                "PatchID" = $patchID
                "FirstSeenDate" = $firstFoundDate
            }

            $MissingPatches += $missingPatchEntry
        }


        $scannedHostsEntry = [PSCustomObject] @{
            "Hostname" = $hostName
            "LastScanDate" = $lastScannedDate
            "MissingPatches" = $MissingPatches
        }

        $ScannedHosts += $scannedHostsEntry
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


#Get-HostInventory -MaxHosts 100 | ConvertTo-Csv | Out-File "hostInventory.csv"


#$GroupListData = Get-HostGrouplists
#$GroupListData | ConvertTo-Json -Depth 5 -Compress | Out-File "groupList.json"
#Solution:
#.\Generate-Capstone.ps1 | ConvertFrom-Json | Select-Object @{Name="Hostname"; Expression={$_.Hostname}}, @{N="Admincount"; E={($_.Groups | Where-Object Groupname -eq "Administrators").Users.Count}}
#Get-Content .\groupList.json | ConvertFrom-Json | Select-Object @{Name="Hostname"; Expression={$_.Hostname}}, @{N="Admincount"; E={($_.Groups | Where-Object Groupname -eq "Administrators").Users.Count}} | Where-Object Admincount -gt 4 | Measure-Object

Get-VulnScanData -MaxHosts 100 -MaxMissingPatches 10 