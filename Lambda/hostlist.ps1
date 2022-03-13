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


#URL Parameter will include how many hosts to generate
if ($LambdaInput) {
    $path = $LambdaInput.path
}
else {
    # Test value when running locally.
    $path = "/100"
}

if($path.StartsWith("/")) {
    $path = $path.Substring(1)
}

#Try to parse the path as an integer, defaulting to 100 if anyone tries any funny business
$numHosts = 100
if( -not [int32]::TryParse( $path, [ref]$numHosts) ) {
    $result = @{
        'statusCode' = 500;
        'body' = 'Error processing data, please try again later'
        'headers' = @{'Content-Type' = 'text/plain'}
    }
    return $result
}

#Set Random
Get-Random -SetSeed 314159 | out-null

$hostList = Get-HostInventory -MaxHosts 100 | ConvertTo-Csv 

$result = @{
    'statusCode' = 200;
    'body' = $hostList
    'headers' = @{'Content-Type' = 'text/csv'}
}

return $result