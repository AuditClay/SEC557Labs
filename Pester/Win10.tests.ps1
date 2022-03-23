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
            $elpased = New-TimeSpan -Start $startTime -End $endTime
            $elapsed.totalSeconds | Should -BeLessThan 30
        }
    }
    Context 'Lab0'{
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
            Set-Location 'c:\users\auditor\sec557Labs\'
            $gitStatus = (git pull)
            $gitStatus[0] | Should -Be 'On branch H01'
        }

        It 'test name' {
            $true | Should -beTrue
        }

        It 'test name' {
            $true | Should -beTrue
        }

    }
    Context 'Lab1.1'{

    }
    Context 'Lab1.2'{

    }
    Context 'Lab1.3'{

    }
    Context 'Lab1.4'{

    }
    Context 'Lab2.1'{

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