Describe 'Tests for Win10 VM' {
    Context 'General Setup' {
        #Check that DNS resolution is happening quickly
        BeforeAll {
            $startTime = Get-Date
            $ip = Resolve-DnsName 'dns.google'
            $endTime = Get-Date
        }
        It 'DNS resolves IP for dns.google' {
            $ip.IPAddress | Should -Contain '8.8.8.8'
        }
        It 'DNS resolves in < 5 seconds' {
            $elapsed = New-TimeSpan -Start $startTime -End $endTime
            $elapsed.totalSeconds | Should -BeLessThan 5
        }
        
    }
    #Check versions for installed software
    Context 'Software Versions'{
        BeforeAll {
            #Use the list from OSQuery
            #If OSQuery is not installed, then several tests will fail
            $softwareVersions = osqueryi 'select name,version from programs;' --json | ConvertFrom-Json
        }
        #Check for VMWare Tools. Version does not matter
        It 'VMware tools is installed' {
            $softwareVersions.Name | Should -Contain 'VMware Tools'
        }
        #Expected version of SOAP UI is installed
        #New versions may require new screenshots
        It 'SoapUI as the correct version'{
            ($softwareVersions | Where-Object name -like 'SoapUI*').Version | Should -Be '5.6.0'
        }
        #Check that we got results from OSQuery
        It 'OSqueryi returns results' {
            $softwareVersions.Count | Should -beGreaterThan 0
        }
        It 'OSqueryd service is running' {
            $true | Should -beTrue
        }
    }
    Context 'Lab0'{
        BeforeAll {
            $gitStatus = (git status)
        }
        It 'VMTools is installed' {
            $true | Should -beTrue
        }
        #Check that the web UI for Grafana is reachable
        #The Ubuntu VM needs to be running for this test to pass
        #Ensure that a 200 status code is returned by the server
        It 'Grafana is reachable' {
            $uri = 'http://dashboard.sec557.local:3000/'
            (Invoke-WebRequest -Uri $uri).StatusCode | 
                Should -Be 200
        }
        It 'Fleet is reachable' {
            $true | Should -beTrue
        }
        It 'Git is on correct branch' {
            $gitStatus[0] | Should -Be 'On branch H01'
        }
    }
    Context 'Lab1.1'{
        It 'Get-LocalUser returns 6 users' {
            (Get-LocalUser).count | Should -be 6
        }
        It 'Get-LocalUser returns 2 enabled users' {
            $true | Should -beTrue
        }


    }
    Context 'Lab1.2'{
        #Use Test-Path to ensure that the XML file for the books
        #database exists
        It 'Books.xml exists' {
            $true | Should -beTrue
        }
        #Check that the file contains the correct data
        It 'Books catalog contains 12 books' {
            $xBooks = New-Object System.Xml.XmlDocument
            $file=Resolve-Path 'C:\Users\auditor\SEC557Labs\Lab1.2\books.xml'
            $xBooks.Load($file)
            $xBooks.catalog.book.count | Should -be 12
        }
        #Use Test-Path to ensure that the XML file for the NMAP
        #scan exists
        It 'nmapScan.xml exits'{
            $true | Should -beTrue
        }
        #Check that the NMAP XML file has correct results in it
        It 'NMAP scan has 59 open ports'{
            $xScan = New-Object System.Xml.XmlDocument
            $file = Resolve-Path 'C:\Users\auditor\SEC557Labs\Lab1.2\nmapScan.xml'
            $xScan.load($file)

            $true | Should -beTrue
        }
        #Check that the 81 CSV files are in the VulnScanResults subdirectory
        #Use Get-ChildItem on that full directory path and count the results
        It 'Vulnerabilty scan directory has 81 CSV files'{
            $true | Should -beTrue
        }
        #Ingest the CSVs and make sure that the correct number of
        #Nessus results are there
        It 'Vulnerabilty scans have 29834 results'{
            $true | Should -beTrue
        }
    }

    Context 'Lab2.1'{
        #Validate that the web service is available and returning values
        #Windows PowerShell is easier to test with
        It 'Windows PowerShell can call web service' {
            $result = powershell.exe -file .\wsp.ps1
            $result | Should -Be 'one dollar'
        }
    }
    Context 'Lab2.2'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    Context 'Lab2.3'{
        It 'Test Name'{
            $true | Should -beTrue
        }    }
    Context 'Lab2.4'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    Context 'Lab3.1'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    Context 'Lab3.2'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    Context 'Lab3.3'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    Context 'Lab3.4'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    Context 'Lab3.5'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    Context 'Lab3.6'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    Context 'Lab4.1'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    Context 'Lab4.2'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    Context 'Lab4.3'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    Context 'Lab4.4'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    Context 'Lab5.1'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    Context 'Lab5.2'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    Context 'Lab5.3'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    Context 'Lab5.4'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    Context 'CapStone'{
        It 'Test Name'{
            $true | Should -beTrue
        }
    }
    
}