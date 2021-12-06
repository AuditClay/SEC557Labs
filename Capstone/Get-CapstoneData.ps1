
function Get-NumberedName {
    param (
        [string]$Name = "Test",
        [int]$Digit = 0,
        [int]$PadAmt = 3
    )
    $returnValue = "{0:d$PadAmt}" -f $Digit
    return $Name + $returnValue
}

function Get-PSCustomObjectList {
    param (
        [int]$RandomSeed,
        [int]$MaxIterations,
        
        $ReturnTypeDescription,
        $ObjectValues,
        $AssignmentProbabilities
    )
    
}