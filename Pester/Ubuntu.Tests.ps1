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

        }
        #Grafana Setup
        It 'Grafana is listening on TCP port 3000' {
            (sudo netstat -antp | grep -i 'listen'  | 
                grep -c '.*3000.*grafana-server') |
                Should -Be 1
        }
        It 'Grafana Graphite datasource provisioning file is correct' {
            #ensure the file /etc/grafana/provisioning/datasources/graphite.yaml
            #has sha1 hash of 6faa4d640c92bb09ce595b7c6ae91ff1fb0d4074
        }
        It 'Grafana MySQL datasource provisioning file is correct' {
            #ensure the file /etc/grafana/provisioning/datasources/mysql.yaml
            #has sha1 hash of 535276379ad610283bbbaf14fd47cdf604d6f401
        }

        #Fleet Setup
        It 'Fleet is listening on port 8443' {

        }

        #Git status
        It 'Git is on correct branch' {
            #Match what we did on win 10 - including beforeall{}
        }
    }
    
    #Exercise 1.1 is all on the Win10 VM
    #Exercise 1.2 is all on the Win10 VM

    Context 'Exercise 1.3' {
        It 'TableDemo.ps1 script returns 227 lines' {

        }

        It 'TableDemo.ps1 inserts 110 rows' { 
            /home/auditor/SEC557Labs/Lab1.3/tableDemo.ps1 | 
                mysql -pPassword1
            $res = "SELECT COUNT(*) FROM grafana.serverstats;" | 
                mysql -pPassword1
            $res[1] | Should -Be 110
        }
        It 'TableDemoGraphite returns 330 lines' {

        }
    }

    Context 'Exercise 1.4' {
        It 'PyramidData.ps1 returns 22256 lines' {

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

        }

        It 'uname -r returns correct value' {

        }

        It 'sysctl syncookies value is correct' {

        }

        It 'ssh config PermitRootLogin value is correct' {

        }

        It 'SSH X11Forwarding value is correct' {

        }

        It 'Python version is correct' {

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

        It 'Inspec benchmark on Ubuntu has 381 failed tests' {
            ((Get-Content /home/auditor/inspec/ubuntu.json | 
                ConvertFrom-Json).profiles.controls.results.status | 
                Where-Object { $_ -eq 'failed' }).Count | 
                Should -Be 381
        }
    }

    #AWS credential checks:
    <# ALL SHOULD RETURN VALUE OF 1:

    cat /home/auditor/.aws/credentials | egrep -c "^aws_access_key_id = \S+$"
    cat /home/auditor/.aws/credentials | egrep -c "^aws_secret_access_key = \S+$"
    cat /home/auditor/.aws/config | egrep -c "^region = \S+$"
    cat /home/auditor/.aws/config | egrep -c "^output = \S+$"
    #>
}