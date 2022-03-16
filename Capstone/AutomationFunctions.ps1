function Send-TCPData {
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

    .PARAMETER metrics
    An array of strings representing metric lines in Graphite import format, i.e. 
    "servers.server1.cpu.average 45 1638147459"
    
    .PARAMETER remoteHost
    The name of the remote host running carbon-cache which will receive the data

    .PARAMETER remotePort
    The port number of the remote carbon-cache process
    #>

    #Allow for common parameters like -verbose
    [cmdletbinding()]

    # Metrics can be passed in the $metrics parameter or as pipeline input
    # Parameters can set the host and port for the remote Carbon-cache server
    param(
        [Parameter(ValueFromPipeline)] $metrics,
        [string]$remoteHost = "ubuntu",
        [int]$remotePort = 2003
    )

    #process the metrics input
    #The begin block runs before the input pipeline/metrics parameter is processed
    begin {
        try {
            #Count the total number of input lines processed
            $linesProcessed = 0
            Write-Verbose "Opening socket to $remoteHost`:$remotePort"

            #use a .NET TcpClient object to make the connection
            $socket = New-Object System.Net.Sockets.TcpClient($remoteHost, $remotePort)
        }
        #Bail out if the connection could not be made
        catch {
            Throw "Could not open connection to $remoteHost`:$remotePort"
        }
    }
    #The process block handles the input object as either an array or as a pipeline of objects
    #For the pipeline, it works like a foreach loop
    process {
        Write-Verbose "Received $metrics"
        #Count the lines processed on this iteration
        $linesProcessed += $metrics.Count
        #insert newlines so that the metrics will occur one per line on the TCP stream, as
        #Graphite/Carbon expects
        $metrics | ForEach-Object {
            $message += ($_ + "`n")
        }
    }
    end {
        try {
            Write-Verbose "Sending $message"
            #package the data for sending over a byte stream on the TCP socket
            $dataBytes = [System.Text.Encoding]::ASCII.GetBytes($message)
            $stream = $socket.GetStream()
            $stream.Write($dataBytes, 0, $dataBytes.Length)

            #Close down the socket and associated stream
            Write-Verbose "$linesProcessed metrics processed"
            Write-Verbose "Closing stream"
            $stream.Close()
            Write-Verbose "Closing socket"
            $socket.Close()
        }
        catch {
            Throw "Exception while sending data"
        }
    }
}
