function Send-TCPData {
    #Allow for common parameters like -verbose
    [cmdletbinding()]
    param(
        [int]$remotePort = 2003,
        [string]$remoteHost = "ubuntu"
    )

    #process the pipeline input
    begin {
        Write-Verbose "Opening socket to $remoteHost`:$remotePort"
        $socket = new-object System.Net.Sockets.TcpClient($remoteHost, $remotePort)
    }
    process {
        $message += $_
        Write-Verbose "Received $_"
    }
    end {
        Write-Verbose "Sending $message"
        $dataBytes = [System.Text.Encoding]::ASCII.GetBytes($message)
        $stream = $socket.GetStream()
        $stream.Write($dataBytes, 0, $dataBytes.Length)
    }
}