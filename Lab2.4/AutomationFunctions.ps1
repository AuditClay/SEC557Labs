function Send-TCPData {
    #Allow for common parameters like -verbose
    [cmdletbinding()]

    # Metrics can be passed in the $metrics parameter or as pipeline input
    param(
        [Parameter(ValueFromPipeline)] $metrics,
        [string]$remoteHost = "ubuntu",
        [int]$remotePort = 2003,
        [switch] $PassThru        
    )

    #process the metrics input
    begin {
        try {
            $linesProcessed = 0
            Write-Verbose "Opening socket to $remoteHost`:$remotePort"
            $socket = new-object System.Net.Sockets.TcpClient($remoteHost, $remotePort)
        }
        catch {
            Throw "Could not open connection to $remoteHost`:$remotePort"
        }
    }
    process {
        Write-Verbose "Received $metrics"
        $linesProcessed += $metrics.Count
        $metrics | ForEach-Object {
            $message += ($_ + "`n")
        }
    }
    end {
        try {
            Write-Verbose "Sending $message"
            $dataBytes = [System.Text.Encoding]::ASCII.GetBytes($message)
            $stream = $socket.GetStream()
            $stream.Write($dataBytes, 0, $dataBytes.Length)
            Write-Verbose "$linesProcessed metrics processed"
            Write-Verbose "Closing stream"
            $stream.Close()
            Write-Verbose "Closing socket"
            $socket.Close()
            #If the $passThru parameter was set, then pass the metrics out on the
            #pipeline for further processing
            if( $PassThru) { $metrics }
        }
        catch {
            Throw "Exception caught while sending data"
        }
    }
    <#
    .SYNOPSIS

    Sends an array of strings containing metric lines in Graphite format to a 
    specified host:port TCP socket.

    .DESCRIPTION

    Sends an array of strings containing metric lines in Graphite format to a 
    specified host:port TCP socket. 
    Accepts metric line array as pipeline input or in the $metrics parameter.
    Uses the standard Graphite import format of "full.metric.path value epochTime", i.e.
    "servers.server1.cpu.average 45 1638147459"
    
    .INPUTS

    An array of strings representing metric lines in Graphite import format, i.e. 
    "servers.server1.cpu.average 45 1638147459"

    .PARAMETER remoteHost
    The name of the remote host running carbon-cache which will receive the data

    .PARAMETER remotePort
    The port number of the remote carbon-cache process
    #>
}