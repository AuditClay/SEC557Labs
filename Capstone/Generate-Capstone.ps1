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

function Get-HostInventory {
    param (
        [int]$MaxHosts = 100,
        [int]$LocationBreak = 4,
        [int]$OSBreak = 2
    )

    #Inventory Setup
    $Inventory = @()

    for ($hostCount = 0; $hostCount -lt $MaxHosts; $hostCount++) {
        $hostName = Get-NumberedName -Name "Host" -Digit ($hostCount + 1)      

        $locationValue = Get-Random -Minimum 0 -Maximum 10
        
        if ($locationValue -lt $LocationBreak) {
            $locationName = "Branch Office"
        }
        else {
            $locationName = "Main Office"
        }

        $osValue = Get-Random -Minimum 0 -Maximum 10
        
        if ($osValue -lt $OSBreak) {
            $osName = "Server"
        }
        else {
            $osName = "Workstation"
        }

        $inventoryEntry = [PSCustomObject] @{
            "Hostname" = $hostName
            "Location" = $locationName
            "OS" = $osName
        }
        
        $Inventory += $inventoryEntry
    }
    $Inventory
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

    $Hosts
}

#Set Random
Get-Random -SetSeed 314159 | out-null


Get-HostInventory -MaxHosts 100 | ConvertTo-Csv | Out-File "hostInventory.csv"


#$GroupListData = Get-HostGrouplists
$GroupListData | ConvertTo-Json -Depth 5 -Compress | Out-File "groupList.json"
#Solution:
#.\Generate-Capstone.ps1 | ConvertFrom-Json | Select-Object @{Name="Hostname"; Expression={$_.Hostname}}, @{N="Admincount"; E={($_.Groups | Where-Object Groupname -eq "Administrators").Users.Count}}
#Get-Content .\groupList.json | ConvertFrom-Json | Select-Object @{Name="Hostname"; Expression={$_.Hostname}}, @{N="Admincount"; E={($_.Groups | Where-Object Groupname -eq "Administrators").Users.Count}} | Where-Object Admincount -gt 4 | Measure-Object

