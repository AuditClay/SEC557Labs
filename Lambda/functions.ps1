function Get-NumberedName {
    param (
        [string]$Name = "Test",
        [int]$Digit = 0,
        [int]$PadAmt = 3
    )
    $returnValue = "{0:d$PadAmt}" -f $Digit
    return $Name + $returnValue
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

