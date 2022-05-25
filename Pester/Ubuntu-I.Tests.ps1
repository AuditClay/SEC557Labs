#Test that all required graphite schemas exist
#Check installed software versions
Describe 'Tests for Ubuntu VM' {
    BeforeAll {
        $basePath = $HOME
    }
    Context 'Lab 0 and General Setup' {
        #Check Graphite setup
        It 'Graphite schemas.conf is correct'{
            #ensure the file /opt/graphite/conf/storage-schemas.conf
            #has sha1 hash of cd6ef60b158b77f30e6faf34416a8096e415e142
            sudo cat /etc/carbon/storage-schemas.conf | sha1sum | 
                Should -BeLike 'ff27d5ed3e33b0ae88e0baf562be4f070f345b85*'
        }
        It 'TCP port 2003 is open' {
            (sudo netstat -antp | grep -i 'listen' |
                grep -c '.*2003.*python3') | 
                Should -Be 1
        }
        It 'Whisper dump is installed'{
            #Ensure that this file exists:
            #/usr/local/bin/whisper-dump.py
            Test-Path -path /usr/bin/whisper-dump -Pathtype Leaf | Should -beTrue
        }
        #Grafana Setup
        It 'Grafana is listening on TCP port 3000' {
            (sudo netstat -antp | grep -i 'listen'  | 
                grep -c '.*3000.*grafana-server') |
                Should -Be 1
        }
        It 'Grafana Graphite datasource provisioning file is correct' {
            sudo cat /etc/grafana/provisioning/datasources/graphite.yaml | sha1sum | 
            Should -BeLike '79c4eb41a296bfc148edbf18a0dc20296088f600*'
        }
        It 'Grafana MySQL datasource provisioning file is correct' {
            (sudo cat /etc/grafana/provisioning/datasources/mysql.yaml | sha1sum) | 
                Should -BeLike '34c966b6d6665384ff474800d6f1dd34ce349068*'
        }

        #Fleet Setup
        It 'Fleet is listening on port 8443' {
            (sudo netstat -antp | grep -i 'listen' |
                grep -c '.*8443.*fleet') | 
                Should -Be 1
        }

        #Git status
        It 'Git is on correct branch' {
            #Match what we did on win 10 - including beforeall{}
            $gitStatus = (git status)
            $gitStatus[0] | Should -Be 'On branch H01'
        }

        It 'OSQuery service is running' {
            systemctl status osqueryd.service | egrep -c "active \(running\)" |
                Should -Be 1
        }
    }
    
    #Exercise 1.1 is all on the Win10 VM
    #Exercise 1.2 is all on the Win10 VM

    Context 'Exercise 1.3' {
        It 'TableDemo.ps1 script returns 227 lines' {
            (& "$basePath/SEC557Labs/Lab1.3/tableDemo.ps1").Count
                | Should -Be 227
        }

        It 'TableDemo.ps1 inserts 110 rows' { 
            & "$basePath/SEC557Labs/Lab1.3/tableDemo.ps1" | 
                mysql -pPassword1
            $res = "SELECT COUNT(*) FROM grafana.serverstats;" | 
                mysql -pPassword1
            $res[1] | Should -Be 110
        }
        It 'TableDemoGraphite returns 330 lines' {
            (& "$basePath/SEC557Labs/Lab1.3/tableDemoGraphite.ps1").Count
                | Should -Be 330
        }
    }

    Context 'Exercise 1.4' {
        It 'PyramidData.ps1 returns 22256 lines' {
            (& "$basePath/SEC557Labs/Lab1.4/PyramidData.ps1").Count
                | Should -Be 22256
        }
    }

    #Exercise 2.1 is all on the Win10 VM
    #Exercise 2.2 is all on the Win10 VM
    #Exercise 2.3 is all on the Win10 VM
    #Exercise 2.4 is all on the Win10 VM

    #Exercise 3.1 is all on the Win10 VM
    #Exercise 3.2 is all on the Win10 VM
    #Exercise 3.3 is all on the Win10 VM
    
    Context 'Exercise 3.4' {
        #TODO: Clay will write this to match the lab
    }

    Context 'Exercise 3.5' {
        BeforeAll {
            inspec --chef-license accept 
            inspec exec $basePath/inspec/cis-dil-benchmark/ --reporter cli json:$basePath/inspec/ubuntu.json
        }
        AfterAll {
            Remove-Item $basePath/inspec/ubuntu.json
        }
        It 'lsb_release returns correct value' {
            lsb_release -d | Should -belike '*Ubuntu 22.04* LTS'
        }

        It 'uname -r returns correct value' {
            uname -r | Should -belike '5.15.0*-generic'
        }

        It 'sysctl syncookies value is correct' {
            sysctl net.ipv4.tcp_syncookies | Should -be 'net.ipv4.tcp_syncookies = 1'
        }

        It 'ssh config PermitRootLogin value is correct' {
            sudo sshd -T | grep -i PermitRootLogin | Should -be 'permitrootlogin without-password'
        }

        It 'SSH X11Forwarding value is correct' {
            sudo sshd -T | grep -i X11Forwarding | Should -be 'x11forwarding yes'
        }

        It 'Python version is correct' {
            python3 -V | Should -belike '*3.10.4'
        }

        It 'Pester returns 2 passed tests' {
            $true | should -befalse
        }

        It 'Pester returns 4 failed tests' {
            $true | should -befalse
        }

        It 'PatchAge command returns at least 1 result' {
            (Get-Content /var/log/dpkg.log* | 
                Select-String " install " -NoEmphasis).count |
                Should -BeGreaterOrEqual 1
        }

        It 'Inspec benchmark on Ubuntu has 378 *failed* tests' {
            ((Get-Content $basePath/inspec/ubuntu.json | 
                ConvertFrom-Json).profiles.controls.results.status | 
                Where-Object { $_ -eq 'failed' }).Count | 
                Should -Be 378
        }

        It 'Inspec benchmark on Ubuntu has 1228 *passed* tests' {
             ((Get-Content $basePath/inspec/ubuntu.json | 
                ConvertFrom-Json).profiles.controls.results.status | 
                Where-Object { $_ -eq 'passed' }).Count | 
                Should -Be 1228
        }

        It 'Inspec benchmark on Ubuntu has 65 *skipped* tests' {
             ((Get-Content $basePath/inspec/ubuntu.json | 
                ConvertFrom-Json).profiles.controls.results.status | 
                Where-Object { $_ -eq 'skipped' }).Count | 
                Should -Be 65
        }
    }

    Context 'Exercise 3.6' {
        It 'OSQuery has at least 100 tables'{
            (osqueryi ".tables").Count | Should -BeGreaterOrEqual 100
        }

        It 'OSQuery returns reasonable kernel version' {
            (osqueryi "Select * from kernel_info" --json | 
                ConvertFrom-Json).version | 
            Should -BeLike '5*generic'
        }

        It 'OSQuery SSH configs returns 4 rows' {
            (osqueryi "select * from ssh_configs" --json | 
                ConvertFrom-Json).Count | 
                Should -Be 4
        }

        It 'Fleetctl binary exists' {
            #test that /usr/bin/fleetctl exists
            Test-Path -path /usr/bin/fleetctl -Pathtype Leaf | Should -beTrue
        }
    }
    
    #Exercise 4.1 is all on the Win10 VM
    #Exercise 4.2 is all on the Win10 VM
    Context 'Exercise 4.3' {
        BeforeAll {
            $iam = (aws iam get-account-password-policy | ConvertFrom-Json).PasswordPolicy
            inspec exec $basePath/inspec/aws-foundations-cis-baseline/ -t aws:// --reporter cli json:$basePath/inspec/aws.json
        }
        AfterAll {
            Remove-Item "$basePath/inspec/aws.json"
        }

        It 'Password policy has MinimumPasswordLength of 20' {
            $iam.MinimumPasswordLength | Should -Be 20
        }

        It 'Password policy has RequireSymbols true' {
            $iam.RequireSymbols | Should -Be 'true'
        }

        It 'Password policy has RequireNumbers true' {
            $iam.RequireNumbers | Should -Be 'true'
        }

        It 'Password policy has RequireUppercaseCharacters true' {
            $iam.RequireUppercaseCharacters | Should -Be 'true'
        }

        It 'Password policy has RequireLowercaseCharacters true' {
            $iam.RequireLowercaseCharacters | Should -Be 'true'
        }

        It 'Password policy has AllowUsersToChangePassword true' {
            $iam.AllowUsersToChangePassword | Should -Be 'true'
        }

        It 'Password policy has ExpirePasswords true' {
            $iam.ExpirePasswords | Should -Be 'true'
        }

        It 'Password policy has MaxPasswordAge of 90' {
            $iam.MaxPasswordAge | Should -Be 90
        }

        It 'Password policy has PasswordReusePrevention of 24' {
            $iam.PasswordReusePrevention | Should -Be 24
        }

        It 'Inspec benchmark on AWS has 46 *failed* tests' {
            ((Get-Content $basePath/inspec/aws.json | 
                ConvertFrom-Json).profiles.controls.results.status | 
                Where-Object { $_ -eq 'failed' }).Count | 
                Should -Be 46
        }

        It 'Inspec benchmark on AWS has 65 *passed* tests' {
            ((Get-Content $basePath/inspec/aws.json | 
                ConvertFrom-Json).profiles.controls.results.status | 
                Where-Object { $_ -eq 'passed' }).Count | 
                Should -Be 65
        }

        It 'Inspec benchmark on AWS has 9 *skipped* tests' {
            ((Get-Content $basePath/inspec/aws.json | 
                ConvertFrom-Json).profiles.controls.results.status | 
                Where-Object { $_ -eq 'skipped' }).Count | 
                Should -Be 9
        }
    }


    #AWS credential checks:
    <# ALL SHOULD RETURN VALUE OF 1:

    
    cat $basePath/.aws/credentials | egrep -c "^aws_secret_access_key = \S+$"
    cat $basePath/.aws/config | egrep -c "^region = \S+$"
    cat $basePath/.aws/config | egrep -c "^output = \S+$"
    #>
}