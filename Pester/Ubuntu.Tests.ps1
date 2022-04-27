#Test that all required graphite schemas exist
#Check installed software versions
Describe 'Tests for Ubuntu VM' {
    Context 'Lab 0 and General Setup' {
        #Check Graphite setup
        It 'Graphite schemas.conf is correct'{
            #ensure the file /opt/graphite/conf/storage-schemas.conf
            #has sha1 hash of cd6ef60b158b77f30e6faf34416a8096e415e142
            sudo cat /opt/graphite/conf/storage-schemas.conf | sha1sum | 
                Should -BeLike 'cd6ef60b158b77f30e6faf34416a8096e415e142*'
        }
        It 'TCP port 2003 is open' {
            (sudo netstat -antp | grep -i 'listen' |
                grep -c '.*2003.*python3') | 
                Should -Be 1
        }
        It 'Whisper dump is installed'{
            #Ensure that this file exists:
            #/usr/local/bin/whisper-dump.py
            Test-Path -path /usr/local/bin/whisper-dump.py -Pathtype Leaf | Should -beTrue
        }
        #Grafana Setup
        It 'Grafana is listening on TCP port 3000' {
            (sudo netstat -antp | grep -i 'listen'  | 
                grep -c '.*3000.*grafana-server') |
                Should -Be 1
        }
        It 'Grafana Graphite datasource provisioning file is correct' {
            sudo cat /etc/grafana/provisioning/datasources/graphite.yaml | sha1sum | 
            Should -BeLike '6faa4d640c92bb09ce595b7c6ae91ff1fb0d4074*'
            #ensure the file /etc/grafana/provisioning/datasources/graphite.yaml
            #has sha1 hash of 6faa4d640c92bb09ce595b7c6ae91ff1fb0d4074
        }
        It 'Grafana MySQL datasource provisioning file is correct' {
            #ensure the file /etc/grafana/provisioning/datasources/mysql.yaml
            #has sha1 hash of 535276379ad610283bbbaf14fd47cdf604d6f401
            (sudo cat /etc/grafana/provisioning/datasources/mysql.yaml | sha1sum) | 
                Should -BeLike '535276379ad610283bbbaf14fd47cdf604d6f401*'
        }

        #Fleet Setup
        It 'Fleet is listening on port 8443' {
            
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
            (/home/auditor/SEC557Labs/Lab1.3/tableDemo.ps1).Count
                | Should -Be 227
        }

        It 'TableDemo.ps1 inserts 110 rows' { 
            /home/auditor/SEC557Labs/Lab1.3/tableDemo.ps1 | 
                mysql -pPassword1
            $res = "SELECT COUNT(*) FROM grafana.serverstats;" | 
                mysql -pPassword1
            $res[1] | Should -Be 110
        }
        It 'TableDemoGraphite returns 330 lines' {
            (/home/auditor/SEC557Labs/Lab1.3/tableDemoGraphite.ps1).Count
                | Should -Be 330
        }
    }

    Context 'Exercise 1.4' {
        It 'PyramidData.ps1 returns 22256 lines' {
            (/home/auditor/SEC557Labs/Lab1.4/PyramidData.ps1).Count
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
            inspec exec /home/auditor/inspec/cis-dil-benchmark/ --reporter cli json:/home/auditor/inspec/ubuntu.json
        }
        AfterAll {
            Remove-Item /home/auditor/inspec/ubuntu.json
        }
        It 'lsb_release returns correct value' {
            lsb_release -d | Should -belike '*Ubuntu 20.04* LTS'
        }

        It 'uname -r returns correct value' {
            uname -r | Should -belike '5.4.0*-generic'
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
            python3 -V | Should -belike '*3.8.10'
        }

        It 'Pester returns 2 passed tests' {

        }

        It 'Pester returns 4 failed tests' {

        }

        It 'PatchAge command returns at least 1 result' {
            (Get-Content /var/log/dpkg.log* | 
                Select-String " install " -NoEmphasis).count |
                Should -BeGreaterOrEqual 1
        }

        It 'Inspec benchmark on Ubuntu has 378 *failed* tests' {
            ((Get-Content /home/auditor/inspec/ubuntu.json | 
                ConvertFrom-Json).profiles.controls.results.status | 
                Where-Object { $_ -eq 'failed' }).Count | 
                Should -Be 378
        }

        It 'Inspec benchmark on Ubuntu has 1188 *passed* tests' {
        
        }

        It 'Inspec benchmark on Ubuntu has 65 *skipped* tests' {
        
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
        }
    }
    
    #Exercise 4.1 is all on the Win10 VM
    #Exercise 4.2 is all on the Win10 VM
    Context 'Exercise 4.3' {
        BeforeAll {
            $iam = (aws iam get-account-password-policy | ConvertFrom-Json).PasswordPolicy
            inspec exec /home/auditor/inspec/aws-foundations-cis-baseline/ -t aws:// --reporter cli json:/home/auditor/inspec/aws.json
        }
        AfterAll {
            Remove-Item /home/auditor/inspec/aws.json
        }

        It 'Password policy has MinimumPasswordLength of 20' {
            $iam.MinimumPasswordLength | Should -Be 20
        }

        It 'Password policy has RequireSymbols true' {

        }

        It 'Password policy has RequireNumbers true' {

        }

        It 'Password policy has RequireUppercaseCharacters true' {

        }

        It 'Password policy has RequireLowercaseCharacters true' {

        }

        It 'Password policy has AllowUsersToChangePassword true' {

        }

        It 'Password policy has ExpirePasswords true' {

        }

        It 'Password policy has MaxPasswordAge of 90' {

        }

        It 'Password policy has PasswordReusePrevention of 24' {

        }

        It 'Inspec benchmark on AWS has 46 *failed* tests' {
            ((Get-Content /home/auditor/inspec/aws.json | 
                ConvertFrom-Json).profiles.controls.results.status | 
                Where-Object { $_ -eq 'failed' }).Count | 
                Should -Be 46
        }

        It 'Inspec benchmark on AWS has 65 *passed* tests' {
        
        }

        It 'Inspec benchmark on AWS has 9 *skipped* tests' {
        
        }
    }


    #AWS credential checks:
    <# ALL SHOULD RETURN VALUE OF 1:

    
    cat /home/auditor/.aws/credentials | egrep -c "^aws_secret_access_key = \S+$"
    cat /home/auditor/.aws/config | egrep -c "^region = \S+$"
    cat /home/auditor/.aws/config | egrep -c "^output = \S+$"
    #>
}