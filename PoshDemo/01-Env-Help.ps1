"Demo for 5X7 Classes"

#List only cmdlets
Get-Command -CommandType Cmdlet
Get-Command -CommandType Cmdlet | Measure-Object
Get-Command -CommandType Cmdlet -Name *Job

#List only functions
Get-Command -CommandType Function
Get-Command -CommandType Function -Module Storage*

#Aliases

#ls to list files in directory
ls
#or dir
dir
#or gci
gci
#or Get-ChildItem
Get-ChildItem

#List aliases using Get-Command
Get-Command -CommandType Alias

#Or get-alias
Get-Alias

#If you see an admin using an interesting alias...
Get-Alias gsv

#Applications - PowerShell uses applications from your PATH
#Find the PATH environment variable
$env:Path

# Env: is a PSDrive representing your environment variables
Get-ChildItem Env:

#Parameters modify/enhance the behavior of a command
#The CommandType parameter limits which types of commands will be returned
Get-Command -CommandType Application 

#Count the number of applications in my path
Get-Command -CommandType Application | Measure-Object

#Use the positional parameter for Name
Get-Command -CommandType Application task*

#Cmdlets always use a Verb-Noun name format
#Noun is always singular
Get-Verb

#Find commands using a specific noun
Get-Command -Noun "Service"

#Or verb...
Get-Command -Verb 'Write'

#Aside - PowerShell quotation marks
# Quotation marks are generally optional, unless using a string containing a space
# Convention is to use single quotes (') for most strings. Double Quotes (") are used for
# including a variable value in a string or for including a single quote in a string

'Hello'

#Put the PS version in a variable so we can see how quotation marks work with variables
$v = $PSVersionTable.PSVersion

#Single quotes treats strings as literals
'Your PowerShell version is $v'

#Double quotes will expand the contents of a variable
"Your PowerShell version is $v"

#Double quotes can contain a string with a single quote in it
"Hello Mr. O'Brien"

#Next line won't work - Can't enclose a single quote in a single quoted string
#Write-host 'Hello Mr. O'Brien'
#Instead, use a double single-quote to let PowerShell know you need a single quote included
'Hello Mr. O''Brien'

#Grave accent (`) - under the ~ key on US keyboards - used as "escape character"
#print a tab character
"Col 1`t`tCol 2"

#print an escaped newline character
"line 1`nline 2"

#Getting Help
Get-Help Get-Service

#Man and the help function run 'get-help | more'
#The more function does not work in the ISE, but it does in the console
Get-Alias Man
Get-Command help
man Get-Service

#Using the -online flag opens the help page from the MS website in a browser
Get-Help Get-Service -Online

#Get examples of how to run a command
Get-Help Get-ADComputer -Examples

#See the full help file
Get-Help Get-ADComputer -Full

#Get help for specific parameters (wildcards are okay!)
Get-Help Get-ADUser -Parameter F*

#Show help in a GUI window (if available)
Get-Help Get-ADUser -ShowWindow

#update your help files to the most current version
#Run these in another shell, since they take a long time...
# Update-Help
# Remove-Item -Path ".\HelpFiles" -Recurse
# New-Item -Name HelpFiles -ItemType Directory -Path "."
# Save-Help -DestinationPath ".\HelpFiles" 
# Update-Help -SourcePath ".\HelpFiles"
