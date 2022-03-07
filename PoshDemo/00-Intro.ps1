"Demo for 5X7 Classes"
#Everything is passed as objects on the command line
#Objects have properties (data) and methods (functions)
#Launch a few instances of notepad so we can look at the process object
notepad;notepad;notepad

#Get-Process returns OBJECTS representing the running processes on the host
Get-Process -Name Notepad

#View a list of the methods and properties of the returned object
Get-Process -Name Notepad | Get-Member

#Get the Process ID for each instance (property)
#The parentheses tell PowerShell to treat each result of the command as an object
(Get-Process -Name Notepad).Id

#Get the amount of CPU time used by each (property)
(Get-Process -Name Notepad).CPU

#Access multiple properties by using the Select-Object command
Get-Process -Name Notepad | Select-Object -Property Name, Id, CPU

#Let's look at the methods of the process object
Get-Process -Name Notepad | Get-Member -MemberType Method

################################
#Get each process to terminate (method)
(Get-Process -Name Notepad).Kill()

#Use the pipeline to pass objects from one command to another
#First, get a list of local users on the system
Get-LocalUser

#Get all of the members for the command
Get-LocalUser | Get-Member

#Use the pipeline to process the results
#Use select-object to select only the interesting properties
Get-LocalUser | Select-Object Name, LastLogon, Enabled

#Let's see how many users are enabled/disabled
################################
Get-LocalUser | Select-Object Name, LastLogon, Enabled | Group-Object Enabled

#PowerShell is mostly non-case-sensitive
#The next two commands are exactly the same
gEt-locaLuSer

################################
Get-LocalUser

#Parameters let us influence the way a command runs
#User the -Name parameter for Get-Process to return only matching processes

Get-Process -Name 'pwsh'

################################
#-Name is a "positional" parameter, so the parameter name can be omitted
Get-Process "pwsh"

#Single quotes are normally used for literal strings
Get-Process 'pwsh'

#Double quotes allow for expanding the data in a variable into a string
#Create a PowerShell variable to hold a process name (note the '$')
$procName = 'pwsh'

#View the contents of the $procName variable
$procName

#To use the variable in a string, use double quotes
"The process you are looking for is: $procName"

################################
#Single quotes would have included the literal string "$procName"
'The process you are looking for is: $procName'

#Get-Help gives information about how to use commands (like Unix man)
Get-Help -Name Get-LocalUser

#-Name is positional
Get-Help Get-LocalUser

#-Full parameter may give more help
Get-Help Get-LocalUser -Full

#Can list all parameters for a command using a wildcard
Get-Help -Name Get-LocalUser -Parameter *

#Or only parameters with a specific name pattern
Get-Help -Name Get-LocalUser -Parameter S*

#Or get information on how to use a specific parameter
Get-Help -Name Get-LocalUser -Parameter SID

#A list of examples is available for most commands
Get-Help -Name Get-LocalUser -Examples

#You can even open your default browser to the current
#online help file with the -Online parameter
##############################################endregion
Get-Help -Name Get-LocalUser -Online

"Demo for 5X7 Classes"
#Get-Member shows all the properties and methods associated with
#an object
Get-Service | Get-Member

#To show only methods, use the MemberType parameter
Get-Service | Get-Member -MemberType Method

#To show both properties and alias properties, use the MemberType parameter
Get-Service | Get-Member -MemberType Properties

#####################################
#To show only properties, pass Property to the MemberType parameter
Get-Service | Get-Member -MemberType Property


#Select specific PROPERTIES using the Select-Object cmdlet
Get-Service | Select-Object -Property ServiceName,Status,StartType 

#Select-Object can select specific OBJECTS using the Skip, First, Last and Index 
#parameters
Get-Service | Select-Object -Property Name,Status,StartType -First 1 -Last 2

#Specifying the wildcard (*) for the positional "Property" parameter 
#will return all properties. Note the change to list format instead of table
Get-Service | Select-Object *

