.\Generate-Capstone.ps1

#Get Counts of local admins per host
"Local Admins per Host"
$groupList = Get-Content .\groupList.json | ConvertFrom-Json
$groupList | Select-Object Hostname, `
  @{n='AdminCount';e={($_.Groups | Where-Object GroupName -eq 'Administrators').Users.Count}}

