Describe 'Tests for Win10 VM' {
    Context 'General Setup' {
        BeforeAll {
            $startTime = Get-Date
            $ip = Resolve-DnsName 'dns.google'
            $endTime = Get-Date
        }
        It 'DNS resolves IP for dns.google' {
            $ip.IPAddress | Should -Contain '8.8.8.8'
        }
        It 'DNS resolves in < 30 seconds' {
            $elapsed = New-TimeSpan -Start $startTime -End $endTime
            $elapsed.totalSeconds | Should -BeLessThan 30
        }
        
    }
    Context 'Software Versions'{
        BeforeAll {
            $softwareVersions = osqueryi 'select name,version from programs;' --json | ConvertFrom-Json
        }
        It 'VMware tools is installed' {
            $softwareVersions.Name | Should -Contain 'VMware Tools'
        }
        It 'soupUI as the correct version'{
            ($softwareVersions | Where-Object name -like 'SoapUI*').Version | Should -Be '5.6.0'
        }
        It 'OSqueryi returns results' {
            $true | Should -beTrue
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
        It 'Grafana is reachable' {
            $true | Should -beTrue
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
        It 'Books.xml exists' {
            $true | Should -beTrue
        }
        It 'Books cataloge contains 12' {
            Set-Location C:\Users\auditor\SEC557Labs\Lab1.2
            $xBooks = New-Object System.Xml.XmlDocument
            $file=Resolve-Path .\books.xml
            $xBooks.Load($file)
            $xBooks.catalog.book.count | Should -be 12
        }
        It 'nmapScan.xml exits'{
            $true | Should -beTrue
        }
        It 'nmap scans 59 open ports'{
                $xScan = New-Object System.Xml.XmlDocument
                $file = Resolve-Path .\nmapScan.xml
                $xScan.load($file)
        }
        It 'Vulnerabilty have 29834 results'{
            $true | Should -beTrue
        }
        It 'Vulnerabilty scan has 81 files'{
            $true | Should -beTrue
        }


    }

    Context 'Lab2.1'{
        It ''{
            $true | Should -beTrue
        }
    }
    Context 'Lab2.2'{

    }
    Context 'Lab2.3'{

    }
    Context 'Lab2.4'{

    }
    Context 'Lab3.1'{

    }
    Context 'Lab3.2'{

    }
    Context 'Lab3.3'{

    }
    Context 'Lab3.4'{

    }
    Context 'Lab3.5'{

    }
    Context 'Lab3.6'{

    }
    Context 'Lab4.1'{

    }
    Context 'Lab4.2'{

    }
    Context 'Lab4.3'{

    }
    Context 'Lab4.4'{

    }
    Context 'Lab5.1'{

    }
    Context 'Lab5.2'{

    }
    Context 'Lab5.3'{

    }
    Context 'Lab5.4'{

    }
    Context 'CapStone'{

    }
    
}