#Select-Object allows for "calculated properties".
#N and E are shorthand for 'name' and 'expression'
#This can be used for creating an entirely new property or fo
#changing the name of a property on the fly
##################################
1..5 | Select-Object @{Name='Original';Expression={$_}}, @{n='Double';e={$_ *2}}

#Where-Object works like a SQL WHERE clause.
#The comparison format is commonly used

Get-Service | Where-Object Status -eq 'Running'

#The script block format is the older form, but sometimes useful
#Note the use of the "default variable" ($_) - which represents
#the object currently being evaluated. 
#Curly braces start and stop the script block

Get-Service | Where-Object { $_.Status -eq 'Stopped' }

#Sort-Object sorts the pipeline input in the way you specify
#Similar to the ORDER BY clause in SQL
5,5,4,7,2,5,6,1  | Sort-Object

#You can sort the pipeline input based on any property in the input object
#####################################
Get-Process | Sort-Object "Workingset64" -Descending | Select-Object -First 5

#Get-Unique returns unique items from a SORTED list

5,5,4,7,2,5,6,1,5,7,2,1  | Sort-Object | Get-Unique  

#Sort-Object -Unique is similar, but is non-case-sensitive by default
'Clay', 'aj', 'CLAY', 'AJ', 'Clay', 'aj'  | Sort-Object -Unique

#Use the -CaseSensitive switch to turn on case sensitivity
##################################
'Clay', 'aj', 'CLAY', 'AJ', 'Clay', 'aj'  | Sort-Object -Unique -CaseSensitive


#Group-Object groups like objects together (works like the SQL 'Group By' clause)
#It returns a new object with Count, Name, and Group properties
##################################
Get-Service |Group-Object -Property StartType


#Comparison operators - commonly used with Where-Object or if statements
#operators include -eq, -ne, -gt, -lt, -ge, -le
1 -lt 3
2 -gt 2
2 -ge 2

#Use an implicit conversion
#######################################
[Math]::Pi -gt 3

#Like operators - allows use of wildcards (not case-sensitive)
'SEC557' -like '*55*'
'SEC557' -like 'sec*'
'SEC557' -notlike 'sec*9'

######################################
#Adding a 'c' to the operator name makes it case sensitive
'SEC557' -clike 'sec*'

#In operators - Checks to see if object is contained in a list
3 -in 1..7
#################################
5 -notin 1..4

#Contains operators - Checks to see if a list contains an object
1..10 -contains 4
1..10 -notcontains 12
1..1000 -notcontains 12
##################################
#Case insensitivity still applies
'abc123','abc234' -contains 'ABC123'
'abc123','abc234' -ccontains 'ABC123'

###Is/IsNot - Checks for the .NET type of the object
1 -is [int]
#######################################
[Math]::Pi -isnot [string]

##Split - breaks a string into "tokens" based on a delimiter
"Clay was here" -split " "
"1,2,3,4" -split ","

## Replace - uses regex to replace parts of a string
"Clay was here 1234" -replace "[0-9]+", "XXX" 

## Omit the replacement value to eliminate the expression
###########################################
"Clay was here 1234" -replace "[0-9]+"

#BONUS - Regular expressions - use the -match operator
# regex for SEC followed by 1 or more digits
'SEC557' -match 'SEC[0-9]+'

#regex for SEC followed by EXACTLY 4 digits
'SEC557' -match 'SEC[0-9]{4}'
'SEC557' -notmatch 'SEC[0-9]{4}'

#PowerShell Regex is case-insensitive (WEIRD!!!)
'SEC557' -match 'sec[0-9]+'
###################################
'SEC557' -cmatch 'sec[0-9]+'

#Select-string does regex matches against lines of text (think GREP)
(Get-NetIPAddress).IPAddress | Select-String "^127.*"

#Turn off highlighting with the -NoEmphasis switch
##############################
(Get-NetIPAddress).IPAddress | Select-String "^127.*" -NoEmphasis

#Measure-Object is useful for counting lines and performing
#calculations on numeric fields
1,2,3,4,5 | Measure-Object -Average
1,2,3,4,5 | Measure-Object -Average -Sum -Maximum -Minimum