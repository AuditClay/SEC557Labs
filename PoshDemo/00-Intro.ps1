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
$procName = 'pwsh'
$procName
Get-Process -Name "$procName"

################################
#Single quotes would have looked for all process named (literally) "$procName"
Get-Process -Name '$procName'

#Get-Help gives information about how to use commands (like Unix man)
Get-Help -Name Get-LocalUser

#-Name is postional
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
Get-Help -Name Get-LocalUser -Online
