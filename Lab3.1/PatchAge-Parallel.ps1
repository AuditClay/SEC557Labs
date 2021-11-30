<# Demo script for SANS 5x7 courses.
    Show the differences in processing speed for network operations when using a traditonal ForEach
    loop vs. a ForEach -Parallel loop. The script runs a traditional foreach-object -parallel loop
    to simulate gathering patch age information from multiple hosts. 
    To simulate successful connections to responsive hosts, we make connections
    to a loopback address. To simulate the effect of non-responsive hosts, we use
    non-existent Automatic Private IP Addressing (APIPA) addresses for some number of the hosts, 
    determined by the $FailInterval parameter (i.e. one out of every $FailInterval hosts will fail).
    
    The script measures and reports the overall and average times per host to show the difference in processing speed, 
    even with unresponsive hosts. It also shows how results can be safely gathered in a multi-threaded test and
    then output at the end of the script. Note that result ordering is not guaranteed when running parallel threads.

    To see the difference in speed between parallel and serial processing, compare the output of these two commands:

    .\PatchAge-Serial.ps1 -NumHosts 8 -FailInterval 5 -Verbose
    .\PatchAge-Parallel.ps1 -NumHosts 254 -ThrottleLimit 50 -FailInterval 5 -Verbose
#>

#Allow for the Verbose flag to work
[cmdletbinding()]

#parameter descriptions
#-ThrottleLimit - Set maximum number of parallel threads
#-NumHosts - Total number of hosts to test. 
#-FailInterval - One out of every $FailInterval hosts will be given a (likely unreachable)
#  APIPA IP address to make the connection test fail for that host
param(
    [int]$ThrottleLimit = 5,
    [int]$NumHosts = 20,
    [int]$FailInterval = 3
)

#Populate the $hostList array with a combination of "good" and "bad" hostnames,
#   based on the parameters passed by the user. "Good" hostnames will maop to 127.0.0.1
#   and "bad" hostnames will map to an APIPA address (169.254.0.1)
$hostlist = @()
for( $i=1; $i -le $NumHosts; $i++)
{
    #Make some of the hosts unreachable, based on the $FailInterval parameter
    if( ($i % $FailInterval) -eq 0 ){
        $hostlist += "badhost$i"
    }
    else {
        $hostlist += "goodhost$i"
    }
}

Write-Verbose "Running patch age test aginst host list: $hostlist"

$startTime = Get-Date

<# Create empty thread-safe hash table (dictionary) for patch results.
    Normal hashtables will occasionally have concurrency problems when accessed
    by two threads at the same time, resulting in lost data.
    
    By defining the dictionary outside the parallel code, it can be used to
    collect results from multiple concurrent threads and output after the threads
    have all terminated.
#>
$results = [System.Collections.Concurrent.ConcurrentDictionary[String,String]]@{}

#Parallel processing block using user-supplied parameters

Write-Verbose "Running in Parallel mode with limit of $throttleLimit threads"
$hostlist | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
    
    $threadID = [System.Threading.Thread]::CurrentThread.ManagedThreadId
    Write-Verbose "New Thread ID: $threadID" -Verbose:($using:VerbosePreference -eq 'Continue')

    try{
        $hostname = $_
        if( $hostname -like 'goodhost*') {
            $ipaddress = '127.0.0.1'
        }
        else {
            $ipaddress = '169.254.0.1'
        }
        $lastPatchDate = (Get-HotFix -ComputerName $ipaddress | 
            Sort-Object InstalledOn -Descending | Select-Object -First 1).InstalledOn

        #If the host was reachable and returned a result store it. Otherwise indicate the error with a value of -1
        if( $lastPatchDate) {
            $patchAge = [int](New-TimeSpan -Start $lastPatchDate -End (Get-Date)).TotalDays
        }
        else {
            $patchAge = -1
        }
    }
    catch {
        $patchAge = -2
    }
    
    
    #parallel processing blocks have their own scope, so the using keyword
    #   will give us access to the dictionary variable from the parent block
    ($using:results)["$hostname"] = $patchAge

    #get the total number of results processed by all threads so far
    $processedCount = ($using:results).Count

    #Get the $VerbosePreference from the parent block so the Verbose
    #   output will be visible if it was requested
    Write-Verbose "$hostname $patchAge" -Verbose:($using:VerbosePreference -eq 'Continue')
    Write-Verbose "Processed: $processedCount" -Verbose:($using:VerbosePreference -eq 'Continue')

}

#Dump the results as CSV. This output could be piped into Out-File or Tee-Object 
#   to save to an output file for furhter processing
"`nResults (as CSV):`n----------------------------"
$results.GetEnumerator() | Select-Object @{n='HostName';e={$_.Key}}, @{n='PatchAge';e={$_.Value}} | ConvertTo-Csv

$endTime = Get-Date
$elapsed = New-TimeSpan -Start $startTime -End $endTime
$avgTime = [float]$elapsed.TotalSeconds / [float]$NumHosts

"`nStats`n----------------------------"
"Parallel:`t$parallel"
"Host Count:`t$NumHosts"
if($Parallel) {"Threads:`t$ThrottleLimit"}
"Fail Ratio:`t1/$FailInterval of hosts"
"Elapsed Time:`t$($elapsed.TotalSeconds) seconds"
"Avg Sec/Host:`t$avgTime"
