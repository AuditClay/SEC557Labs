#Requires -RunAsAdministrator
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
        #Use test-net connection to verify that TCP port 2003 
        #is reachable on ubuntu host
        It 'Graphite service is reachable on Ubuntu' {
            $true | Should -beFalse
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
        #use 'jq.exe -V' to check version of jq.exe
        #current version is 'jq-1.6'
        It 'jq.exe is correct version' {
            $true | Should -beFalse
        }
        #Check that we got results from OSQuery
        It 'OSqueryi returns results' {
            $softwareVersions.Count | Should -beGreaterThan 0
        }
        It 'OSqueryd service is running' {
            $true | Should -beFalse
        }
    }
    Context 'Lab0'{
        BeforeAll {
            $gitStatus = (git status)
        }
        It 'VMTools is installed' {
            $true | Should -beFalse
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
            $uri = 'https://fleet.sec557.local:8443'
            (Invoke-WebRequest -SkipCertificateCheck -Uri $uri).StatusCode | 
                Should -Be 200
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
             (Get-LocalUser |  Where-Object Enabled -eq $true).count | Should -be 2
        }


    }
    Context 'Lab1.2'{
        #Use Test-Path to ensure that the XML file for the books
        #database exists
        It 'Books.xml exists' {
            $true | Should -beFalse
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
            $true | Should -beFalse
        }
        #Check that the NMAP XML file has correct results in it
        #TODO: Finish this test
        It 'NMAP scan has 59 open ports'{
            $xScan = New-Object System.Xml.XmlDocument
            $file = Resolve-Path 'C:\Users\auditor\SEC557Labs\Lab1.2\nmapScan.xml'
            $xScan.load($file)

            $true | Should -beFalse
        }
        #Check that the 81 CSV files are in the VulnScanResults subdirectory
        #Use Get-ChildItem on that full directory path and count the results
        It 'Vulnerabilty scan directory has 81 CSV files'{
            $true | Should -beFalse
        }
        #Ingest the CSVs and make sure that the correct number of
        #Nessus results are there
        It 'Vulnerabilty scans have 29834 results'{
            $true | Should -beFalse
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
        #Get 100 Github closed issues into a variable for testing
        BeforeAll {
            $uri = "https://api.github.com/repos/PowerShell/PowerShell/issues?per_page=10`&state=closed"
            $issueResponse = Invoke-WebRequest -Uri $uri
            $issueContent = $issueResponse.Content
            $issues = Invoke-RestMethod -Method Get -Uri $uri
        }
        It 'Github issues API returns 10 results' {
            $issues.Count | Should -Be 10
        }
        #Run a command with jq to make sure it processes okay
        It 'jq parses issue title'{
            $issueContent | jq '.[0].created_at' |
                Should -Not -BeNullOrEmpty
        }
        #Make sure that the student MTTR calculation returns a number > 0
        It 'MTTR returns calculation returns a positive result' {
            ($issues | 
                Select-Object @{n='TimeToResolve'; `
                    e={(New-TimeSpan -Start (Get-Date -date $_.created_at) `
                    -End ($_.closed_at)).TotalDays} } |  
                Measure-Object -Property TimeToResolve -Average).Average | 
                Should -BeGreaterThan 0
        }
    }
    #This lab rehashes some of the commands from the previous lab,
    #but it needs the secrets modules, so test that they are installed
    #and working
    Context 'Lab2.3'{
        #Load the modules so we can test them
        BeforeAll {
            Import-Module Microsoft.PowerShell.SecretManagement
            Import-Module Microsoft.PowerShell.SecretStore
        }
        #Use Get-Command to make sure that Get-Secret is included 
        #in the SecretManagement module
        It 'SecretManagement module contains Get-Secret command'{
            $true | Should -beFalse
        }
        #Use Get-Command to make sure that  Get-SecretStoreConfiguration is included 
        #in the SecretStore module  
        It 'SecretStore module contains Get-SecretStoreConfiguration command'{
            $true | Should -beFalse
        }    
    }
    #Students manually configure a scheduled task in this lab
    #We'll just check to see that the correct files all exist
    #using the Test-path command and full file paths
    Context 'Lab2.4'{
        It 'AutomationFunctions.ps1 exists in lab directory'{
            $true | Should -beFalse
        }
        It 'GithubIssues.ps1 exists in lab directory'{
            $true | Should -beFalse
        }
        It 'Run-GithubIssues.ps1 exists in lab directory'{
            $true | Should -beFalse
        }
        It 'GithubIssues.xml exists in lab directory'{
            $true | Should -beFalse
        }
        It 'issues.json exists in lab directory'{
            $true | Should -beFalse
        }
    }
    Context 'Lab3.1'{
        #Run the script to create the student data files
        #Using Push- and Pop-Location so that the file will be created in the right place
        BeforeAll{
            Push-Location C:\Users\auditor\SEC557Labs\Lab3.1\
            .\GetPatchData.ps1
            $patchAgeData = Import-Csv .\patchAge.csv
            $patchdata = Import-Csv .\patches.csv
        }
        AfterAll{
            Remove-Item patches.csv
            Remove-Item patchAge.csv
            Pop-Location
        }
        It 'Get-patchData.ps1 script exists'{
            $true | Should -beFalse
        }
        It 'patchAge.csv contains 36600 records'{
            $true | Should -beFalse
        }
        It 'patches.csv has 12840 records' {
            $true | Should -beFalse
        }
        It 'patchAge.csv contains 100 servers' {
            $servers = $patchdata | Select-Object Source -Unique
            $servers.Count | Should -Be 100
        }
    }
    Context 'Lab3.2'{
        #Students are asked to use secedit to export local security policy
        BeforeAll {
            Push-Location C:\users\auditor\SEC557Labs\Lab3.2\
            SecEdit.exe /export /cfg localSecPolicy.txt
            $localPolicy = Get-Content .\localSecPolicy.txt
        }
        AfterAll {
            Remove-Item C:\users\auditor\SEC557Labs\Lab3.2\localSecPolicy.txt
            Pop-Location
        }
        #Use Get-Module to check the version of the Pester module
        It 'Pester is at least version 5'{
            $true | Should -beFalse
        }
        #Verify that user testing results will match the lab
        It 'Local administrator account is disabled' {
            $true | Should -beFalse
        }
        It 'Local guest account is disabled' {
            $true | Should -beFalse
        }
        It 'Local administrator group has 2 members' {
            $true | Should -beFalse
        }
        #Verify OSQueryd results will match lab
        It 'OSQueryd is installed' {
            $true | Should -beFalse
        }
        It 'OSQueryd is running' {
            $true | Should -beFalse
        }
        It 'OSQueryd is has automatic startup' {
            $true | Should -beFalse
        }
        #Validate that the registry tests done by the student 
        #will return correct results
        It 'LSA LimitBlankPasswordUse is 1' {
            $true | Should -beFalse
        }
        It 'LSA NoLMHash is 1' {
            $true | Should -beFalse
        }
        It 'LSA RestrictAnonymous is 0' {
            $true | Should -beFalse
        }
        It 'Minimum Password Age is 0' {
            #Find the MinimumPasswordAge setting in the text file
            $MinPwdAge = ($localPolicy | Select-String "MinimumPasswordAge" -NoEmphasis) `
                -Replace 'MinimumPasswordAge = ', ''
            $MinPwdAge | Should -Be '0'
        }
        It 'BackupPrivilege Contains Administrators and backup Operators Groups'{
            $backupUsers = ($localPolicy | Select-String "SeBackupPrivilege" -NoEmphasis) `
                -Replace 'SeBackupPrivilege = ', '' -Split "," -replace '\*', ''
            $groupNames=($backupUsers | foreach { Get-LocalGroup | Where-Object Sid -eq $_ }).Name
            $groupNames | Should -Contain 'Administrators'
            $groupNames | Should -Contain 'Backup Operators'
        }
        It 'InstalledSoftware.ps1 shows Firefox' {
            $programNames = (C:\users\auditor\SEC557Labs\Lab3.2\InstalledSoftware.ps1)
            ($programNames | Where-Object DisplayName -like '*firefox*').Count | 
                Should -Be 1
        }
        #More tests will be needed for part 3 and following
    }
    Context 'Lab3.3'{
        It 'Test Name'{
            $true | Should -beFalse
        }
    }
    Context 'Lab3.4'{
        It 'Test Name'{
            $true | Should -beFalse
        }
    }
    Context 'Lab3.5'{
        It 'Test Name'{
            $true | Should -beFalse
        }
    }
    Context 'Lab3.6'{
        It 'Test Name'{
            $true | Should -beFalse
        }
    }
    Context 'Lab4.1'{
        It 'Test Name'{
            $true | Should -beFalse
        }
    }
    Context 'Lab4.2'{
        It 'Test Name'{
            $true | Should -beFalse
        }
    }
    Context 'Lab4.3'{
        It 'Test Name'{
            $true | Should -beFalse
        }
    }
    Context 'Lab4.4'{
        It 'Test Name'{
            $true | Should -beFalse
        }
    }
    Context 'Lab5.1'{
        It 'Test Name'{
            $true | Should -beFalse
        }
    }
    Context 'Lab5.2'{
        It 'Test Name'{
            $true | Should -beFalse
        }
    }
    Context 'Lab5.3'{
        It 'Test Name'{
            $true | Should -beFalse
        }
    }
    Context 'Lab5.4'{
        It 'Test Name'{
            $true | Should -beFalse
        }
    }
    Context 'CapStone'{
        It 'Test Name'{
            $true | Should -beFalse
        }
    }
    
}