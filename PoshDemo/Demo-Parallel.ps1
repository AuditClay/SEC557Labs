<# Demo script for SANS 5x7 courses.
    Show the differences in processing speed for network operations when using a traditonal ForEach
    loop vs. a ForEach -Parallel loop. The script uses the Test-netConnection cmdlet to simulate any
    remote network test run against a host. To simulate the effect of non-responsive hosts, we use
    non-existent Automatic Private IP Addressing (APIPA) addresses for some number of the hosts 
    (determined by the $FailInterval parameter).
    
    The script measures and reports the overall and average times per host to show the difference in processing speed, 
    even with unresponsive hosts. It also shows how resutls can be safely gathered in a multi-threaded test and
    then output at the end of the script. Note that result ordering is not guaranteed when running parallel threads.

    To see the difference in speed between parallel and serial processing, compare the output of these two commands:

    .\Demo-Parallel.ps1 -Verbose -NumHosts 3 -FailInterval 2    
    .\Demo-Parallel.ps1 -NumHosts 128 -ThrottleLimit 50 -FailInterval 5 -Verbose -Parallel
#>

#Allow for the Verbose flag to work
[cmdletbinding()]

#parameter descriptions
#-Parallel - use the foreach-object -parallel option to run tests in parallel
#-ThrottleLimit - Set maximum number of parallel threads
#-NumHosts - Total number of hosts to test. Maximum is 255 - larger numbers will be 
#  reduced to 255
#-FailInterval - One out of every $FailInterval hosts will be given a (likely unreachable)
#  APIPA IP address to make the connection test fail for that host
param(
    [switch]$Parallel,
    [int]$ThrottleLimit = 5,
    [int]$NumHosts = 20,
    [int]$FailInterval = 3
)

#Sanity check so the IPs generated are valid. Avoids the need for binary math :)
if( $NumHosts -gt 255 ) {
    Write-Verbose "Resetting host count to the maximum of 255"
    $NumHosts = 255
}

#Populate the $hostList array with a combination of good and bad IPs,
#   based on the parameters passed by the user
$hostlist = @()
for( $i=1; $i -le $NumHosts; $i++)
{
    #Make some of the hosts unreachable, based on the $FailInterval parameter
    if( ($i % $FailInterval) -eq 0 ){
        $hostlist += "169.254.0.$i"
    }
    else {
        $hostlist += "127.0.0.$i"
    }
}

Write-Verbose "Running ping test aginst host list: $hostlist"

$startTime = Get-Date

<# Create empty thread-safe hash table (dictionary) for ping results.
    Normal hashtables will occasionally have concurrency problems when accessed
    by two threads at the same time, resulting in lost data.
    
    By defining the dictionary outside the parallel code, it can be used to
    collect results from multiple concurrent threads and output after the threads
    have all terminated.
#>
$results = [System.Collections.Concurrent.ConcurrentDictionary[String,Boolean]]@{}
$errors = [System.Collections.Concurrent.ConcurrentDictionary[String,String]]@{}
#Parallel processing block using user-supplied parameters
if( $Parallel) {
    Write-Verbose "Running in Parallel mode with limit of $throttleLimit threads"
    $hostlist | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
        $threadID = [System.Threading.Thread]::CurrentThread.ManagedThreadId
        Write-Verbose "New Thread ID: $threadID" -Verbose:($using:VerbosePreference -eq 'Continue')

        $hostname = $_
        $systemUp = (Test-NetConnection -ComputerName $hostname).pingSucceeded
        
        #parallel processing blocks have their own scope, so the using keyword
        #   will give us access to the dictionary variable from the parent block
        ($using:results)[$hostname] = $systemUP

        #get the total number of results processed by all threads so far
        $processedCount = ($using:results).Count

        #Get the $VerbosePreference from the parent block so the Verbose
        #   output will be visible if it was requested
        Write-Verbose "$hostname $systemUp" -Verbose:($using:VerbosePreference -eq 'Continue')
        Write-Verbose "Processed: $processedCount" -Verbose:($using:VerbosePreference -eq 'Continue')

        try{
            $errorNum = Get-Random -Maximum 1000
            throw "Error $errorNum"
        }
        catch{
            $errorText = $_
            ($using:errors)[$hostname] = "`"$hostname`",`"$errorText`""
        }
    }
}
#Sequential processing using traditional ForEach loop
else {
    $hostlist | ForEach-Object {
        $hostname = $_
        $systemUp = (Test-NetConnection -ComputerName $hostname).pingSucceeded
        $results[$hostname] = $systemUP
        #Increment the result counter
        $processedCount = $results.Count

        Write-Verbose "$hostname $systemUp"
        Write-Verbose "Processed: $processedCount"
    }
}

#Dump the results as CSV. This output could be piped into Out-File or Tee-Object 
#   to save to an output file for furhter processing
"`nResults (as CSV):`n----------------------------"
$results.GetEnumerator() | Select-Object @{n='HostName';e={$_.Key}}, @{n='HostUp';e={$_.Value}} | ConvertTo-Csv

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

""
""
#$errors