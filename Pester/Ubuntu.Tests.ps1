#Test that all required graphite schemas exist
#Check installed software versions
Describe 'Tests for Ubuntu VM' {
    Context 'General Setup' {
        #Check Graphite setup
        It 'Graphite schemas.conf is correct'{
            #ensure the file /opt/graphite/conf/storage-schemas.conf
            #has sha1 hash of cd6ef60b158b77f30e6faf34416a8096e415e142
            sudo cat /opt/graphite/conf/storage-schemas.conf | sha1sum | 
                Should -BeLike 'cd6ef60b158b77f30e6faf34416a8096e415e14'
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
            #Use the get-filehash cmd to ensure the file
            # 
            #has sha1 hash of cd6ef60b158b77f30e6faf34416a8096e415e142
        }
    }
}